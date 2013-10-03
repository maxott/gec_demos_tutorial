defProperty('slice', '', "slice name")
defProperty('tracker', "1-#{property.slice}", "ID of tracker node")
defProperty('leecher_player', "2-#{property.slice}, 3-#{property.slice}", "List of leecher/player nodes")
defProperty('seeder', "1-#{property.slice}, 4-#{property.slice}, 5-#{property.slice}", "List of seeder nodes")

defApplication('bttrack') do |app|
  app.description = 'Bittornado BT tracker'
  app.binary_path = '/usr/bin/bttrack'
  app.defProperty('dfile', 'Database file', '--dfile', {:type => :string})
  app.defProperty('port', 'Port number', '--port', {:type => :integer})  
end

defApplication('transmission-daemon') do |app|
  app.description = 'bittorrent client with video streaming support'
  app.binary_path = '/usr/local/bin/transmission-daemon'
  app.defProperty('foreground', 'Run in foreground', '-f', {:type => :boolean})

  app.defMeasurement("stats") do |mp|
    mp.defMetric('tor_id', :int32)
    mp.defMetric('tor_name', :string)
    mp.defMetric('dl_rate', :double)
    mp.defMetric('ul_rate', :double)
    mp.defMetric('percent_done', :double)
  end
end

defApplication('transmission-remote') do |app|
  app.description = 'remote controller for transmission-daemon'
  app.binary_path = '/usr/local/bin/transmission-remote'
  app.defProperty('uplimit', 'Upload limit', '-u', {:type => :integer})
end

defApplication('vlc') do |app|
  app.description = 'VideoLAN client media player'
  app.binary_path = '/usr/local/bin/vlc.sh'
  app.defProperty('stream', 'URL to play stream from', nil, {:type => :string})

  app.defMeasurement("vlc_video") do |mp|
    mp.defMetric('i_decoded_video_blocks', :int32)
    mp.defMetric('i_played_video_frames', :int32)
    mp.defMetric('i_lost_video_frames', :int32)
  end
end

defGroup('tracker', property.tracker) do |g|
  g.addApplication("bttrack") do |app|
    r = Random.new
    app.setProperty('dfile', "/tmp/dfile#{r.rand(10}")
    app.setProperty('port', 6969)
  end
end

defGroup('seeder', property.seeder) do |g|
  g.addApplication("transmission-daemon") do |app|
    app.setProperty('foreground', true)
  end
end

defGroup('leecher-player', property.leecher_player) do |g|
  g.exec("rm /root/Downloads/*")
  # TODO also remove any incomplete / pending downloads here
  g.addApplication("transmission-daemon") do |app|
    app.setProperty('foreground', true)
    app.measure('stats')
  end
  g.addApplication("vlc") do |app|
    app.setProperty('stream', "http://localhost:8080/big_buck_bunny_480p_stereo.avi?tor_url=http://192.168.1.1/big_buck_bunny_480p_stereo.avi.torrent")
    app.measure('vlc_video')
  end
end

onEvent(:ALL_UP) do |event|
  info "Starting bittorrent streaming experiment"
  allGroups.startApplications
  wait 60
  allGroups.stopApplications
  Experiment.done
end
