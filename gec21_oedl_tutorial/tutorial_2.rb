# OEDL Script showing a user-defined event, which is triggered upon an  
# experiment-generated measurements reaching a specific value
#
# - we have only 1 resources, which is running a sine signal generator at 2s period
# - the experiment monitors the sine values from that generator every 1s
# - when the experiment detects that the last sine value is above an arbitrary 
#   threshold of 0.9, then it instruct the resource to send one ICMP ping packet
#   to a target host.
# - both measurements from the sine generator and the ping packets are then showed
#   on 2 plots, where we should see that a new ping RTT value appears only when
#   the sine value has peaked above 0.9
#
loadOEDL('https://raw.githubusercontent.com/mytestbed/oml4r/master/omf/signalgen.rb')
loadOEDL('https://raw.githubusercontent.com/mytestbed/oml4r/master/omf/ping-oml2.rb')

defProperty('res1', "test1", "ID of a node")
defProperty('target', "127.0.0.1", "Host to ping")
peak_list = []

defGroup('Generator', property.res1) do |group|
  group.addApplication("signalgen") do |app|
    app.setProperty('frequency', 0.5)
    app.measure('sin', samples: 1)
  end
end

defGroup('Pinger', property.res1) do |group|
  group.addApplication("ping") do |app|
    app.setProperty('dest_addr', property.target)
    app.setProperty('count', 1)
    app.measure('ping', samples: 1)
  end
end

# Note: remember that sampling frequency > 2 * frequency of observed phenomenon
defEvent(:CHECK_MEASUREMENT, every: 1) do

  # Query for some measurements...
  # returns an array where each element is a hash representing a row from the DB
  data = ms('sin').select { [ :oml_ts_client, :value ] }

  # Alternatively the above line could also be:
  # data = defQuery('select oml_ts_client, value from signalgen_sin')
  #
  # Also if you want to rename 'oml_ts_client' to 'ts'
  # data = ms('sin').select { [ oml_ts_client.as(:ts), :value ] } 
  # data = defQuery('select oml_ts_client as ts, value from signalgen_sin')

  triggered = false
  if !data.nil? && !(last_row = data.pop).nil?
    next if peak_list.include?(last_row[:oml_ts_client])
    if last_row[:value] > 0.90
      peak_list << last_row[:oml_ts_client] # record that sample, so we dont trigger on it again
      triggered = true
    end
  end
  triggered
end

onEvent(:CHECK_MEASUREMENT, consume_event = false) do
  info "TEST - TRIGGERED - #{Time.now}"
  group('Pinger').startApplications
end

onEvent(:ALL_UP_AND_INSTALLED) do 
  info "Starting a remote signal generator"
  group('Generator').startApplications
  info "All my Applications are started now..."

  after 40 do
    group('Generator').stopApplications
    info "All my Applications are stopped now."
    Experiment.done
  end
end

defGraph 'Sine' do |g|
  g.ms('sin').select {[ oml_ts_client.as(:ts), :value ]}
  g.caption "Generated Sine Signal"
  g.type 'line_chart3'
  g.mapping :x_axis => :ts, :y_axis => :value
  g.xaxis :legend => 'time [s]'
  g.yaxis :legend => 'Sine Signal', :ticks => {:format => 's'}
end

defGraph 'Ping' do |g|
  g.ms('ping').select {[ oml_ts_client.as(:ts), :rtt ]}
  g.caption "Ping only when Sine > 0.9"
  g.type 'line_chart3'
  g.mapping :x_axis => :ts, :y_axis => :rtt
  g.xaxis :legend => 'time [s]'
  g.yaxis :legend => 'Ping RTT [ms]', :ticks => {:format => 's'}
end

