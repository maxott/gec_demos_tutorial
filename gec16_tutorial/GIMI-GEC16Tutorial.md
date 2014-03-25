#GEC16: Basic Tutorial/Experiment with GIMI v1.2 I&M Tools: Instructions#

###Tutorial Overview###
+ This tutorial will show how to reserve resources with Flukes tool, implement basic experiments on ExoGENI testbed via OML/OMF, analyze and visualize measurement results, and store and retrieve data to/from iRODS.
+ In this tutorial, Users are expected to get familiar with GIMI tools and command line based OML/OMF, in order to submit experiment scripts, run experiments, and get visualized results.
+ As GIMI I&M service example, users will get the experience of setting up a specific topology, add routing on top of that topology and measure the network performance based on UDP packet size.

####Introduction####
#####GIMI Configuration#####
![gec15-Configuration.png](/home/cong/Dropbox/SHARED/GENI/GEC/gec15-Configuration.png "Configuration")

#####Workflow#####
In this part of the tutorial we give a brief overview on the experiment workflow. GIMI is providing experimenters with a set of tools that will aid them in allocating GENI resources (currently this is limited to ExoGENI resources), executing experiments, and performing measurements while these experiments are running. In addition, the GIMI tools will allow experimenters to analyze and visualize measurement data. Finally, a federated set of iRODS servers provides an archival service.

#####Topology#####
The image below illustrates the ExoGENI topology that we will create within the scope of this tutorial. The experiment described above will be executed on the basis of this topology. Note, that NodeC is running in a different physical location (BBN) than the other nodes (RENCI). In Section [Obtain Slice], we will go through the process of setting up and obtaining a slice that represents this topology.

![gec-15-topology.jpg](/home/cong/Dropbox/SHARED/GENI/GEC/gec-15-topology.jpg "topo")

The routing in this topology is set up as follows:

![gec-15-routing.png](/home/cong/Dropbox/SHARED/GENI/GEC/gec-15-routing.png "routing")

#####Help#####

