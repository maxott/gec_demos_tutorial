# OEDL Script showing how to get and use a list of resources previously
# provisioned for the slice context within which this experiment trial is being
# executed.
#
# - we start by getting the list of resources provisioned for our slice
# - we filter that list of resources to only retain the 'node' ones
# - then we randomly pick a few of these nodes
# - finally, we create a new group with these randomly picked nodes and
#    associate a ping app to them
#
loadOEDL('https://raw.githubusercontent.com/mytestbed/oml4r/master/omf/ping-oml2.rb')

defProperty('target', "127.0.0.1", "Host to ping")

# getResources returns an array of resources (previously added to the Slice)
# each element of that array has attributes similar to the following:
# "client_id": "some_id_for_that_node",
# "status": "ready",
# "omf_id": "the_id_by_which_that_node_can_be_used_in_an_OEDL_script",
# "sliver_id": "urn:publicid:IDN+instageni.foo.edu+sliver+1234",
# "ssh_login": {
#   "hostname": "pc1.instageni.foo.edu",
#   "port": "12345"
# },
# "interfaces": {
#   "some_id_for_that_node:if0": {
#     "client_id": "some_id_for_that_node:if0",
#     "sliver_id": "urn:publicid:IDN+instageni.foo.edu+sliver+1234",
#     "mac_address": "01234567890a",
#     "ip": [
#       {
#         "address": "10.10.1.1",
#         "type": "ipv4"
#       }
#     ]
#   }
# },
# "urn": "urn:publicid:IDN+instageni.foo.edu+sliver+1234",
# "type": "node"

available_resources = getResources()
nodes = available_resources.map { |res| res.omf_id if res.type == 'node' }.compact
random_nodes = nodes.sample(2)

info "------ Found #{available_resources.length} available resources"
info "------ Including #{nodes.length} available nodes"
random_nodes.map { |n| info "------ Randomly picked: #{n}" }

defGroup("Random_Workers", random_nodes) do |group|
  group.addApplication("ping") do |app|
    app.setProperty('dest_addr', property.target)
    app.measure('ping', samples: 1)
  end
end

onEvent :ALL_UP_AND_INSTALLED do
  allGroups.startApplications
  after 40 do
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