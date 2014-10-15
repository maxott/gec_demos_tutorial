# OEDL Script showing how to get and use a list of resources previously
# provisioned for the slice context within which this experiment trial is being
# executed.
#
# - we start by getting the list of resources provisioned for our slice
# - then for each resource, we check that it is a 'node' type of resoures
# - if so, we create a new group for that node resources & add a ping app to it
#
loadOEDL('https://raw.githubusercontent.com/mytestbed/oml4r/master/omf/ping-oml2.rb')

defProperty('target', "127.0.0.1", "Host to ping")

# getResources returns an array of resources (previously added to the Slice)
# each element of that array has attrbitues similar to the following:
# "client_id": "some_id_for_that_node",
#     "status": "ready",
#     "omf_id": "the_id_by_which_that_node_can_be_used_in_an_OEDL_script",
#     "sliver_id": "urn:publicid:IDN+instageni.foo.edu+sliver+1234",
#     "ssh_login": {
#       "hostname": "pc1.instageni.foo.edu",
#       "port": "12345"
#     },
#     "interfaces": {
#       "some_id_for_that_node:if0": {
#         "client_id": "some_id_for_that_node:if0",
#         "sliver_id": "urn:publicid:IDN+instageni.foo.edu+sliver+1234",
#         "mac_address": "01234567890a",
#         "ip": [
#           {
#             "address": "10.10.1.1",
#             "type": "ipv4"
#           }
#         ]
#       }
#     },
#     "urn": "urn:publicid:IDN+instageni.foo.edu+sliver+1234",
#     "type": "node"
#
available_resources = getResources()

available_resources.each do |res|
  if res.type == 'node'
    info "Got a new resource from Slice: #{res.omf_id} - #{res.type}"
    defGroup("Worker"+res.omf_id , res.omf_id) do |group|
      group.addApplication("ping") do |app|
        app.setProperty('dest_addr', property.target)
        app.measure('ping', samples: 1)
      end
    end
  end
end

onEvent :ALL_UP_AND_INSTALLED do 
  allGroups.startApplications
  after 20 do
    allGroups.stopApplications
    Experiment.done
  end
end
