defProperty('slice', 'cdw', "slice name")
defProperty('tracker', "1", "ID of tracker node")
defProperty('leecher_player', "2,3", "List of leecher/player nodes")
defProperty('seeder', "4,5", "List of seeder nodes")
defProperty('upload', 2500, 'Maximum torrent upload speed in kb/s')

tracker = "#{property.tracker.value}-#{property.slice.value}"
leecher_player = property.leecher_player.value.split(',').map { |x| "#{x}-#{property.slice.value}" }
seeder = property.seeder.value.split(',').map { |x| "#{x}-#{property.slice.value}" }

defApplication('bttrack') do |app|
  app.description = 'Bittornado BT tracker'
  app.binary_path = 'killall -s9 bttrack; /usr/bin/bttrack'
  app.defProperty('dfile', 'Database file', '--dfile', {:type => :string})
  app.defProperty('port', 'Port number', '--port', {:type => :integer})  
end

defApplication('transmission_daemon') do |app|
  app.description = 'bittorrent client with video streaming support'
  app.binary_path = 'killall -s9 transmission-daemon; rm /root/.config/transmission-daemon/settings.json; /usr/local/bin/transmission-daemon'
  app.defProperty('foreground', 'Run in foreground', '-f', {:type => :boolean})

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
  app.binary_path = 'killall -s9 vlc; /usr/local/bin/vlc.sh'
  # property name 'stream' causes Openfire to kick us...
  app.defProperty('xstream', 'URL to play stream from', nil, {:type => :string})
  app.defMeasurement("video") do |mp|
    mp.defMetric('i_decoded_video_blocks', :int32)
    mp.defMetric('i_played_video_frames', :int32)
    mp.defMetric('i_lost_video_frames', :int32)
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

defGroup('leecher', *leecher_player) do |g|
  g.addApplication("transmission_daemon") do |app|
    app.setProperty('foreground', true)
    app.measure('stats', :samples => 1)
  end
end

defGroup('player', *leecher_player) do |g|
  g.addApplication("vlc") do |app|
    app.setProperty('xstream', "http://localhost:8080/big_buck_bunny_480p_stereo.avi?tor_url=http://192.168.1.1/big_buck_bunny_480p_stereo.avi.torrent")
    app.measure('video', :samples => 1)
  end
end

onEvent(:ALL_NODES_UP) do |event|
  group("leecher").exec("rm /root/Downloads/* /root/.config/transmission-daemon/resume/* /root/.config/transmission-daemon/torrents/*")
  after 5 do
    info "Starting tracker"
    group("tracker").startApplications
  end
  after 10 do
   info "Starting seeders"
   group("seeder").startApplications
   info "Starting leechers"
   group("leecher").startApplications
  end
  after 15 do
    # set the upload speed limit
    allGroups.exec("/usr/local/bin/transmission-remote -u #{property.upload.value}")
  end
  after 20 do
    info "Starting players"
    group("player").startApplications
  end
  after 110 do
    allGroups.exec("killall -s9 bttrack; killall -s9 vlc; killall -s9 transmission-daemon")
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

defGraph 'VLC Player' do |h|
  h.ms('video').select {[ :oml_sender_id, :oml_seq, :oml_ts_server, :i_played_video_frames ]}
  h.caption "VLC Player (frames played)"
  h.type 'line_chart3'
  h.mapping :x_axis => :oml_ts_server, :y_axis => :i_played_video_frames, :group_by => :oml_sender_id
  h.xaxis :legend => 'time [s]'
  h.yaxis :legend => 'Frames played', :ticks => {:format => 's'}
end