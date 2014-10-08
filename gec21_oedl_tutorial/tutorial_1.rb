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

defProperty('target', "127.0.0.1", "Host to ping")

number_of_resources = "4"
resource_set_index = *("1"..number_of_resources)
initial_set_index = resource_set_index.take(resource_set_index.length/2)
backup_set_index = resource_set_index - initial_set_index
failed_resources = []
worker_prefix = "Worker"
resource_prefix = "rc"

resource_set_index.each do |index|
  defGroup(worker_prefix+index, resource_prefix+index) do |group|
    group.addApplication("ping") do |app|
      app.setProperty('dest_addr', property.target)
      app.measure('ping', samples: 1)
    end
  end
end

defGroup("Production_Worker", initial_set_index.map { |i| worker_prefix+i } ) 

defEvent :APP_EXITED do |state|
  exited = false
  state.each do |resource|
    next if failed_resources.include?(resource.uid)
    if (resource.type == 'application') && (resource.state == 'stopped')
      failed_resources << resource.uid
      exited = true
    end
  end
  exited
end

onEvent :APP_EXITED, consume_event = false do
  backup_index = backup_set_index.pop
  if backup_index.nil?
    info "----------   No more backup resources are available!"
  else
    group(worker_prefix+backup_index).startApplications
  end
end

every 20 do
  i = initial_set_index.pop
  group(worker_prefix+i).stopApplications unless i.nil?
end

onEvent :ALL_UP_AND_INSTALLED do 
  group('Production_Worker').startApplications
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