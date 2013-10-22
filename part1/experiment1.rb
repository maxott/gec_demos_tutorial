defProperty('resource1', "your_resource_ID", "ID of a resource")
defProperty('resource2', "your_resource_ID", "ID of a resource")

defApplication('ping') do |app|
  app.description = 'Simple Definition for the ping-oml2 application'
  app.binary_path = '/usr/bin/ping-oml2'
  app.defProperty('target', 'Address to ping', '', {:type => :string})
  app.defProperty('count', 'Number of times to ping', '-c', {:type => :integer})
  app.defMeasurement('ping') do |m|
    m.defMetric('dest_addr',:string)
    m.defMetric('ttl',:uint32)
    m.defMetric('rtt',:double)
    m.defMetric('rtt_unit',:string)
  end
  app.defMeasurement('rtt_stats') do |m|
    m.defMetric('min',:double)
    m.defMetric('avg',:double)
    m.defMetric('max',:double)
    m.defMetric('mdev',:double)
    m.defMetric('rtt_unit',:string)
  end
end

defGroup('First_Peer', property.resource1) do |g|
  g.net.e1.ip = "192.168.1.2/24"
  g.addApplication("ping") do |app|
    app.setProperty('target', '192.168.1.3')
    app.setProperty('count', 10)
    app.measure('ping', :samples => 1)
    app.measure('rtt_stats', :samples => 1)
  end
end
 
defGroup('Second_Peer', property.resource2) do |g|
  g.net.e1.ip = "192.168.1.3/24"
  g.addApplication("ping") do |app|
    app.setProperty('target', '192.168.1.2')
    app.setProperty('count', 15)
    app.measure('ping', :samples => 1)
    app.measure('rtt_stats', :samples => 1)
  end
end

onEvent(:ALL_UP_AND_INSTALLED) do |event|
  info "This is my first OMF experiment"
  group('First_Peer').startApplications
  after 5.seconds do
    group('Second_Peer').startApplications
  end
  after 30.seconds do
    Experiment.done
  end
end

defGraph 'RTT1' do |g|
  g.ms('ping').select {[ :oml_sender_id, :oml_ts_client, :oml_ts_server, :rtt ]}
  g.caption "Round Trip Time (RTT) reported by each resource"
  g.type 'line_chart3'
  g.mapping :x_axis => :oml_ts_client, :y_axis => :rtt, :group_by => :oml_sender_id
  g.xaxis :legend => 'time [s]'
  g.yaxis :legend => 'RTT [ms]', :ticks => {:format => 's'}
end

defGraph 'RTT2' do |g|
  g.ms('rtt_stats').select {[ :oml_sender_id, :avg ]}
  g.caption "RTT Comparison Between Resources [ms]"
  g.type 'pie_chart2'
  g.mapping :value => :avg, :label => :oml_sender_id
end