You can get solution for most of the ExoGNI problems in the [ExoGENI wiki](https://wiki.exogeni.net/doku.php)

In the following we list set of resources which experimenters can make use of to obtain further help if required:
+ Mailing list for GIMI users: geni-gimi-users@googlegroups.com
+ Mailing list for ExoGENI users: geni-orca-users@googlegroups.com

##A. Establish Environment##
###A.1 Establish experiment managment (user workspace) service###
+ Bring up tutorial VM and log in.
User: geniuser, PW: gec15user (ATTENTION account and PW for VirtualBox? are different from those for GENI credentials. The latter will be handed out to you at the beginning of the tutorial!)
+ Open Firefox web browser
+ Open a terminal window
+ The software required for this tutorial is already installed in the tutorial VM.
+ Download GIMI tutorial specific configuration files by issuing the following command in a terminal window:

*It is important that you replace gimiXX with your actual user account (e.g., gimi01).*

    $ wget emmy9.casa.umass.edu/GEC16-GIMI-Tutorial/gec16-wget.sh
    $ sh wget_gec15.sh
    
###A.2 Copy and paste in user workspace###
It might be helpful to use shortcuts in the user workspace VM:

Firefox/Flukes:     Cut = Ctrl-X     Copy = Ctrl-C     Paste = Ctrl-V

Terminal:     Cut = Shift+Ctrl-X     Copy = Shift + Ctrl-C     Paste = Shift + Ctrl-V

###A.3 Gather necessary keys, certificates and credentials###
Since credentials are required for the different tools used within GIMI these have to be set up first. For this tutorial 30 GENI accounts were created (gimi01-gimi30). At the beginning of the tutorial you'll have received your personal account information for the day on a piece of actual paper! It is IMPORTANT that you always use the account name exactly as specified. E.g, always use gimi01 and NOT gimi1!!

To configure your credential in the user workspace VM execute the following command in the terminal:

    $ credconfig.sh -g ~/Tutorials/GIMI/gimiXX/ssh/gimiXX.pem  -f ~/Tutorials/GIMI/gimiXX/ssh/gimiXX.jks -i ~/Tutorials/GIMI/gimiXX/gimiXXIrodsEnv
    
Where gimiXX has to be replaced by your actual user name. For the case of username gimi16 the command would look as follows:

    $ credconfig.sh -g ~/Tutorials/GIMI/gimi16/ssh/gimi16.pem  -f ~/Tutorials/GIMI/gimi16/ssh/gimi16.jks -i ~/Tutorials/GIMI/gimi16/gimi16IrodsEnv
    
The gimiXX account will not stay active after the end of the tutorial. In case you are interested in further using GIMI tools (and we sure hope you are), here how you can use the script to configure the user workspace with your own, personal GENI credentials:

+ credconfig.sh -g ~/mypgenicert.pem -f ~/mypgeni.jks -i ~/myirodsEnv

[Here](http://groups.geni.net/geni/wiki/GENIUserWorkspace/ConfigCredentials) you can find more detailed information on the credential management and configuration.

And here we list the steps the script actually performs:

1. Installs the GENI certificate in $HOME/.ssl
2. Creates an SSH key pair based on the private key in the GENI certificate and installs the pair in $HOME/.ssh/geni_key and $HOME/.ssh/geni_key.pub
3. Creates omni_config to point to the certificate and key pair.
4. Configures .flukes.properties with the appropriate keystore and key pair.
5. Configures .irods/.irodsEnv with the appropriate username and server information
6. Runs ssh-add to add the geni_key private key to the ssh agent for password-less login to the nodes.

###A.4 Verify availability of desired aggregates###
In this section, we provide some basic information about how an experimenter can determine what services are actually active and which ones are down. We would like to emphasize that first and foremost experimenters should join the mailing lists mentioned in Section 5 of the Introduction. Service or infrastructure outage should usually reported on these lists. In some cases you can perform some basic investigations yourself.

+ ExoGENI:: Check mailing list: geni-orca-users@googlegroups.com
+ XMPP server: Just check if this [link](http://emmy9.casa.umass.edu:9090/login.jsp?url=%2Findex.jsp) works.
+ OML server: The OML server is running on port 3003 on emmy9.casa.umass.edu. A simple test if a service is running on this port can be performed with the following command:

        $ nc -zv -w 10 emmy9.casa.umass.edu 3003
        
+ iRODS: A simple 'ils' at the command line will indicate potential problems with iRODS.

###A.5 Verify availability of desired software images/packages###
The following software packages and scripts required for this tutorial are already installed on the VM:
+ OMF EC, RC, AM (version 5.4)
+ OML server, iperf, nmetrics (version 2.8)
+ OMF web (version 5.4)
+ R (version 2.15.1)
+ iRODS client (version 3.1)
+ ExoGENI Software:
    + Link to Flukes on the desktop
    + .flukes.properties in /home/geniuser

Any further software packages that might be required for other experiments have to be installed by the experimenter.

###A.6 Verify availability of necessary operational services, and access to those services###

+ IRODS: To test if the iRODS client can connect to the iRODS server simply execute the following command:

        $ ils
        
As a result the content of our iRODS home directory should be listed:

    /geniRenci/home/gimi30:
      test.2
      
In part E of the tutorial, we introduce the iRODS web portal, which offers an alternative way of verifying if the iRODS service is up and running.

##B. Obtain Slice##

###B.1 Select target aggregates###

In this tutorial, we focus on ExoGENI and do not select any additional aggregates. In future tutorials we will present how GIMI can support experiments on other aggregates and a combination of aggregates (e.g., ExoGENI and WiMAX).

###B.2 Formulate slice topology for experiment, and build request rspec###

We will not go into any detail on this topic since this is covered in the [ExoGENI tutorial](http://groups.geni.net/geni/wiki/GEC15Agenda/ExoGENITutorial).

###B.2 Acquire resources and load images/packages for I&M tools and experiment services###

####B.2.1 Flukes####

B.2.1.1 Register slice and node names (create Pubsub nodes):

The RCs and the EC communicate via an XMPP server. The GIMI XMPP is running on emmy9.casa.umass.edu.

The ExoGENI instances and the experiment slice should be registered with the XMPP server. You can achieve this using the OMF AM by issuing the following command from a terminal in the user workspace. In the following command, please change "gimiXX" to the user name provided to you.

    $ omf_create_psnode-5.4 "XMPP Server" mkslice "slice_name" "list_of_nodenames"
    
    E.g., omf_create_psnode-5.4 emmy9.casa.umass.edu mkslice gimiXX nodeA nodeB nodeC nodeD nodeE
    
If this succeeds you should see an output similar to the one below

    $ omf_create_psnode-5.4 emmy9.casa.umass.edu mkslice gimi28 nodeA nodeB nodeC nodeD nodeE
    DEBUG: Try to connect to Pubsub Gateway 'emmy9.casa.umass.edu'...
    DEBUG: Try to connect to Pubsub Gateway 'emmy9.casa.umass.edu:5222'...
    DEBUG: Connected as 'aggmgr@emmy9.casa.umass.edu' to XMPP server: 'emmy9.casa.umass.edu'
    Connected to PubSub Server: 'emmy9.casa.umass.edu'
    
You only need to create pubsub node once for each new slice name.

B.2.1.2 Before experimenters can use Flukes, its properties file has to be modified.

*The steps described in Section B.2.1.3 do NOT have to be executed during the tutorial!! We are describing them in case you should have to change the credential configuration in .flukes.properties manually!*

Open the properties file with your favorite text editor (e.g., nano):

    $ nano ~/.flukes.properties
    
Then change the file as indicated below.

    # Do not change these
    orca.xmlrpc.url=https://geni.renci.org:11443/orca/xmlrpc
    ssh.options=-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -X
    xterm.path=/usr/bin/xterm
    
    
    image1.name=gec15-gimi-image
    image1.url=http://emmy9.casa.umass.edu/GEC15-GIMI-Tutorial/gec-15-tutorial.xml
    image1.hash=c866eb5423b30cd22a766ee6d1ffba744987a647
    
    image2.name=deb6-2g-zfilesystem 
    image2.url=http://geni-images.renci.org/images/standard/debian/debian-squeeze-amd64-neuca-2g.zfilesystem.sparse.xml
    image2.hash=6a8a8466aef43774bf2e309af47ce876ba793f36
    
    image3.name=gec15-nicta-1
    image3.url=http://pkg.mytestbed.net/geni/gec15-nicta-1.xml
    image3.hash=51838b0d77fcf8840624bdc150ac51331f84a524
    
    user.keystore=/home/geni/.ssl/gimi30.jks
    ssh.key=/home/geni/.ssh/geni_key
    ssh.pubkey=/home/geni/.ssh/geni_key.pub
    
The following [video](http://emmy9.casa.umass.edu/GEC15-GIMI-Tutorial/videos/Flukes_properties.mp4) gives more details on the necessary changes of the file.

B.2.1.3 In the tutorial VM start Flukes and load gimiXX.rdf. (Also here, replace gimiXX with your assigned user ID.) In Flukes select Files->Open Request->select gimiXX.rdf in ~/Tutorials/GIMI/gimiXX.

B.2.1.4 Verify settings and create slice.

+ First select the the Request View tab.
+ To verify settings, right-click on each node and select Edit Properties, inspect, and close if everything looks right. In case you detect an error (which we don't expect for the tutorial) you can fix it here and then save a new version of the RDF file by clicking on File from the top menu in Flukes and selecting Save Request.
+ To create a slice enter your slice name gimiXX in to the empty field next to the Submit Request button and the click the latter.
+ When you are prompted for login please enter the following data: Key alias: gimiXX Password: The one that has been handed out to you.

B.2.1.5 To check if all the resources have come up, go to the Manifest View tab and enter your slice name (gimiXX) into the empty field. Then click Query for Manifest. After a short moment a box with all the requested resources and their respective status will appear. (This box does not update automatically and you have to hit the Query for Manifest button again to receive and update).

B.2.1.6 GIMI specific post boot script. Each node uses the same image but runs a slightly different post boot script. The latter allows for individualized settings at each node. This script is already part of the gimiXX.rdf file. An example post boot script for NodeA is shown below:

B.2.1.5 To check if all the resources have come up, go to the Manifest View tab and enter your slice name (gimiXX) into the empty field. Then click Query for Manifest. After a short moment a box with all the requested resources and their respective status will appear. (This box does not update automatically and you have to hit the Query for Manifest button again to receive and update).

B.2.1.6 GIMI specific post boot script. Each node uses the same image but runs a slightly different post boot script. The latter allows for individualized settings at each node. This script is already part of the gimiXX.rdf file. An example post boot script for NodeA is shown below:

    #!/bin/bash
    
    # Experiment slice name used by OMF. Should be unique for each experiment
    sn=gimi30
    
    # For now ExoGENI does not assign the "Name" assigned in Flukes as hostname. This will not be needed in future versions.
    hostname nodeA
    
    curl http://emmy9.casa.umass.edu/pingWrap.rb -o /root/pingWrap.rb
    chmod +x /root/pingWrap.rb
    
    #Adds the slice name to the resource controller configuration file
    curl http://emmy9.casa.umass.edu/omf-resctl.yaml -o /etc/omf-resctl-5.4/omf-resctl.yaml
    perl -i.bak -pe "s/\:slice\:/\:slice\: $sn/g" /etc/omf-resctl-5.4/omf-resctl.yaml
    
    # The above updates require a restart of the OMF resource controller.
    /etc/init.d/omf-resctl-5.4 restart
    
The following [video](http://emmy9.casa.umass.edu/GEC15-GIMI-Tutorial/videos/Flukes_overview.mp4) gives an overview on how to load an RDF file, request a slice, and verify the creation of a slice with Flukes.

B.2.1.6 Information about the ExoGENI image we use for this tutorial can be found [here](https://wiki.exogeni.net/doku.php?id=public:experimenters:images).

*This section will NOT be covered during the tutorial!! Nevertheless, we describe in Section B.2.2 how you can use Omni to set up and ExoGENI slice should you consider not using Flukes for future experiments.*
 
##C. Orchestrate/Run Experiment##


###C.1 Initial Setup###

####C.1.1 Starting the OML Server (if needed)####

For this tutorial we have an OML server running on emmy9.casa.umass.edu, which collects the measurement data in an sqlite3 database and at the end of the experiment it pushes the data to IRODS.

+ Here is how you would have to start an OML server if you wanted to run this on a different machine (OML2.8 is required.) DO NOT perform this task in the tutorial.
This is explained the [OML installation file].

    $ /usr/bin/oml2-server -l 3003 --logfile=/var/log/oml2-server-2.9.log --user=oml2 --group=oml2 -H /usr/share/oml2-server/oml2-server-hook.sh

The latest version of OML offers the capability of executing a script after the measurement has finished. In OML terminology this is called a "hook". The hook script we use is attached at the bottom of this wiki page (oml2-server-hook.sh).

    #!/bin/bash
    #
    # Example event hook for the OML server, copying an Sqlite database elsewhere
    # when the last client has exited.
    # Copyright 2012-2013 National ICT Australia (NICTA), Australia
    #
    # Permission is hereby granted, free of charge, to any person obtaining a copy
    # of this software and associated documentation files (the "Software"), to deal
    # in the Software without restriction, including without limitation the rights
    # to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    # copies of the Software, and to permit persons to whom the Software is
    # furnished to do so, subject to the following conditions:
    #
    # The above copyright notice and this permission notice shall be included in
    # all copies or substantial portions of the Software.
    #
    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    # FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
    # AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    # LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    # OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    # THE SOFTWARE.
    #
    irodsUserName=rods
    irodsHost=emmy9.casa.umass.edu
    irodsPort=1247
    irodsZone=geniRenci
    HOME=/home/oml2
    export irodsUserName irodsHost irodsPort irodsZone HOME
    
    LOGFILE=/tmp/oml2-server-hook.log
    function log ()
    {
    	echo "$@" >&2
    	echo "$@" >> ${LOGFILE}
    }
    
    # XXX: You might need to initialise the iRODS password for the UNIX user
    # running tho oml2-server by running 'iinit' to create ~/.irods/.irodsA on its
    # behalf for iput to work
    IPUT=/usr/bin/iput
    SQLITE3=sqlite3
    PGDUMP=pg_dump
    
    echo "OML HOOK READY"
    log "OML HOOK READY"
    
    while read COMMAND ARGUMENTS; do
    	# One report line must be printed in each control path;
    	# this first one puts out a timestamp and a dump of the received command, but no newline
    	log -n "`date`: ${COMMAND} ${ARGUMENTS}: "
    	case "${COMMAND}" in
    		"DBCLOSED")
    			case "${ARGUMENTS}" in
    				file:*)
    					DBFILE=${ARGUMENTS/file:/}
    					log "${IPUT} ${OPTION} ${DBFILE}"
    					NAME=${DBFILE:14:6};
    					FILE=${DBFILE:14};
    					LENGTH=${#FILE}
    					SLICE=${FILE:0:$LENGTH-4}
    					DATE=`date`
    					log "b db ${DBFILE} closed, pushing to iRODS..."
    					${IPUT} -f ${DBFILE} /geniRenci/home/$NAME/ #$FILE
    					log "an iRODS operation finished"
    					;;
    				postgresql://*)
    					# Separate the components of the URI by gradually eating them off the TMP variable
    					
    					DOMAIN=${ARGUMENTS//*\//}	# cut everything before the final '/'
    					USERNAME=${DOMAIN/-*/}		# get the first part before the '-'
    					REST=${DOMAIN/$USERNAME-/}	# remove the username from the rest
    					EXPNAME=${REST/-*/}		# same as for the username
    					TIMESTAMP=${REST//*-/}		# get the last part after the '-'
    
    						
    					TMP="${ARGUMENTS/postgresql:\/\//}"
    					USER=${TMP/@*/}
    					TMP=${TMP/${USER}@/}
    					HOST=${TMP/:*/}
    					TMP=${TMP/${HOST}:/}
    					PORT=${TMP/\/*/}
    					TMP=${TMP/${PORT}\//}
    					DBNAME=${TMP}
    					DBFILE=${DBNAME}.`date +%Y-%m-%d_%H:%M:%S%z`.pg.sql
    					log "PostgreSQL DB ${DBNAME} closed, dumping as ${DBFILE} and pushing to iRODS"
    					log "User ${USER} Host ${HOST} Port ${PORT} DBNAME ${DBNAME} Home ${HOME}"
    					${PGDUMP} -U ${USER} -h ${HOST} -p ${PORT} ${DBNAME} > /tmp/${DBFILE}
    					log "Before IPUT"
    					log "${IPUT} -f /tmp/${DBFILE} /geniRenci/home/rods/"
    					log `${IPUT} -V -f /tmp/${DBFILE} /geniRenci/home/rods/ 2>&1`
    					# ${IPUT} -f /tmp/${DBFILE} /geniRenci/home/rods/
    					${IPUT} -f /tmp/${DBFILE} /geniRenci/home/${USERNAME}/experiments/${EXPNAME}-${TIMESTAMP}/measurements.sql
    					log "After IPUT"
    					;;
    				*)
    					log "DB ${ARGUMENTS} closed, but don't know how to handle it"
    					;;
    			esac
    			;;
    		"EXIT")
    			log "Exiting"
    			exit 0
    			;;
    		*)
    			log "Unknown command"
    			;;
    	esac
    done

####C.1.2 Verification of Topology####
After establishing the slice on which the experiment will be executed, the experimenter will be most likely be interested in verifying if the slice has been initiated correctly. In this tutorial, we use an [OMF experiment script](http://emmy9.casa.umass.edu/GEC15-GIMI-Tutorial/step1-ping_all.rb) that executes pings between neighboring nodes. 
The following figure shows that a total of 12 (between each pair of nodes and in each direction) ping are performed.

![gec-15-5-node-ping.png](/home/cong/Dropbox/SHARED/GENI/GEC/gec-15-5-node-ping.png "5-node-ping")

    defProperty('source1', "nodeA", "ID of a resource")
    defProperty('source2', "nodeB", "ID of a resource")
    defProperty('source3', "nodeC", "ID of a resource")
    defProperty('source4', "nodeD", "ID of a resource")
    defProperty('source5', "nodeE", "ID of a resource")
    
    #defProperty('sink1', "nodeA", "ID of a sink")
    #defProperty('sink2', "nodeB", "ID of a sink")
    #defProperty('sink3', "nodeC", "ID of a sink")
    #defProperty('sink4', "nodeD", "ID of a sink")
    #defProperty('sink5', "nodeE", "ID of a sink")
    
    defProperty('sinkaddr11', '192.168.4.10', "Ping destination address")
    defProperty('sinkaddr12', '192.168.5.12', "Ping destination address")
    
    defProperty('sinkaddr21', '192.168.4.11', "Ping destination address")
    defProperty('sinkaddr22', '192.168.2.12', "Ping destination address")
    defProperty('sinkaddr23', '192.168.1.13', "Ping destination address")
    
    defProperty('sinkaddr31', '192.168.5.11', "Ping destination address")
    defProperty('sinkaddr32', '192.168.2.10', "Ping destination address")
    defProperty('sinkaddr33', '192.168.3.13', "Ping destination address")
    defProperty('sinkaddr34', '192.168.6.14', "Ping destination address")
    
    defProperty('sinkaddr41', '192.168.1.10', "Ping destination address")
    defProperty('sinkaddr42', '192.168.3.12', "Ping destination address")
    
    defProperty('sinkaddr51', '192.168.6.12', "Ping destination address")
    
    defApplication('ping_app', 'pingmonitor') do |a|
        a.path = "/root/pingWrap.rb" 
        a.version(1, 2, 0)
        a.shortDescription = "Wrapper around ping" 
        a.description = "ping application"
        a.defProperty('dest_addr', 'Address to ping', '-a', {:type => :string, :dynamic => false})
        a.defProperty('count', 'Number of times to ping', '-c', {:type => :integer, :dynamic => false}) 
        a.defProperty('interval', 'Interval between pings in s', '-i', {:type => :integer, :dynamic => false})
    
        a.defMeasurement('myping') do |m|
         m.defMetric('dest_addr',:string) 
         m.defMetric('ttl',:int)
         m.defMetric('rtt',:float)
         m.defMetric('rtt_unit',:string)
       end
    end
    
    defGroup('Source1', property.source1) do |node|
      node.addApplication("ping_app") do |app|
        app.setProperty('dest_addr', property.sinkaddr11)
        app.setProperty('count', 30)
        app.setProperty('interval', 1)
        app.measure('myping', :samples => 1)
      end
    
      node.addApplication("ping_app") do |app|
        app.setProperty('dest_addr', property.sinkaddr12)
        app.setProperty('count', 30)
        app.setProperty('interval', 1)
        app.measure('myping', :samples => 1)
      end
    end
    
    defGroup('Source2', property.source2) do |node|
      node.addApplication("ping_app") do |app|
        app.setProperty('dest_addr', property.sinkaddr21)
        app.setProperty('count', 30)
        app.setProperty('interval', 1)
        app.measure('myping', :samples => 1)
      end
    
      node.addApplication("ping_app") do |app|
        app.setProperty('dest_addr', property.sinkaddr22)
        app.setProperty('count', 30)
        app.setProperty('interval', 1)
        app.measure('myping', :samples => 1)
      end
    
      node.addApplication("ping_app") do |app|
        app.setProperty('dest_addr', property.sinkaddr23)
        app.setProperty('count', 30)
        app.setProperty('interval', 1)
        app.measure('myping', :samples => 1)
      end
    end
    
    defGroup('Source3', property.source3) do |node|
      node.addApplication("ping_app") do |app|
        app.setProperty('dest_addr', property.sinkaddr31)
        app.setProperty('count', 30)
        app.setProperty('interval', 1)
        app.measure('myping', :samples => 1)
      end
    
      node.addApplication("ping_app") do |app|
        app.setProperty('dest_addr', property.sinkaddr32)
        app.setProperty('count', 30)
        app.setProperty('interval', 1)
        app.measure('myping', :samples => 1)
      end
    
      node.addApplication("ping_app") do |app|
        app.setProperty('dest_addr', property.sinkaddr33)
        app.setProperty('count', 30)
        app.setProperty('interval', 1)
        app.measure('myping', :samples => 1)
      end
    
      node.addApplication("ping_app") do |app|
        app.setProperty('dest_addr', property.sinkaddr34)
        app.setProperty('count', 30)
        app.setProperty('interval', 1)
        app.measure('myping', :samples => 1)
      end
    end
    
    defGroup('Source4', property.source4) do |node|
    
      node.addApplication("ping_app") do |app|
        app.setProperty('dest_addr', property.sinkaddr41)
        app.setProperty('count', 30)
        app.setProperty('interval', 1)
        app.measure('myping', :samples => 1)
      end
    
      node.addApplication("ping_app") do |app|
        app.setProperty('dest_addr', property.sinkaddr42)
        app.setProperty('count', 30)
        app.setProperty('interval', 1)
        app.measure('myping', :samples => 1)
      end
    end
    
    defGroup('Source5', property.source5) do |node|
      node.addApplication("ping_app") do |app|
        app.setProperty('dest_addr', property.sinkaddr51)
        app.setProperty('count', 30)
        app.setProperty('interval', 1)
        app.measure('myping', :samples => 1)
      end
    end
    
    onEvent(:ALL_UP_AND_INSTALLED) do |event|
      info "Starting the ping"
      allGroups.startApplications
      wait 5
      info "Stopping the ping"
      allGroups.stopApplications
      Experiment.done
    end

The script is executed from the user workspace as follows:

    $ cd ~/Tutorials/GIMI/common/
    $ omf-5.4 exec --no-am -e gimiXX-ping_all -S gimiXX step1-ping_all.rb
    
Where gimiXX has to be replaced by the slice name you are using for your experiment.

You should see the following output after executing the omf command.

     INFO NodeHandler: OMF Experiment Controller 5.4 (git e0eefcf)
     INFO NodeHandler: Slice ID: gimi20 
     INFO NodeHandler: Experiment ID: gimi20-2012-10-18t14.03.42-04.00
     INFO NodeHandler: Message authentication is disabled
     WARN NodeHandler: AM support disabled - any service calls will fail!
     INFO Experiment: load system:exp:stdlib
     INFO property.resetDelay: resetDelay = 210 (Fixnum)
     INFO property.resetTries: resetTries = 1 (Fixnum)
     INFO Experiment: load system:exp:eventlib
     INFO Experiment: load ping_all.rb
     INFO property.source1: source1 = "nodeA" (String)
     INFO property.source2: source2 = "nodeB" (String)
     INFO property.source3: source3 = "nodeC" (String)
     INFO property.source4: source4 = "nodeD" (String)
     INFO property.source5: source5 = "nodeE" (String)
     INFO property.sinkaddr11: sinkaddr11 = "192.168.4.10" (String)
     INFO property.sinkaddr12: sinkaddr12 = "192.168.5.12" (String)
     INFO property.sinkaddr21: sinkaddr21 = "192.168.4.11" (String)
     INFO property.sinkaddr22: sinkaddr22 = "192.168.2.12" (String)
     INFO property.sinkaddr23: sinkaddr23 = "192.168.1.13" (String)
     INFO property.sinkaddr31: sinkaddr31 = "192.168.5.11" (String)
     INFO property.sinkaddr32: sinkaddr32 = "192.168.2.10" (String)
     INFO property.sinkaddr33: sinkaddr33 = "192.168.3.13" (String)
     INFO property.sinkaddr34: sinkaddr34 = "192.168.6.14" (String)
     INFO property.sinkaddr41: sinkaddr41 = "192.168.1.10" (String)
     INFO property.sinkaddr42: sinkaddr42 = "192.168.3.12" (String)
     INFO property.sinkaddr51: sinkaddr51 = "192.168.6.12" (String)
     INFO Topology: Loading topology 'nodeA'.
     INFO Topology: Loading topology 'nodeB'.
     INFO Topology: Loading topology 'nodeC'.
     INFO Topology: Loading topology 'nodeD'.
     INFO Topology: Loading topology 'nodeE'.
     INFO Experiment: Switching ON resources which are OFF
     INFO ALL_UP_AND_INSTALLED: Event triggered. Starting the associated tasks.
     INFO exp: Starting the ping
     INFO exp: Request from Experiment Script: Wait for 5s....
     INFO exp: Stopping the ping
     INFO EXPERIMENT_DONE: Event triggered. Starting the associated tasks.
     INFO NodeHandler: 
     INFO NodeHandler: Shutting down experiment, please wait...
     INFO NodeHandler: 
     INFO run: Experiment gimi20-2012-10-18t14.03.42-04.00 finished after 0:16
     
###C.1.3 Setup Routing in Experiment Topology###

In more complex topologies routing has to be set up. In our case, this is achieved with the aid of an [OMF experiment script](http://emmy9.casa.umass.edu/GEC15-GIMI-Tutorial/step2-routing.rb). The one we use for this tutorial is shown below.

    defGroup('Node1', "nodeA")
    defGroup('Node2', "nodeB")
    defGroup('Node3', "nodeC")
    defGroup('Node4', "nodeD")
    defGroup('Node5', "nodeE")
    
    
    onEvent(:ALL_UP) do |event|
      wait 1
      info 'Changing routing setup'
    
      group('Node1').exec("route add -net 192.168.1.0/24 gw 192.168.4.10")
      group('Node1').exec("route add -net 192.168.2.0/24 gw 192.168.4.10")
      group('Node1').exec("route add -net 192.168.3.0/24 gw 192.168.5.12")
      group('Node1').exec("route add -net 192.168.6.0/24 gw 192.168.5.12")
      group('Node1').exec("echo 1 >  /proc/sys/net/ipv4/ip_forward")
    
      group('Node2').exec("route add -net 192.168.3.0/24 gw 192.168.1.13")
      group('Node2').exec("route add -net 192.168.5.0/24 gw 192.168.4.11")
      group('Node2').exec("route add -net 192.168.6.0/24 gw 192.168.2.12")
      group('Node2').exec("echo 1 >  /proc/sys/net/ipv4/ip_forward")
    
      group('Node3').exec("route add -net 192.168.1.0/24 gw 192.168.3.13")
      group('Node3').exec("route add -net 192.168.4.0/24 gw 192.168.5.11")
      group('Node3').exec("echo 1 >  /proc/sys/net/ipv4/ip_forward")
    
      group('Node4').exec("route add -net 192.168.2.0/24 gw 192.168.3.12")
      group('Node4').exec("route add -net 192.168.4.0/24 gw 192.168.1.10")
      group('Node4').exec("route add -net 192.168.5.0/24 gw 192.168.3.12")
      group('Node4').exec("route add -net 192.168.6.0/24 gw 192.168.3.12")
      group('Node4').exec("echo 1 >  /proc/sys/net/ipv4/ip_forward")
    
      group('Node5').exec("route add -net 192.168.2.0/24 gw 192.168.6.12")
      group('Node5').exec("route add -net 192.168.1.0/24 gw 192.168.6.12")
      group('Node5').exec("route add -net 192.168.3.0/24 gw 192.168.6.12")
      group('Node5').exec("route add -net 192.168.4.0/24 gw 192.168.6.12")
      group('Node5').exec("route add -net 192.168.5.0/24 gw 192.168.6.12")
    
      info 'Routing setup finished'
      wait 5
      info 'Stopping applications'
      allGroups.stopApplications
      wait 1
      Experiment.done
    end
    
This script can be easily adapted if the experimenter wishes to set up the routing between the nodes differently.

The script is executed from the user workspace as follows:

    $ cd ~/Tutorials/GIMI/common/
    $ omf-5.4 exec --no-am -e gimiXX-routing -S gimiXX step2-routing.rb
    
Where gimiXX has to be replaced by the slice name you are using for your experiment.

You should see the following output after executing the omf command.

     INFO NodeHandler: OMF Experiment Controller 5.4 (git e0eefcf)
     INFO NodeHandler: Slice ID: gimi20 
     INFO NodeHandler: Experiment ID: gimi20-2012-10-18t14.14.10-04.00
     INFO NodeHandler: Message authentication is disabled
     WARN NodeHandler: AM support disabled - any service calls will fail!
     INFO Experiment: load system:exp:stdlib
     INFO property.resetDelay: resetDelay = 210 (Fixnum)
     INFO property.resetTries: resetTries = 1 (Fixnum)
     INFO Experiment: load system:exp:eventlib
     INFO Experiment: load routing.rb
     INFO Topology: Loading topology 'nodeA'.
     INFO Topology: Loading topology 'nodeB'.
     INFO Topology: Loading topology 'nodeC'.
     INFO Topology: Loading topology 'nodeD'.
     INFO Topology: Loading topology 'nodeE'.
     INFO Experiment: Switching ON resources which are OFF
     INFO ALL_UP: Event triggered. Starting the associated tasks.
     INFO exp: Request from Experiment Script: Wait for 1s....
     INFO exp: Changing routing setup
     INFO exp: Routing setup finished
     INFO exp: Request from Experiment Script: Wait for 5s....
     INFO exp: Stopping applications
     INFO exp: Request from Experiment Script: Wait for 1s....
     INFO EXPERIMENT_DONE: Event triggered. Starting the associated tasks.
     INFO NodeHandler: 
     INFO NodeHandler: Shutting down experiment, please wait...
     INFO NodeHandler: 
     INFO run: Experiment gimi20-2012-10-18t14.14.10-04.00 finished after 0:16
    
###C.1.4 Verification of Routing###

After establishing the routing, we use an [OMF experiment script](http://emmy9.casa.umass.edu/GEC15-GIMI-Tutorial/step3-ping_e2e.rb) that executes pings between each pair of nodes that contains one hop, to verify the correctness of routing setup.

    defProperty('source1', "nodeA", "ID of a resource")
    defProperty('source2', "nodeB", "ID of a resource")
    defProperty('source3', "nodeC", "ID of a resource")
    defProperty('source4', "nodeD", "ID of a resource")
    defProperty('source5', "nodeE", "ID of a resource")
    
    defProperty('sinkaddr11', '192.168.1.13', "Ping destination address")
    defProperty('sinkaddr12', '192.168.3.13', "Ping destination address")
    defProperty('sinkaddr13', '192.168.6.14', "Ping destination address")
    
    defProperty('sinkaddr21', '192.168.6.14', "Ping destination address")
    
    defProperty('sinkaddr41', '192.168.4.11', "Ping destination address")
    defProperty('sinkaddr42', '192.168.5.11', "Ping destination address")
    defProperty('sinkaddr43', '192.168.6.14', "Ping destination address")
    
    defProperty('sinkaddr51', '192.168.5.11', "Ping destination address")
    defProperty('sinkaddr52', '192.168.2.10', "Ping destination address")
    defProperty('sinkaddr53', '192.168.3.13', "Ping destination address")
    
    defApplication('ping_app', 'pingmonitor') do |a|
            a.path = "/root/pingWrap.rb"
            a.version(1, 2, 0)
            a.shortDescription = "Wrapper around ping"
            a.description = "ping application"
            a.defProperty('dest_addr', 'Address to ping', '-a', {:type => :string, :dynamic => false})
            a.defProperty('count', 'Number of times to ping', '-c', {:type => :integer, :dynamic => false})
            a.defProperty('interval', 'Interval between pings in s', '-i', {:type => :integer, :dynamic => false})
            
            a.defMeasurement('myping') do |m|
                m.defMetric('dest_addr',:string)
                m.defMetric('ttl',:int)
                m.defMetric('rtt',:float)
                m.defMetric('rtt_unit',:string)
            end
    end
    
    defGroup('Source1', property.source1) do |node|
          node.addApplication("ping_app") do |app|
              app.setProperty('dest_addr', property.sinkaddr11)
              app.setProperty('count', 30)
              app.setProperty('interval', 1)
              app.measure('myping', :samples => 1)
          end
          
          node.addApplication("ping_app") do |app|
              app.setProperty('dest_addr', property.sinkaddr12)
              app.setProperty('count', 30)
              app.setProperty('interval', 1)
              app.measure('myping', :samples => 1)
          end
    
          node.addApplication("ping_app") do |app|          
              app.setProperty('dest_addr', property.sinkaddr13)
              app.setProperty('count', 30)              
              app.setProperty('interval', 1)                  
              app.measure('myping', :samples => 1)
          end
    end
    
    defGroup('Source2', property.source1) do |node|
        node.addApplication("ping_app") do |app|              
            app.setProperty('dest_addr', property.sinkaddr21)        
            app.setProperty('count', 30)            
            app.setProperty('interval', 1)                
            app.measure('myping', :samples => 1)                  
        end                
    end
    
    defGroup('Source4', property.source3) do |node|
          node.addApplication("ping_app") do |app|
              app.setProperty('dest_addr', property.sinkaddr41)
              app.setProperty('count', 30)
              app.setProperty('interval', 1)
              app.measure('myping', :samples => 1)
          end
    
          node.addApplication("ping_app") do |app|
              app.setProperty('dest_addr', property.sinkaddr42)
              app.setProperty('count', 30)
              app.setProperty('interval', 1)
              app.measure('myping', :samples => 1)
          end
    
          node.addApplication("ping_app") do |app|
              app.setProperty('dest_addr', property.sinkaddr43)
              app.setProperty('count', 30)
              app.setProperty('interval', 1)
              app.measure('myping', :samples => 1)
          end
    end
    
    defGroup('Source5', property.source3) do |node|
              node.addApplication("ping_app") do |app|
                  app.setProperty('dest_addr', property.sinkaddr51)
                  app.setProperty('count', 30)
                  app.setProperty('interval', 1)
                  app.measure('myping', :samples => 1)
              end
    
              node.addApplication("ping_app") do |app|
                  app.setProperty('dest_addr', property.sinkaddr52)
                  app.setProperty('count', 30)
                  app.setProperty('interval', 1)
                  app.measure('myping', :samples => 1)
              end
    
              node.addApplication("ping_app") do |app|
                  app.setProperty('dest_addr', property.sinkaddr53)
                  app.setProperty('count', 30)
                  app.setProperty('interval', 1)
                  app.measure('myping', :samples => 1)
              end
    end
    
    onEvent(:ALL_UP_AND_INSTALLED) do |event|
          info "Starting the ping"
          allGroups.startApplications
          wait 5
          info "Stopping the ping"
          allGroups.stopApplications
          Experiment.done
    end
    
The script is executed from the user workspace as follows:
    
    $ cd ~/Tutorials/GIMI/common/
    $ omf-5.4 exec --no-am -e gimiXX-ping_e2e -S gimiXX step3-ping_e2e.rb
    
Where gimiXX has to be replaced by the slice name you are using for your experiment.

You should see the following output after executing the omf command.

     INFO NodeHandler: OMF Experiment Controller 5.4 (git e0eefcf)
     INFO NodeHandler: Slice ID: gimi20 
     INFO NodeHandler: Experiment ID: gimi20-2012-10-18t14.03.42-04.00
     INFO NodeHandler: Message authentication is disabled
     WARN NodeHandler: AM support disabled - any service calls will fail!
     INFO Experiment: load system:exp:stdlib
     INFO property.resetDelay: resetDelay = 210 (Fixnum)
     INFO property.resetTries: resetTries = 1 (Fixnum)
     INFO Experiment: load system:exp:eventlib
     INFO Experiment: load ping_all.rb
     INFO property.source1: source1 = "nodeA" (String)
     INFO property.source2: source2 = "nodeB" (String)
     INFO property.source3: source3 = "nodeC" (String)
     INFO property.source4: source4 = "nodeD" (String)
     INFO property.source5: source5 = "nodeE" (String)
     INFO property.sinkaddr11: sinkaddr11 = "192.168.4.10" (String)
     INFO property.sinkaddr12: sinkaddr12 = "192.168.5.12" (String)
     INFO property.sinkaddr21: sinkaddr21 = "192.168.4.11" (String)
     INFO property.sinkaddr22: sinkaddr22 = "192.168.2.12" (String)
     INFO property.sinkaddr23: sinkaddr23 = "192.168.1.13" (String)
     INFO property.sinkaddr31: sinkaddr31 = "192.168.5.11" (String)
     INFO property.sinkaddr32: sinkaddr32 = "192.168.2.10" (String)
     INFO property.sinkaddr33: sinkaddr33 = "192.168.3.13" (String)
     INFO property.sinkaddr34: sinkaddr34 = "192.168.6.14" (String)
     INFO property.sinkaddr41: sinkaddr41 = "192.168.1.10" (String)
     INFO property.sinkaddr42: sinkaddr42 = "192.168.3.12" (String)
     INFO property.sinkaddr51: sinkaddr51 = "192.168.6.12" (String)
     INFO Topology: Loading topology 'nodeA'.
     INFO Topology: Loading topology 'nodeB'.
     INFO Topology: Loading topology 'nodeC'.
     INFO Topology: Loading topology 'nodeD'.
     INFO Topology: Loading topology 'nodeE'.
     INFO Experiment: Switching ON resources which are OFF
     INFO ALL_UP_AND_INSTALLED: Event triggered. Starting the associated tasks.
     INFO exp: Starting the ping
     INFO exp: Request from Experiment Script: Wait for 5s....
     INFO exp: Stopping the ping
     INFO EXPERIMENT_DONE: Event triggered. Starting the associated tasks.
     INFO NodeHandler: 
     INFO NodeHandler: Shutting down experiment, please wait...
     INFO NodeHandler: 
     INFO run: Experiment gimi20-2012-10-18t14.03.42-04.00 finished after 0:16
     
###C.2 Running Actual Experiment###

We will use an [OMF experiment script](http://emmy9.casa.umass.edu/GEC15-GIMI-Tutorial/step4-otg_nmetrics.rb) to execute oml enabled traffic generator and receiver (otg and otr) to simulate network traffic, and use oml enabled nmetrics to measure the system usage (e.g., CUP, memory) and network interface usage on each of the participated ExoGENI nodes.

The one we use for this tutorial is shown below.

    defProperty('theSender','nodeB','ID of sender node')
    defProperty('theReceiver1', 'nodeE', "ID of receiver node")
    defProperty('theReceiver2', 'nodeA', "ID of receiver node")
    defProperty('theReceiver3', 'nodeD', "ID of receiver node")
    defProperty('packetsize', 128, "Packet size (byte) from the sender node")
    defProperty('bitrate', 2048, "Bitrate (bit/s) from the sender node")
    defProperty('runtime', 40, "Time in second for the experiment is to run")
    
    defGroup('Sender',property.theSender) do |node|
        options = { 'sample-interval' => 2 }
        node.addPrototype("system_monitor", options)
        node.addApplication("test:app:otg2") do |app|
            app.setProperty('udp:local_host', '192.168.2.10')
            app.setProperty('udp:dst_host', '192.168.6.14')
            app.setProperty('udp:dst_port', 3000)
            app.setProperty('cbr:size', property.packetsize)
            app.setProperty('cbr:rate', property.bitrate * 2)
            app.measure('udp_out', :samples => 1)
        end
        
        node.addApplication("test:app:otg2") do |app|
            app.setProperty('udp:local_host', '192.168.4.10')
            app.setProperty('udp:dst_host', '192.168.4.11')
            app.setProperty('udp:dst_port', 3000)
            app.setProperty('cbr:size', property.packetsize)
            app.setProperty('cbr:rate', property.bitrate * 2)
            app.measure('udp_out', :samples => 1)
        end
        
        node.addApplication("test:app:otg2") do |app|
            app.setProperty('udp:local_host', '192.168.1.10')
            app.setProperty('udp:dst_host', '192.168.1.13')
            app.setProperty('udp:dst_port', 3000)                                    
            app.setProperty('cbr:size', property.packetsize)                                            
            app.setProperty('cbr:rate', property.bitrate * 2)                                                    
            app.measure('udp_out', :samples => 1)                                                        
        end
    end
    
    defGroup('Receiver1',property.theReceiver1) do |node|
        options = { 'sample-interval' => 2 }
        node.addPrototype("system_monitor", options)
    
        node.addApplication("test:app:otr2") do |app|
            app.setProperty('udp:local_host', '192.168.6.14')
            app.setProperty('udp:local_port', 3000)
            app.measure('udp_in', :samples => 1)
        end
    end
    
    defGroup('Receiver2',property.theReceiver2) do |node|
        options = { 'sample-interval' => 2 }
        node.addPrototype("system_monitor", options)
        node.addApplication("test:app:otr2") do |app|
            app.setProperty('udp:local_host', '192.168.4.11')
            app.setProperty('udp:local_port', 3000)
            app.measure('udp_in', :samples => 1)
        end 
    end
    
    defGroup('Receiver3',property.theReceiver3) do |node|     
        options = { 'sample-interval' => 2 }
        node.addPrototype("system_monitor", options)
        node.addApplication("test:app:otr2") do |app|                    
            app.setProperty('udp:local_host', '192.168.1.13')
            app.setProperty('udp:local_port', 3000)                                
            app.measure('udp_in', :samples => 1)                                    
        end
    end
    
    onEvent(:ALL_UP_AND_INSTALLED) do |event|
        info "starting"
        wait 5
        allGroups.exec("ln -s /usr/local/bin/otr2 /usr/bin/otr2")
        allGroups.exec("ln -s /usr/local/bin/otg2 /usr/bin/otg2")
        allGroups.exec("ln -s /usr/local/bin/oml2-nmetrics /usr/bin/oml2-nmetrics")
        allGroups.startApplications
        info "All applications started..."
        wait property.runtime / 4
        property.packetsize = 256
        wait property.runtime / 4
        property.packetsize = 512
        wait property.runtime / 4
        property.packetsize = 1024
        wait property.runtime / 4
        allGroups.stopApplications
        info "All applications stopped." 
        Experiment.done
    end
    
The script is executed from the user workspace as follows:

    $ cd ~/Tutorials/GIMI/common/
    $ omf-5.4 exec --no-am -e gimiXX-otg_nmetrics -S gimiXX step4-otg_nmetrics.rb
    
Where gimiXX has to be replaced by the slice name you are using for your experiment.

You should see the following output (or similar) after executing the omf command.

    INFO NodeHandler: OMF Experiment Controller 5.4 (git e0eefcf)
     INFO NodeHandler: Slice ID: gimi20 
     INFO NodeHandler: Experiment ID: gimi20-2012-10-18t13.51.41-04.00
     INFO NodeHandler: Message authentication is disabled
     WARN NodeHandler: AM support disabled - any service calls will fail!
     INFO Experiment: load system:exp:stdlib
     INFO property.resetDelay: resetDelay = 210 (Fixnum)
     INFO property.resetTries: resetTries = 1 (Fixnum)
     INFO Experiment: load system:exp:eventlib
     INFO Experiment: load otg_nmetrics.rb
     INFO property.theSender: theSender = "nodeB" (String)
     INFO property.theReceiver1: theReceiver1 = "nodeE" (String)
     INFO property.theReceiver2: theReceiver2 = "nodeA" (String)
     INFO property.theReceiver3: theReceiver3 = "nodeD" (String)
     INFO property.packetsize: packetsize = 128 (Fixnum)
     INFO property.bitrate: bitrate = 2048 (Fixnum)
     INFO property.runtime: runtime = 40 (Fixnum)
     INFO Topology: Loading topology 'nodeB'.
     INFO Topology: Loading topology 'nodeE'.
     INFO Topology: Loading topology 'nodeA'.
     INFO Topology: Loading topology 'nodeD'.
     INFO Experiment: Switching ON resources which are OFF
     INFO ALL_UP_AND_INSTALLED: Event triggered. Starting the associated tasks.
     INFO exp: starting
     INFO exp: Request from Experiment Script: Wait for 5s....
     INFO exp: All applications started...
     INFO exp: Request from Experiment Script: Wait for 10s....
     INFO property.packetsize: packetsize = 256 (Fixnum)
     INFO exp: Request from Experiment Script: Wait for 10s....
     INFO property.packetsize: packetsize = 512 (Fixnum)
     INFO exp: Request from Experiment Script: Wait for 10s....
     INFO property.packetsize: packetsize = 1024 (Fixnum)
     INFO exp: Request from Experiment Script: Wait for 10s....
     INFO exp: All applications stopped.
     INFO EXPERIMENT_DONE: Event triggered. Starting the associated tasks.
     INFO NodeHandler: 
     INFO NodeHandler: Shutting down experiment, please wait...
     INFO NodeHandler: 
     INFO run: Experiment gimi20-2012-10-18t13.51.41-04.00 finished after 0:56
     
##D. Observe Results##

###D.1 LabWiki###
Labwiki is a tool which provides a user-friendly interface to visualize your experiment. To know more about LabWiki please visit [LabWiki] (https://github.com/mytestbed/labwiki)

Labwiki can be used to Plan, Prepare and Run your Experiment.
####D.1.1 Plan####
Labwiki accounts have already been created for you for this tutorial. To use Labwiki, go to [GIMI portal](labwiki.casa.umass.edu) and login with the username and password you have been given.

![gec-16-Labwiki_1.png](/home/cong/Dropbox/SHARED/GENI/GEC/gec-16-Labwiki_1.png "")

After you have successfully been signed in you will be able to see a screen like the one below. 

![gec-16-Labwiki_2a.png](/home/cong/Dropbox/SHARED/GENI/GEC/gec-16-Labwiki_2a.png "")

The left column could contain the steps to run the experiment or general information about the experiment.

![gec-16-Labwiki_2.png](/home/cong/Dropbox/SHARED/GENI/GEC/gec-16-Labwiki_2.png "")

####D.1.2 Prepare####
In the Prepare column, you can select the experiment that you want to execute. In this column you will also be able to edit your experiment script.

![gec-16-Labwiki_3.png](/home/cong/Dropbox/SHARED/GENI/GEC/gec-16-Labwiki_3.png "")

After editing, click on the save icon at the top of the column to save your script. 
Next, click and drag the icon at the top left corner over to the right column Execute.

###D.1.3 Execute###
Here, you can start your experiment and Visualise it. In the name tab, type in the name you wish to give the experiment. There are no particular rules for this.
Under slice name, type in the name of your slice as you have entered in the Flukes tool while setting up your slice. 

Then. scroll towards the bottom of this column and under the tab named Graph, type 'true'.This enables the graph view on your execute column.
Once the experiment starts running you will be able to scroll down and view the graph.

![gec-16-Labwiki_4.png](/home/cong/Dropbox/SHARED/GENI/GEC/gec-16-Labwiki_4.png "")

Click on 'Start Experiment' at the bottom of the screen.

![gec-16-Labwiki_5.png](/home/cong/Dropbox/SHARED/GENI/GEC/gec-16-Labwiki_5.png "")

After a couple of seconds, you can see the graph at the bottom of the screen.

![gec-16-Labwiki_6.png](/home/cong/Dropbox/SHARED/GENI/GEC/gec-16-Labwiki_6.png "")

You can click and drag it to the Plan screen just above Figure 12. This will display the graph along with the experiment description. This graph is also dynamic.

![gec-16-Labwiki_7.png](/home/cong/Dropbox/SHARED/GENI/GEC/gec-16-Labwiki_7.png "")

You can click and drag the experiment description to the Prepare column. This allows you to add any comments or details about the experiment results.
Similarly, Experiments 2 and 3 can be run using the same procedure. Experiment 2 does not have a graph.

![gec16-Labwiki_8.png](/home/cong/Dropbox/SHARED/GENI/GEC/gec16-Labwiki_8.png "")

Once you have your slice up and running you can visualize any experiment using LabWiki.

##E. Push to iRODS##
###E.1 Overview###
In GIMI, iRODS is used as the repository for measurement data. At the moment our iRODS data system consist of three servers (RENCI, NICTA, and UMass) and a metadata catalog (located at RENCI).

###E.2 Storing data on iRODS###
After successful completion of an experiment the measurement data from the experiment have been stored in iRODS. We will now look into two options on how this data can be handled.

####E.2.1 iRODS command line tools in the user work space####
+ The GENI User Workspace comes already with the iRODS command line tools installed.
+ If you have not done so far use iinit to create a file that contains your iRODS password in a scrambled form. This will then be used automatically by the icommands for authentication with the server.

        $iinit
     You will be prompted for a password. Please enter the one given on the paper handout.
     
+ The iRODS client uses a configuration file (~/.irods/.irodsEnv) that sets certain parameter for the icommands. Here is and example:

        # iRODS personal configuration file.
        #
        # This file was automatically created during iRODS installation.
        #   Created Thu Feb 16 14:06:27 2012
        #
        # iRODS server host name:
        irodsHost 'emmy9.casa.umass.edu'
        # iRODS server port number:
        irodsPort 1247
        
        # Default storage resource name:
        irodsDefResource 'iRODSUmass2'
        # Home directory in iRODS:
        irodsHome '/geniRenci/home/gimiXX'
        # Current directory in iRODS:
        irodsCwd '/geniRenci/home/gimiXX'
        # Account name:
        irodsUserName 'gimiXX'
        # Zone:
        irodsZone 'geniRenci'
        
+ Retrieve file from your iRODS home directory into user workspace.

        $ iget <file_name>
      Assuming you wanted to retrieve a file called gimitesting.sq3 the command would look as follows:
              
        $ iget gimitesting.sq3
        
+ Store data from user workspace into your iRODS home directory.

        $ imeta add -d <file_name> <name> <value> <unit>
        
    For example if you wanted to add the slice name of the experiment as metadata for file gimi01-ping_all.sq3, the command would look as follows:
    
        $ imeta add -d gimi01-ping_all.sq3 SliceName gimi01
        
    (<unit> is not required.)
    
####E.2.2 iRODS web interface####
iRODS also provides a nice and easy to use web interface, which we will explore in the following.

+ Point the browser in your user workspace to the following link: https://www.irods.org/web/index.php
+ Input the following information to sign in:

        Host/IP: emmy9.casa.umass.edu
        Port: 1247
        Username: as given on printout
        Password: as given on printout
        
###E.3 IRODS and OML###
In GIMI we have enabled an option in OML2.8 that allows the execution of script. We use this functionality to automatically save measurement results in IRODS after a measurement has successfully completed.

###E.4 DISCLAIMER###
The iRODS service we are offering within the scope of GIMI does NOT guarantee 100% reliable data storage (i.e., we do NOT back up the data). If you are performing your own experiments and want to use iRODS you are absolutely welcome but be aware that we do NOT guarantee recovery from data loss.

##F. Analyze##
In Section F we went through the exercise of retrieving data from iRODS to a local computer. In this Section, we will introduce two different methods that can be used to analyze the measurement data. Analysis of measurement data obtained with OMF/OML is not limited to these two methods, we simply use them for demonstration purposes.

###G.1 R Scripts###
One potential way to visualize the data is making use of R, which provides a visualization language. For this tutorial, we have create a set of R scripts, which we briefly discuss in the following.

The first R script creates a plot of the RTTs for each ping that's carried out in the experiment in the initial experiment we ran in the tutorial.

    library(RSQLite)
    con <- dbConnect(dbDriver("SQLite"), dbname = "gimi20-2012-10-18t14.03.42-04.00.sq3")
    dbListTables(con)
    dbReadTable(con,"pingmonitor_myping")
    
    mydata1 <- dbGetQuery(con, "select dest_addr, rtt from pingmonitor_myping where dest_addr='192.168.4.10'")
    rtt1 <- abs(mydata1$rtt)
    
    mydata2 <- dbGetQuery(con, "select dest_addr, rtt from pingmonitor_myping where dest_addr='192.168.5.12'")
    rtt2 <- abs(mydata2$rtt)
    
    mydata3 <- dbGetQuery(con, "select dest_addr, rtt from pingmonitor_myping where dest_addr='192.168.4.11'")
    rtt3 <- abs(mydata3$rtt)
    
    mydata4 <- dbGetQuery(con, "select dest_addr, rtt from pingmonitor_myping where dest_addr='192.168.2.12'")
    rtt4 <- abs(mydata4$rtt)
    
    mydata5 <- dbGetQuery(con, "select dest_addr, rtt from pingmonitor_myping where dest_addr='192.168.1.13'")
    rtt5 <- abs(mydata5$rtt)
    
    mydata6 <- dbGetQuery(con, "select dest_addr, rtt from pingmonitor_myping where dest_addr='192.168.5.11'")
    rtt6 <- abs(mydata6$rtt)
    
    mydata7 <- dbGetQuery(con, "select dest_addr, rtt from pingmonitor_myping where dest_addr='192.168.2.10'")
    rtt7 <- abs(mydata7$rtt)
    
    mydata8 <- dbGetQuery(con, "select dest_addr, rtt from pingmonitor_myping where dest_addr='192.168.3.13'")
    rtt8 <- abs(mydata8$rtt)
    
    mydata9 <- dbGetQuery(con, "select dest_addr, rtt from pingmonitor_myping where dest_addr='192.168.6.14'")
    rtt9 <- abs(mydata9$rtt)
    
    mydata10 <- dbGetQuery(con, "select dest_addr, rtt from pingmonitor_myping where dest_addr='192.168.1.10'")
    rtt10 <- abs(mydata10$rtt)
    
    mydata11 <- dbGetQuery(con, "select dest_addr, rtt from pingmonitor_myping where dest_addr='192.168.3.12'")
    rtt11 <- abs(mydata11$rtt)
    
    mydata12 <- dbGetQuery(con, "select dest_addr, rtt from pingmonitor_myping where dest_addr='192.168.6.12'")
    rtt12 <- abs(mydata12$rtt)
    
    png(filename="gimi20-nmetrics-eth", height=650, width=900,
     bg="white")
    g_range <- range(0,rtt1,rtt2,rtt3,rtt4,rtt5,rtt6,rtt7,rtt8,rtt9,rtt10,rtt11,rtt12)
    
    plot(rtt1,type="o",col="red",ylim= g_range, lty=2, xlab="Experiment Interval",ylab="RTT")
    lines(rtt2,type="o",col="blue",xlab="Experiment Interval",ylab="Received Data")
    lines(rtt3,type="o",col="green",xlab="Experiment Interval",ylab="Received Data")
    lines(rtt4,type="o",col="purple",xlab="Experiment Interval",ylab="Received Data")
    lines(rtt5,type="o",col="violetred",xlab="Experiment Interval",ylab="Received Data")
    lines(rtt6,type="o",col="springgreen",xlab="Experiment Interval",ylab="Received Data")
    lines(rtt7,type="o",col="skyblue",xlab="Experiment Interval",ylab="Received Data")
    lines(rtt8,type="o",col="sienna",xlab="Experiment Interval",ylab="Received Data")
    lines(rtt9,type="o",col="pink",xlab="Experiment Interval",ylab="Received Data")
    lines(rtt10,type="o",col="yellow",xlab="Experiment Interval",ylab="Received Data")
    lines(rtt11,type="o",col="thistle",xlab="Experiment Interval",ylab="Received Data")
    lines(rtt12,type="o",col="orange",xlab="Experiment Interval",ylab="Received Data")
    
    title(main="nmetrics experiment on ExoGENI (Received Data)", col.main="red", font.main=4)
    legend("topright", g_range[4], legend=c("192.168.4.10","192.168.5.12","192.168.4.11","192.168.2.12","192.168.5.11","192.168.2.10","192.168.3.13","192.168.6.14","192.168.1.10","192.168.3.12","192.168.6.12"), cex=0.8,
       col=c("blue","red","green","purple","violetred","springgreen","skyblue","sienna","pink","yellow","thistle","orange"), pch=15:16:17:18:19:20:21:22:23:24:25:26, lty=1:2:3:4:5:6:7:8:9:10:11:12);
    
    dev.off()

The resulting plot is shown below.

![gec16-gimi-ping.png](/home/cong/Dropbox/SHARED/GENI/GEC/gec16-gimi-ping.png "")

The following R script plots otr results from the 4th experiment we executed in Section C.

    library(RSQLite)
    con <- dbConnect(dbDriver("SQLite"), dbname = "gimi20-otg-nmetrics.sq3")
    dbListTables(con)
    dbReadTable(con,"otr2_udp_in")
    
    mydata1 <- dbGetQuery(con, "select oml_sender_id, pkt_length from otr2_udp_in where src_host='192.168.4.10'")
    pkt_length <- mydata1$pkt_length
    #plot(rx_bytes1, type="o", color="red", xlab="Experiment Interval", ylab="Received data")
    
    
    png(filename="gimi20_otg1.png", height=650, width=900,
     bg="white")
    g_range <- range(0,pkt_length)
    
    plot(pkt_length,type="o",col="red",ylim= g_range, lty=2, xlab="Experiment Interval",ylab="Packet Size")
    
    title(main="Received packet size with sender address 192.168.4.10", col.main="red", font.main=4)
    legend("bottomright", g_range[1], legend=c("interface1"), cex=0.8,
       col=c("blue"), pch=21, lty=1);
    
    dev.off()
    
The resulting plot is shown below.

![gec-16-gimi20_otg1.png](/home/cong/Dropbox/SHARED/GENI/GEC/gec-16-gimi20_otg1.png "")

The following script plots part of nmetrics results from the 4th experiment we executed.

    library(RSQLite)
    con <- dbConnect(dbDriver("SQLite"), dbname = "gimi20-otg-nmetrics.sq3")
    dbListTables(con)
    dbReadTable(con,"nmetrics_net_if")
    
    mydata1 <- dbGetQuery(con, "select oml_sender_id, rx_bytes from nmetrics_net_if where oml_sender_id=1")
    rx_bytes1 <- abs(mydata1$rx_bytes)
    #plot(rx_bytes1, type="o", color="red", xlab="Experiment Interval", ylab="Received data")
    
    mydata2 <- dbGetQuery(con, "select oml_sender_id, rx_bytes from nmetrics_net_if where oml_sender_id=2")
    rx_bytes2 <- abs(mydata2$rx_bytes)
    
    mydata3 <- dbGetQuery(con, "select oml_sender_id, rx_bytes from nmetrics_net_if where oml_sender_id=3")
    rx_bytes3 <- abs(mydata3$rx_bytes)
    
    mydata4 <- dbGetQuery(con, "select oml_sender_id, rx_bytes from nmetrics_net_if where oml_sender_id=4")
    rx_bytes4 <- abs(mydata4$rx_bytes)
    
    png(filename="gimi20-nmetrics-eth", height=650, width=900,
     bg="white")
    g_range <- range(0,rx_bytes1,rx_bytes2,rx_bytes3,rx_bytes4)
    
    plot(rx_bytes1,type="o",col="red",ylim= g_range, lty=2, xlab="Experiment Interval",ylab="Received Data")
    lines(rx_bytes2,type="o",col="blue",xlab="Experiment Interval",ylab="Received Data")
    lines(rx_bytes3,type="o",col="green",xlab="Experiment Interval",ylab="Received Data")
    lines(rx_bytes4,type="o",col="purple",xlab="Experiment Interval",ylab="Received Data")
    title(main="nmetrics experiment on ExoGENI (Received Data)", col.main="red", font.main=4)
    legend("bottomright", g_range[4], legend=c("interface1","interface2","interface3","interface4"), cex=0.8,
       col=c("blue","red","green","purple"), pch=21:22:23:24, lty=1:2:3:4);
       
The resulting plot is shown below.

![gec-16gimi20-nmetrics-eth.png](/home/cong/Dropbox/SHARED/GENI/GEC/gec-16gimi20-nmetrics-eth.png "")

All three scripts are simply executed with:

    R -f <script_name>

The benefit of using R scripts is that they can produce graphs that can be used in documents!

The results can then be stored into iRODS using the itools presented in Section E.2.

###H. Clean Up###
####H.1 Delete Slice####
In Flukes select the Manifest View tab enter your slice name (gimiXX) and select Delete slice.