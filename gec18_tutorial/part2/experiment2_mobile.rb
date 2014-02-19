defProperty('slice', 'android', "slice name")
defProperty('tracker', "0", "ID of tracker node")
defProperty('leecher', "1,9", "List of leecher/player nodes")
defProperty('fixed_player', "1", "List of leecher/player nodes")
defProperty('mobile_player', "nitos.android.s2", "List of leecher/player nodes")
defProperty('seeder', "3", "List of seeder nodes")
defProperty('upload', 2500, 'Maximum torrent upload speed in kb/s')

tracker = property.tracker.to_s.split(',').map { |x| "#{x}-#{property.slice}" }
leecher = property.leecher.to_s.split(',').map { |x| "#{x}-#{property.slice}" }
fixed_player = property.fixed_player.to_s.split(',').map { |x| "#{x}-#{property.slice}" }
seeder = property.seeder.value.to_s.split(',').map { |x| "#{x}-#{property.slice}" }
allresources = tracker + leecher + seeder + fixed_player

defApplication('clean_all') do |app|
  app.description = 'Some commands to ensure that we start with a clean slate'
  app.binary_path = 'killall -s9 bttrack transmission-daemon vlc; rm -f /root/.config/transmission-daemon/settings.json; '
  app.quiet = true
end

defApplication('clean_leechers') do |app|
  app.description = 'Ensure that leechers do not have the file to download'
  app.binary_path = 'rm -f /root/Downloads/* /root/.config/transmission-daemon/resume/* /root/.config/transmission-daemon/torrents/*'
  app.quiet = true
end

defApplication('bttrack') do |app|
  app.description = 'Bittornado BT tracker'
  app.binary_path = '/usr/bin/bttrack'
  app.defProperty('dfile', 'Database file', '--dfile', {:type => :string})
  app.defProperty('port', 'Port number', '--port', {:type => :integer})  
  app.quiet = true
end

defApplication('transmission_daemon') do |app|
  app.description = 'bittorrent client with video streaming support'
  app.binary_path = '/usr/local/bin/transmission-daemon'
  app.defProperty('foreground', 'Run in foreground', '-f', {:type => :boolean})
  app.quiet = true
  app.defMeasurement("stats") do |mp|
    mp.defMetric('tor_id', :int32)
    mp.defMetric('tor_name', :string)
    mp.defMetric('dl_rate', :double)
    mp.defMetric('ul_rate', :double)
    mp.defMetric('percent_done', :double)
  end
end

defApplication('vlc') do |app|
  app.description = 'VideoLAN client media player'
  app.binary_path = '/usr/local/bin/vlc.sh'
  app.defProperty('vstream', 'URL to play stream from', nil, {:type => :string})
  app.quiet = true
  app.defMeasurement("video") do |mp|
    mp.defMetric('i_decoded_video_blocks', :int32)
    mp.defMetric('i_played_video_frames', :int32)
    mp.defMetric('i_lost_video_frames', :int32)
  end
end

defApplication('vlc_mobile') do |app|
  app.description = 'VLC video player'
  # Define the path to the binary executable for this application
  app.binary_path = {package: 'org.videolan.vlc.betav7neon', action: 'ACTION_VIEW'}
  # Define the configurable parameters for this application
  app.defProperty("data_and_type", "Set the data for the intent along with an explicit MIME data type", "", {type: "INTENT"})
  app.platform = 'android'
end

defGroup('mobile_player', property.mobile_player) do |g|
  # Associate the application defined above to each resources
  # in this group
  g.addApplication("vlc_mobile") do |app|
    # Configure the parameters of the application
    app.setProperty('data_and_type', {:data => 'http://152.54.14.19:8080/big_buck_bunny_480p_stereo.avi?tor_url=http://192.168.1.1/big_buck_bunny_480p_stereo.avi.torrent', :type => 'application/mp4'})
  end
end  
  
defGroup('tracker', *tracker) do |g|
  g.addApplication("bttrack") do |app|
    app.setProperty('dfile', "/tmp/dfile_#{Time.now.to_i}")
    app.setProperty('port', 6969)
  end
end

defGroup('seeder', *seeder) do |g|
  g.addApplication("transmission_daemon") do |app|
    app.setProperty('foreground', true)
    app.measure('stats', :samples => 1)
  end
end

defGroup('leecher', *leecher) do |g|
  g.addApplication("transmission_daemon") do |app|
    app.setProperty('foreground', true)
    app.measure('stats', :samples => 1)
  end
end

defGroup('fixed_player', *fixed_player) do |g|
  g.addApplication("vlc") do |app|
    app.setProperty('vstream', "http://localhost:8080/big_buck_bunny_480p_stereo.avi?tor_url=http://192.168.1.1/big_buck_bunny_480p_stereo.avi.torrent")
    app.measure('video', :samples => 1)
  end
end

defGroup('all_resources', *allresources) do |g|
  g.addApplication("clean_all")
end

defGroup('all_leechers', *leecher) do |g|
  g.addApplication("clean_leechers")
end

onEvent(:ALL_UP_AND_INSTALLED) do |event|
  group("all_leechers").startApplications
  group("all_resources").startApplications
  after 10 do
    info "Starting tracker"
    group("tracker").startApplications
  end
  after 15 do
   info "Starting seeders"
   group("seeder").startApplications
   info "Starting leechers"
   group("leecher").startApplications
  end
  after 20 do
    # set the upload speed limit
    allGroups.exec("/usr/local/bin/transmission-remote -u #{property.upload.value}")
  end
  after 25 do
    info "Starting players"
    group("fixed_player").startApplications
    group("mobile_player").startApplications
  end
  after 220 do
    group("all_resources").startApplications
    Experiment.done
  end
end

defGraph 'Bittorrent' do |g|
  g.ms('stats').select {[ :oml_sender_id, :oml_seq, :oml_ts_server, :percent_done ]}
  g.caption "Bittorrent (torrent completion)"
  g.type 'line_chart3'
  g.mapping :x_axis => :oml_ts_server, :y_axis => :percent_done, :group_by => :oml_sender_id
  g.xaxis :legend => 'time [s]'
  g.yaxis :legend => 'Completion', :ticks => {:format => 's'}
end

defGraph 'VLC Player' do |g|
  g.ms('video').select {[ :oml_sender_id, :oml_seq, :oml_ts_server, :i_played_video_frames ]}
  g.caption "VLC Player (frames played)"
  g.type 'line_chart3'
  g.mapping :x_axis => :oml_ts_server, :y_axis => :i_played_video_frames, :group_by => :oml_sender_id
  g.xaxis :legend => 'time [s]'
  g.yaxis :legend => 'Frames played', :ticks => {:format => 's'}
end
