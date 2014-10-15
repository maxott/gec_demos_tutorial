# OEDL Script showing a user-defined event, which is triggered upon a specific 
# change in the state of some resources
#
# - we start with 4 resources, i.e. 2 initial 'workers' and 2 backup ones
# - all workers have a ping application associated to them
# - the 2 initial workers starts their ping applications
# - the experiment monitors the state of all applications running on all workers
# - every 20 seconds, we stop the ping application of one of the initial workers
# - the experiment detects this action and reacts dynamically by starting the 
#   application on one of the backup worker
#
loadOEDL('https://raw.githubusercontent.com/mytestbed/oml4r/master/omf/ping-oml2.rb')

defProperty('res1', "rc1", "1st resource")
defProperty('res2', "rc2", "2nd resource")
defProperty('res3', "rc3", "3rd resource")
defProperty('res4', "rc4", "4th resource")
defProperty('target', "127.0.0.1", "Host to ping")

# This may come from SliceService
resources = [ property.res1, 
              property.res2,
              property.res3,
              property.res4
            ]

group_prefix = "Worker_"
initial_resources = resources[0 ... resources.length / 2]
backup_resources = resources - initial_resources
failed_resources = []

resources.each do |res|
  defGroup(group_prefix + res, res) do |group|
    group.addApplication("ping") do |app|
      app.setProperty('dest_addr', property.target)
      app.measure('ping', samples: 1)
    end
  end
end

defGroup("Initial_Worker", initial_resources.map { |r| group_prefix + r } ) 

defEvent :APP_EXITED do |state|
  triggered = false
  state.each do |resource|
    next if failed_resources.include?(resource.uid)
    if (resource.type == 'application') && (resource.state == 'stopped')
      failed_resources << resource.uid
      triggered = true
    end
  end
  triggered
end

onEvent :APP_EXITED, consume_event: false do
  if res = backup_resources.pop
    group(group_prefix + res).startApplications
  else
    info "----------   No more backup resources are available!"
  end
end

every 20 do
  res = initial_resources.pop
  group(group_prefix + res).stopApplications if res
end

onEvent :ALL_UP_AND_INSTALLED do 
  group('Initial_Worker').startApplications
  after 60 do
    allGroups.stopApplications
    Experiment.done
  end
end

defGraph 'Workers' do |g|
  g.ms('ping').select {[ oml_ts_client.as(:time), :rtt, oml_sender_id.as(:name) ]}
  g.caption "Ping RTT vs Time, for each Workers"
  g.type 'line_chart3'
  g.mapping :x_axis => :time, :y_axis => :rtt, :group_by => :name
  g.xaxis :legend => 'time [s]'
  g.yaxis :legend => 'Ping RTT [ms]', :ticks => {:format => 's'}
end