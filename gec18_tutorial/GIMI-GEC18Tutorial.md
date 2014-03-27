#GEC18 ExoGENI/GIMI Tutorial#
##Overview:##
The objective of this tutorial is to introduce the GIMI tool set to experimenters who are interested in performing experiments on ExoGENI slices. We will introduce an experiment workflow which experimenters will most likely apply to perform measurements.

After the tutorial, experimenters should be able to:

+ Create a slice on ExoGENI and run an experiment on top of this slice.
+ Orchestrate experiments with OMF:
    + Set up routing on top of topology
    + Verify that topology has been set up correctly
    + Execute an experiment that measures the impact of packet size on throughput by comparing udp output at the sender and udp input at the receiver.
+ Store and retrieve data to/from iRODS
+ Analyze/visualize measurement data with various tools

![GIMI_measure_env.png](http://groups.geni.net/geni/attachment/wiki/GEC17Agenda/GettingStartedWithGENI_III_GIMI/Procedure/GIMI_measure_env.png?format=raw "")

##Tools:##
**LabWiki**
It is a tool used to instrumentize and measure network experiments
The project is available on [GitHub-LabWiki](https://github.com/mytestbed/labwiki)

**Where to get help:**
You can get solution for most of the ExoGENI problems in the [ExoGENI wiki](https://wiki.exogeni.net/doku.php)

In the following we list set of resources which experimenters can make use of to obtain further help if required:

+ Mailing list for GIMI users: geni-gimi-users@googlegroups.com
+ Mailing list for ExoGENI users: geni-orca-users@googlegroups.com

**Resources:**

To get more information on Labwiki, [LabWiki](https://github.com/mytestbed/labwiki)

##Tutorial Instructions##
###Design/Setup###

In this part of the tutorial we give a brief overview on the experiment workflow. GIMI is providing experimenters with a set of tools that will aid them in allocating GENI resources, executing experiments, and performing measurements while these experiments are running. In addition, the GIMI tools will allow experimenters to analyze and visualize measurement data. Finally, a federated set of iRODS servers provides an archival service.
The figure below illustrate what we describe as the experiment workflow. During the tutorial we will walk through the single steps of this workflow with the goal to have experimenters apply this workflow to their own experiments.

###Topology###

The image below illustrates the ExoGENI topology that we will create within the scope of this tutorial. The experiment described above will be executed on the basis of this topology.

In Section 1.Reserving Resources, we will go through the process of setting up and obtaining a slice that represents this topology.

![GIMI_Experiment_Topo.2.png](http://groups.geni.net/geni/attachment/wiki/GEC17Agenda/GettingStartedWithGENI_III_GIMI/Procedure/DesignSetup/GIMI_Experiment_Topo.2.png?format=raw "")

The routing in this topology is set up as follows:

![gec-15-routing.png](http://emmy9.casa.umass.edu/GEC-17/gec-15-routing.png "")

###1. Reserve Resources###

####1.1 Login to the GENI Portal####
[GENI Portal](https://portal.geni.net/)

####1.2 Select Project and Create Slice####
**Create Slice**

Create a slice in the Project GEC18. Give the slice a unique name. Preferably something with your username in it. e.g dbhatlabwiki 

![Portalgec18_5.png](http://groups.geni.net/geni/attachment/wiki/GEC18Agenda/GettingStartedWithGENI_III_GIMI/Procedure/DesignSetup/Portalgec18_5.png?format=raw "")

####1.3 Click on Add Resources and select RSpec####
Select RSpec from drop down list under Add Resources.

![Portalgec18_4.png](http://groups.geni.net/geni/attachment/wiki/GEC18Agenda/GettingStartedWithGENI_III_GIMI/Procedure/DesignSetup/Portalgec18_4.png?format=raw "")

For this tutorial we already have an RSpec created for you. Here, select UHGIMIimage. 
You can also upload your own RSpec. 

![Portalgec18_3.png](http://groups.geni.net/geni/attachment/wiki/GEC18Agenda/GettingStartedWithGENI_III_GIMI/Procedure/DesignSetup/Portalgec18_3.png?format=raw "")

Here you will need to select the ExoGENI racks assigned to you for the tutorial. This assignment is only done so that we can distribute VMs across different ExoGENI racks. Outside of this tutorial, you can use any of the following racks:
**Click on Reserve Resources**

####1.4 Query for resources####

Click on your slice name at the top and click on Resource Status. Once you see a READY on your resources, your slice is ready for experiments. You can refresh the page until you see READY.

**Wait until ready**
![Portal5.png](http://groups.geni.net/geni/attachment/wiki/GEC18Agenda/GettingStartedWithGENI_III_GIMI/Procedure/DesignSetup/Portal5.png?format=raw "")

***iRODs***
###2. Configure iRODs###
The iRODs or Integrated Rule-Oriented Datasystem is a directory structure used to archive all experiment related data such as scripts, manifest RSpecs, experiment results and so on.
Please click on this link to learn more about [iRODs](https://www.irods.org/index.php/IRODS:Data_Grids,_Digital_Libraries,_Persistent_Archives,_and_Real-time_Data_Systems).

####2.1 Create iRODs account####
Login to your GENI Portal account and Click on the Profile tab on the top right corner of the page. Click on Tools.
At the bottom of the page, click on the Create iRODs button. 

![Portal6.png](http://groups.geni.net/geni/attachment/wiki/GEC18Agenda/GettingStartedWithGENI_III_GIMI/Procedure/DesignSetup/Portal6.png?format=raw "")

You will be redirected to another page with your iRODs Environment and also your temporary iRODs account password. 

![Portal7.png](http://groups.geni.net/geni/attachment/wiki/GEC18Agenda/GettingStartedWithGENI_III_GIMI/Procedure/DesignSetup/Portal7.png?format=raw "")

Important: Make sure you record your iRODS password. How to change your password is explained [here](http://groups.geni.net/geni/wiki/HowToUseiRODS).

####2.2 Using iDrop####
[iDrop](https://geni-gimi.renci.org:8443/idrop-web2) is the Web-interface provided for you to view your iRODs directory structure and files. You can view, upload and download files through iDrop. For LabWiki experiments, iDrop will have all your measurement related data and experiment Scripts in your folders.

![idrop1.png](http://groups.geni.net/geni/attachment/wiki/GEC18Agenda/GettingStartedWithGENI_III_GIMI/Procedure/DesignSetup/idrop1.png?format=raw "")

##Execute##
###3. Initial Setup###
####3.1 Starting the OML Server (if needed)####
For this tutorial, you can skip this step. The OML Server is already running on emmy9.casa.umass.edu.
At the [following page](http://groups.geni.net/geni/wiki/GEC17Agenda/GettingStartedWithGENI_III_GIMI/Procedure/Execute/OmlServer) we give the interested experimenter additional information on how they can run their own OML server independent of the one offered by GIMI.

####3.2 Verification of Topology####
After establishing the slice on which the experiment will be executed, the experimenter will be most likely be interested in verifying if the slice has been initiated correctly. In this tutorial, we use an OMF experiment script that executes pings between neighbouring nodes. 

Before executing the experiments, we provide here a brief overview on the 4 experiments and the associated OEDL/OMF scripts that we use to execute these experiments.

**Note**: All the scripts shown here have been prepopulated in your iRODs directory under a folder called /geniRenci/home/<username>/experimentScripts/oidl. You could edit these scripts in LabWiki or [add your own using iDrop](http://groups.geni.net/geni/wiki/GEC18Agenda/GettingStartedWithGENI_III_GIMI/Procedure/Execute/addtoiDrop).


The following figure shows that a total of 12 (between each pair of nodes and in each direction) ping are performed.

![ping.png](http://groups.geni.net/geni/attachment/wiki/GEC17Agenda/GettingStartedWithGENI_III_GIMI/Procedure/Execute/ping.png?format=raw "")

**OEDL Script**

**step1-ping_all.rb**

    defProperty('source1', "nodeA-fivenodeping", "ID of a resource")
    defProperty('source2', "nodeB-fivenodeping", "ID of a resource")
    defProperty('source3', "nodeC-fivenodeping", "ID of a resource")
    defProperty('source4', "nodeD-fivenodeping", "ID of a resource")
    defProperty('source5', "nodeE-fivenodeping", "ID of a resource")
    #defProperty('graph', true, "Display graph or not")
    
    
    defProperty('sinkaddr11', '192.168.1.2', "Ping destination address")
    defProperty('sinkaddr12', '192.168.1.4', "Ping destination address")
    
    defProperty('sinkaddr11', '192.168.6.10', "Ping destination address")
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
    
    defApplication('ping') do |app|
      app.description = 'Simple Definition for the ping-oml2 application'
      # Define the path to the binary executable for this application
      app.binary_path = '/usr/local/bin/ping-oml2'
      # Define the configurable parameters for this application
      # For example if target is set to foo.com and count is set to 2, then the 
      # application will be started with the command line:
      # /usr/bin/ping-oml2 -a foo.com -c 2
      app.defProperty('target', 'Address to ping', '-a', {:type => :string})
      app.defProperty('count', 'Number of times to ping', '-c', {:type => :integer})
      # Define the OML2 measurement point that this application provides.
      # Here we have only one measurement point (MP) named 'ping'. Each measurement
      # sample from this MP will be composed of a 4-tuples (addr,ttl,rtt,rtt_unit)
      app.defMeasurement('ping') do |m|
        m.defMetric('dest_addr',:string)
        m.defMetric('ttl',:uint32)
        m.defMetric('rtt',:double)
        m.defMetric('rtt_unit',:string)
      end
    end
    defGroup('Source1', property.source1) do |node|
      node.addApplication("ping") do |app|
        app.setProperty('target', property.sinkaddr12)
        app.setProperty('count', 30)
        #app.setProperty('interval', 1)
        app.measure('ping', :samples => 1)
      end
    end
    
    
    defGroup('Source2', property.source2) do |node|
      node.addApplication("ping") do |app|
        app.setProperty('target', property.sinkaddr11)
        app.setProperty('count', 30)
        #app.setProperty('interval', 1)
        app.measure('ping', :samples => 1)
      end
      node.addApplication("ping") do |app|
        app.setProperty('target', property.sinkaddr21)
        app.setProperty('count', 30)
        #app.setProperty('interval', 1)
        app.measure('ping', :samples => 1)
      end
    
      node.addApplication("ping") do |app|
        app.setProperty('target', property.sinkaddr22)
        app.setProperty('count', 30)
        #app.setProperty('interval', 1)
        app.measure('ping', :samples => 1)
      end
    
      node.addApplication("ping") do |app|
        app.setProperty('target', property.sinkaddr23)
        app.setProperty('count', 30)
        #app.setProperty('interval', 1)
        app.measure('ping', :samples => 1)
      end
    end
    
    defGroup('Source3', property.source3) do |node|
      node.addApplication("ping") do |app|
        app.setProperty('target', property.sinkaddr31)
        app.setProperty('count', 30)
        #app.setProperty('interval', 1)
        app.measure('ping', :samples => 1)
      end
    
      node.addApplication("ping") do |app|
        app.setProperty('target', property.sinkaddr32)
        app.setProperty('count', 30)
        #app.setProperty('interval', 1)
        app.measure('ping', :samples => 1)
      end
    
      node.addApplication("ping") do |app|
        app.setProperty('target', property.sinkaddr33)
        app.setProperty('count', 30)
        #app.setProperty('interval', 1)
        app.measure('ping', :samples => 1)
      end
    
      node.addApplication("ping") do |app|
        app.setProperty('target', property.sinkaddr34)
        app.setProperty('count', 30)
        #app.setProperty('interval', 1)
        app.measure('ping', :samples => 1)
      end
    end
    
    defGroup('Source4', property.source4) do |node|
      node.addApplication("ping") do |app|
        app.setProperty('target', property.sinkaddr41)
        app.setProperty('count', 30)
        #app.setProperty('interval', 1)
        app.measure('ping', :samples => 1)
      end
    
      node.addApplication("ping") do |app|
        app.setProperty('target', property.sinkaddr42)
        app.setProperty('count', 30)
        #app.setProperty('interval', 1)
        app.measure('ping', :samples => 1)
      end
    end
    
    defGroup('Source5', property.source5) do |node|
      node.addApplication("ping") do |app|
        app.setProperty('target', property.sinkaddr51)
        app.setProperty('count', 30)
        #app.setProperty('interval', 1)
        app.measure('ping', :samples => 1)
      end
    end
    
    
    
    
    #defGroup('Sink1', property.sink1) do |node|
    #end
    
    #defGroup('Sink2', property.sink2) do |node|
    #end
    
    #defGroup('Sink3', property.sink3) do |node|
    #end
    
    #defGroup('Sink4', property.sink4) do |node|
    #end
    
    #defGroup('Sink5', property.sink5) do |node|
    #end
    
    onEvent(:ALL_UP_AND_INSTALLED) do |event|
      info "Starting the ping"
      after 5 do
        allGroups.startApplications
      end
      after 70 do
        info "Stopping the ping"
        allGroups.stopApplications
        Experiment.done
      end
    end
    
    defGraph 'RTT' do |g|
      g.ms('ping').select(:oml_seq, :dest_addr, :rtt) 
      g.caption "RTT of received packets."
      g.type 'line_chart3'
      g.mapping :x_axis => :oml_seq, :y_axis => :rtt, :group_by => :dest_addr
      g.xaxis :legend => 'oml_seq'
      g.yaxis :legend => 'rtt', :ticks => {:format => 's'}
    end
    
####3.3 Setup Routing in Experiment Topology####

In more complex topologies routing has to be set up. In our case, this is achieved with the aid of an [OMF experiment script]. The one we use for this tutorial is shown below.

**OEDL Script**

**step2-routing.rb**

    #defProperty('source1', 'omf.nicta.node11', 'ID of a resource')
    #defProperty('source2', 'omf.nicta.node13', 'ID of a resource')
    #defProperty('target', 'emmy9.casa.umass.edu/expect_wget_script.sh', 'download target1')
    #defProperty('target1', 'emmy9.casa.umass.edu/expect_script.sh', 'download target2')
    
    defGroup('Node1', "nodeA-fivenodetest")
    defGroup('Node2', "nodeB-fivenodetest")
    defGroup('Node3', "nodeC-fivenodetest")
    defGroup('Node4', "nodeD-fivenodetest")
    defGroup('Node5', "nodeE-fivenodetest")
    defGroup('NeucaServices', "nodeB-fivenodetest","nodeC-fivenodetest","nodeD-fivenodetest","nodeE-fivenodetest")
    
    
    onEvent(:ALL_UP) do |event|
      after 1 do
    #  group('All').startApplications
      info 'Changing routing setup'
      
      group('NeucaServices').exec("/usr/sbin/service neuca stop")
    
      group('Node1').exec("/sbin/route add -net 192.168.1.0/24 gw 192.168.4.10")
      group('Node1').exec("/sbin/route add -net 192.168.2.0/24 gw 192.168.4.10")
      group('Node1').exec("/sbin/route add -net 192.168.3.0/24 gw 192.168.5.12")
      group('Node1').exec("/sbin/route add -net 192.168.6.0/24 gw 192.168.5.12")
      group('Node1').exec("echo 1 >  /proc/sys/net/ipv4/ip_forward")
    
      group('Node2').exec("/sbin/route add -net 192.168.3.0/24 gw 192.168.1.13")
      group('Node2').exec("/sbin/route add -net 192.168.5.0/24 gw 192.168.4.11")
      group('Node2').exec("/sbin/route add -net 192.168.6.0/24 gw 192.168.2.12")
      group('Node2').exec("echo 1 >  /proc/sys/net/ipv4/ip_forward")
    
      group('Node3').exec("/sbin/route add -net 192.168.1.0/24 gw 192.168.3.13")
      group('Node3').exec("/sbin/route add -net 192.168.4.0/24 gw 192.168.5.11")
      group('Node3').exec("echo 1 >  /proc/sys/net/ipv4/ip_forward")
    
      group('Node4').exec("/sbin/route add -net 192.168.2.0/24 gw 192.168.3.12")
      group('Node4').exec("/sbin/route add -net 192.168.4.0/24 gw 192.168.1.10")
      group('Node4').exec("/sbin/route add -net 192.168.5.0/24 gw 192.168.3.12")
      group('Node4').exec("/sbin/route add -net 192.168.6.0/24 gw 192.168.3.12")
      group('Node4').exec("echo 1 >  /proc/sys/net/ipv4/ip_forward")
    
      group('Node5').exec("/sbin/route add -net 192.168.2.0/24 gw 192.168.6.12")
      group('Node5').exec("/sbin/route add -net 192.168.1.0/24 gw 192.168.6.12")
      group('Node5').exec("/sbin/route add -net 192.168.3.0/24 gw 192.168.6.12")
      group('Node5').exec("/sbin/route add -net 192.168.4.0/24 gw 192.168.6.12")
      group('Node5').exec("/sbin/route add -net 192.168.5.0/24 gw 192.168.6.12")
    
      info 'Routing setup finished'
      end
    
      after 6 do
      info 'Stopping applications'
      allGroups.stopApplications
      end
      after 7 do
      Experiment.done
      end
    end

This script can be easily adapted if the experimenter wishes to set up the routing between the nodes differently.

####3.4 Verification of Routing####

After establishing the routing, we use an [OMF experiment script] that executes pings between each pair of nodes that contains one hop, to verify the correctness of routing setup.

![GIMIPing_e2e.png](http://groups.geni.net/geni/attachment/wiki/GEC17Agenda/GettingStartedWithGENI_III_GIMI/Procedure/Execute/GIMIPing_e2e.png?format=raw "")

**OEDL Script**

**step3-ping_e2e.rb**

    defProperty('source1', "nodeA-fivenodeping", "ID of a resource")
    defProperty('source2', "nodeB-fivenodeping", "ID of a resource")
    defProperty('source3', "nodeC-fivenodeping", "ID of a resource")
    defProperty('source4', "nodeD-fivenodeping", "ID of a resource")
    defProperty('source5', "nodeE-fivenodeping", "ID of a resource")
    
    
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
    
    defApplication('ping') do |app|
      app.description = 'Simple Definition for the ping-oml2 application'
      # Define the path to the binary executable for this application
      app.binary_path = '/usr/local/bin/ping-oml2'
      # Define the configurable parameters for this application
      # For example if target is set to foo.com and count is set to 2, then the 
      # application will be started with the command line:
      # /usr/bin/ping-oml2 -a foo.com -c 2
      app.defProperty('target', 'Address to ping', '-a', {:type => :string})
      app.defProperty('count', 'Number of times to ping', '-c', {:type => :integer})
      # Define the OML2 measurement point that this application provides.
      # Here we have only one measurement point (MP) named 'ping'. Each measurement
      # sample from this MP will be composed of a 4-tuples (addr,ttl,rtt,rtt_unit)
      app.defMeasurement('ping') do |m|
        m.defMetric('dest_addr',:string)
        m.defMetric('ttl',:uint32)
        m.defMetric('rtt',:double)
        m.defMetric('rtt_unit',:string)
      end
    end
    
    defGroup('Source1', property.source1) do |node|
      node.addApplication("ping") do |app|
          	app.setProperty('target', property.sinkaddr11)
          	app.setProperty('count', 30)
          	#app.setProperty('interval', 1)
         	app.measure('ping', :samples => 1)
          end
          
      node.addApplication("ping") do |app|
        app.setProperty('target', property.sinkaddr12)
        app.setProperty('count', 30)
        #app.setProperty('interval', 1)
        app.measure('ping', :samples => 1)
      end
    
      node.addApplication("ping") do |app|
        app.setProperty('target', property.sinkaddr13)
        app.setProperty('count', 30)
        #app.setProperty('interval', 1)
        app.measure('ping', :samples => 1)
      end
    end
    
    defGroup('Source2', property.source2) do |node|
      node.addApplication("ping") do |app|
        app.setProperty('target', property.sinkaddr21)
        app.setProperty('count', 30)
        #app.setProperty('interval', 1)
        app.measure('ping', :samples => 1)
      end               
    end
    
    defGroup('Source4', property.source4) do |node|
      node.addApplication("ping") do |app|
        app.setProperty('target', property.sinkaddr41)
        app.setProperty('count', 30)
        #app.setProperty('interval', 1)
        app.measure('ping', :samples => 1)
      end
    
      node.addApplication("ping") do |app|
        app.setProperty('target', property.sinkaddr42)
        app.setProperty('count', 30)
        #app.setProperty('interval', 1)
        app.measure('ping', :samples => 1)
      end
    
      node.addApplication("ping") do |app|
        app.setProperty('target', property.sinkaddr43)
        app.setProperty('count', 30)
        #app.setProperty('interval', 1)
        app.measure('ping', :samples => 1)
      end
    end
    
    defGroup('Source5', property.source5) do |node|
      node.addApplication("ping") do |app|
        app.setProperty('target', property.sinkaddr51)
        app.setProperty('count', 30)
        #app.setProperty('interval', 1)
        app.measure('ping', :samples => 1)
      end
    
      node.addApplication("ping") do |app|
        app.setProperty('target', property.sinkaddr52)
        app.setProperty('count', 30)
        #app.setProperty('interval', 1)
        app.measure('ping', :samples => 1)
      end
    
       node.addApplication("ping") do |app|
        app.setProperty('target', property.sinkaddr53)
        app.setProperty('count', 30)
        #app.setProperty('interval', 1)
        app.measure('ping', :samples => 1)
      end
    end
    
    onEvent(:ALL_UP_AND_INSTALLED) do |event|
       info "Starting the ping"
      after 5 do
        allGroups.startApplications
      end
      after 70 do
        info "Stopping the ping"
        allGroups.stopApplications
        Experiment.done
      end
    end
    
    
    defGraph 'RTT' do |g|
      g.ms('ping').select(:oml_seq, :dest_addr, :rtt) 
      g.caption "RTT of received packets."
      g.type 'line_chart3'
      g.mapping :x_axis => :oml_seq, :y_axis => :rtt, :group_by => :dest_addr
      g.xaxis :legend => 'oml_seq'
      g.yaxis :legend => 'rtt', :ticks => {:format => 's'}
    end

####3.5. Running Actual Experiment####

We will use an [OMF experiment script] to execute oml enabled traffic generator and receiver (otg and otr) to simulate network traffic, and use oml enabled nmetrics to measure the system usage (e.g., CUP, memory) and network interface usage on each of the participated ExoGENI nodes.

![otg_nmetrics.png](http://groups.geni.net/geni/attachment/wiki/GEC17Agenda/GettingStartedWithGENI_III_GIMI/Procedure/Execute/otg_nmetrics.png?format=raw "")

The one we use for this tutorial is shown below.

**OEDL Script**

**step4-iperf.rb**

    defProperty('source1', "nodeA-fivenodetest", "ID of a resource")
    defProperty('source2', "nodeB-fivenodetest", "ID of a resource")
    defProperty('source3', "nodeC-fivenodetest", "ID of a resource")
    defProperty('source4', "nodeD-fivenodetest", "ID of a resource")
    defProperty('source5', "nodeE-fivenodetest", "ID of a resource")
    
    
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
    
    defApplication('iperf') do |app| 
      app.description = "Iperf is a traffic generator and bandwidth measurement
    tool. It provides generators producing various forms of packet streams and port
    for sending these packets via various transports, such as TCP and UDP."
      app.binary_path = "/usr/bin/iperf_oml2"
    
      #app.defProperty('interval', 'pause n seconds between periodic bandwidth reports', '-i',
       # :type => :double, :unit => "seconds", :default => '1.')
      app.defProperty('len', 'set length read/write buffer to n (default 8 KB)', '-l',
    		  :type => :integer, :unit => "KiBytes")
      app.defProperty('print_mss', 'print TCP maximum segment size (MTU - TCP/IP header)', '-m',
    		  :type => :boolean)
      app.defProperty('output', 'output the report or error message to this specified file', '-o',
    		  :type => :string)
      app.defProperty('port', 'set server port to listen on/connect to to n (default 5001)', '-p',
    		  :type => :integer)
      app.defProperty('udp', 'use UDP rather than TCP', '-u',
    		  :type => :boolean,
    		  :order => 2)
      app.defProperty('window', 'TCP window size (socket buffer size)', '-w',
    		  :type => :integer, :unit => "Bytes")
      app.defProperty('bind', 'bind to <host>, an interface or multicast address', '-B',
    		  :type => :string)
      app.defProperty('compatibility', 'for use with older versions does not sent extra msgs', '-C',
    		  :type => :boolean)
      app.defProperty('mss', 'set TCP maximum segment size (MTU - 40 bytes)', '-M',
    		  :type => :integer, :unit => "Bytes")
      app.defProperty('nodelay', 'set TCP no delay, disabling Nagle\'s Algorithm', '-N',
    		  :type => :boolean)
      app.defProperty('IPv6Version', 'set the domain to IPv6', '-V',
    		  :type => :boolean)
      app.defProperty('reportexclude', 'exclude C(connection) D(data) M(multicast) S(settings) V(server) reports', '-x',
    		  :type => :string, :unit => "[CDMSV]")
      app.defProperty('reportstyle', 'C or c for CSV report, O or o for OML', '-y',
    		  :type => :string, :unit => "[CcOo]", :default => "o") # Use OML reporting by default
    
      app.defProperty('server', 'run in server mode', '-s',
    		  :type => :boolean)
    
      app.defProperty('bandwidth', 'set target bandwidth to n bits/sec (default 1 Mbit/sec)', '-b',
    		  :type => :string, :unit => "Mbps")
      app.defProperty('client', 'run in client mode, connecting to <host>', '-c',
    		  :type => :string,
    		  :order => 1)
      app.defProperty('dualtest', 'do a bidirectional test simultaneously', '-d',
    		  :type => :boolean)
      app.defProperty('num', 'number of bytes to transmit (instead of -t)', '-n',
    		  :type => :integer, :unit => "Bytes")
      app.defProperty('tradeoff', 'do a bidirectional test individually', '-r',
    		  :type => :boolean)
      app.defProperty('time', 'time in seconds to transmit for (default 10 secs)', '-t',
    		  :type => :integer, :unit => "seconds")
      app.defProperty('fileinput', 'input the data to be transmitted from a file', '-F',
    		  :type => :string)
      app.defProperty('stdin', 'input the data to be transmitted from stdin', '-I',
    		  :type => :boolean)
      app.defProperty('listenport', 'port to recieve bidirectional tests back on', '-L',
    		  :type => :integer)
      app.defProperty('parallel', 'number of parallel client threads to run', '-P',
    		  :type => :integer)
      app.defProperty('ttl', 'time-to-live, for multicast (default 1)', '-T',
    		  :type => :integer,
    		  :default => 1)
      app.defProperty('linux_congestion', 'set TCP congestion control algorithm (Linux only)', '-Z',
    		  :type => :boolean)
    
      app.defMeasurement("application"){ |m|
        m.defMetric('pid', :integer)
        m.defMetric('version', :string)
        m.defMetric('cmdline', :string)
        m.defMetric('starttime_s', :integer)
        m.defMetric('starttime_us', :integer)
      }
    
      app.defMeasurement("settings"){ |m|
        m.defMetric('pid', :integer)
        m.defMetric('server_mode', :integer)
        m.defMetric('bind_address', :string)
        m.defMetric('multicast', :integer)
        m.defMetric('multicast_ttl', :integer)
        m.defMetric('transport_protocol', :integer)
        m.defMetric('window_size', :integer)
        m.defMetric('buffer_size', :integer)
      }
    
      app.defMeasurement("connection"){ |m|
        m.defMetric('pid', :integer)
        m.defMetric('connection_id', :integer)
        m.defMetric('local_address', :string)
        m.defMetric('local_port', :integer)
        m.defMetric('remote_address', :string)
        m.defMetric('remote_port', :integer)
      }
    
      app.defMeasurement("transfer"){ |m|
        m.defMetric('pid', :integer)
        m.defMetric('connection_id', :integer)
        m.defMetric('begin_interval', :double)
        m.defMetric('end_interval', :double)
        m.defMetric('size', :uint64)
      }
    
      app.defMeasurement("losses"){ |m|
        m.defMetric('pid', :integer)
        m.defMetric('connection_id', :integer)
        m.defMetric('begin_interval', :double)
        m.defMetric('end_interval', :double)
        m.defMetric('total_datagrams', :integer)
        m.defMetric('lost_datagrams', :integer)
      }
    
      app.defMeasurement("jitter"){ |m|
        m.defMetric('pid', :integer)
        m.defMetric('connection_id', :integer)
        m.defMetric('begin_interval', :double)
        m.defMetric('end_interval', :double)
        m.defMetric('jitter', :double)
      }
    
      app.defMeasurement("packets"){ |m|
        m.defMetric('pid', :integer)
        m.defMetric('connection_id', :integer)
        m.defMetric('packet_id', :integer)
        m.defMetric('packet_size', :integer)
        m.defMetric('packet_time_s', :integer)
        m.defMetric('packet_time_us', :integer)
        m.defMetric('packet_sent_time_s', :integer)
        m.defMetric('packet_sent_time_us', :integer)
      }
    
    end
    
    
    defGroup('Serverapp', property.source1, property.source2, property.source4, property.source5) do |node|
     node.addApplication("iperf") do |app|
            #app.setProperty('interval', property.setinterval)
            app.setProperty('server',true)
            app.setProperty('port',6001)
            app.measure('transfer', :samples => 1)
        end
    end
    
    
    defGroup('Source1', property.source1) do |node|
        node.addApplication("iperf") do |app|
            #app.setProperty('interval',property.setinterval)
            app.setProperty('client',property.sinkaddr11)
            app.setProperty('time',30)
            app.setProperty('port',6001)
            #app.setProperty('bandwidth',property.setbandwidth)
            app.measure('transfer', :samples => 1)
            app.measure('packets', :samples => 1)
        end
        node.addApplication("iperf") do |app|
            #app.setProperty('interval',property.setinterval)
            app.setProperty('client',property.sinkaddr12)
            app.setProperty('time',30)
            app.setProperty('port',6001)
            #app.setProperty('bandwidth',property.setbandwidth)
            app.measure('transfer', :samples => 1)
            app.measure('packets', :samples => 1)
        end
        node.addApplication("iperf") do |app|
            #app.setProperty('interval',property.setinterval)
            app.setProperty('client',property.sinkaddr13)
            app.setProperty('time',30)
            app.setProperty('port',6001)
            #app.setProperty('bandwidth',property.setbandwidth)
            app.measure('transfer', :samples => 1)
            app.measure('packets', :samples => 1)
        end
    end
    defGroup('Source2', property.source2) do |node|
        node.addApplication("iperf") do |app|
            #app.setProperty('interval',property.setinterval)
            app.setProperty('client',property.sinkaddr21)
            app.setProperty('time',30)
            app.setProperty('port',6001)
            #app.setProperty('bandwidth',property.setbandwidth)
            app.measure('transfer', :samples => 1)
            app.measure('packets', :samples => 1)
        end
    end
    
    defGroup('Source4', property.source4) do |node|
        node.addApplication("iperf") do |app|
            #app.setProperty('interval',property.setinterval)
            app.setProperty('client',property.sinkaddr41)
            app.setProperty('time',30)
            app.setProperty('port',6001)
            #app.setProperty('bandwidth',property.setbandwidth)
            app.measure('transfer', :samples => 1)
            app.measure('packets', :samples => 1)
        end
        node.addApplication("iperf") do |app|
            #app.setProperty('interval',property.setinterval)
            app.setProperty('client',property.sinkaddr42)
            app.setProperty('time',30)
            app.setProperty('port',6001)
            #app.setProperty('bandwidth',property.setbandwidth)
            app.measure('transfer', :samples => 1)
            app.measure('packets', :samples => 1)
        end
        node.addApplication("iperf") do |app|
            #app.setProperty('interval',property.setinterval)
            app.setProperty('client',property.sinkaddr43)
            app.setProperty('time',30)
            app.setProperty('port',6001)
            #app.setProperty('bandwidth',property.setbandwidth)
            app.measure('transfer', :samples => 1)
            app.measure('packets', :samples => 1)
        end
    end
    
    defGroup('Source5', property.source5) do |node|
        node.addApplication("iperf") do |app|
            #app.setProperty('interval',property.setinterval)
            app.setProperty('client',property.sinkaddr51)
            app.setProperty('time',30)
            app.setProperty('port',6001)
            #app.setProperty('bandwidth',property.setbandwidth)
            app.measure('transfer', :samples => 1)
            app.measure('packets', :samples => 1)
        end
         node.addApplication("iperf") do |app|
            #app.setProperty('interval',property.setinterval)
            app.setProperty('client',property.sinkaddr52)
            app.setProperty('time',30)
            app.setProperty('port',6001)
            #app.setProperty('bandwidth',property.setbandwidth)
            app.measure('transfer', :samples => 1)
            app.measure('packets', :samples => 1)
        end
         node.addApplication("iperf") do |app|
            #app.setProperty('interval',property.setinterval)
            app.setProperty('client',property.sinkaddr53)
            app.setProperty('time',30)
            app.setProperty('port',6001)
            #app.setProperty('bandwidth',property.setbandwidth)
            app.measure('transfer', :samples => 1)
            app.measure('packets', :samples => 1)
        end
    end
    
    onEvent(:ALL_UP_AND_INSTALLED) do |event|
       info "Starting the iperf"
       wait 1
        group('Serverapp').startApplications
      wait 3
        group('Source1').startApplications
        group('Source2').startApplications
        group('Source4').startApplications
      wait 120
        info "Stopping the iperf"
        group('Source1').stopApplications
        group('Source2').stopApplications
        group('Source4').stopApplications
      wait 2
        allGroups.stopApplications
        Experiment.done
    end
    
    defGraph 'Received bytes' do |g|
      g.ms('transfer').select {[ oml_ts_client.as(:ts), :size , :connection_id]}
      g.caption "Packet length measurement."
      g.type 'line_chart3'
      g.mapping :x_axis => :ts, :y_axis => :size, :group_by => :connection_id
      g.xaxis :legend => 'time [s]'
      g.yaxis :legend => 'packet size', :ticks => {:format => 's'}
    end

###4. LabWiki###


LabWiki is a tool which provides a user-friendly interface to visualize your experiment. To know more about LabWiki please visit LabWiki 
LabWiki can be used to Plan, Prepare and Run your Experiment. 
After you have successfully been signed in you will be able to see a screen like the one below. 

![Labwiki_1.png](http://groups.geni.net/geni/attachment/wiki/GEC17Agenda/GettingStartedWithGENI_III_GIMI/Procedure/Execute/Labwiki_1.png?format=raw "")

Figure(1)

####4.1 Login using OpenID####

If you are logged in to the GENI Portal you will be logged in to LabWiki automatically when you click Login. 

Otherwise please enter the same username and password you use for the GENI Portal
There is a link to LabWiki now available through the GENI Portal or you can click [here](http://emmy9.casa.umass.edu:4601/) to use LabWiki

![Labwiki_OpenID.png](http://groups.geni.net/geni/attachment/wiki/GEC17Agenda/GettingStartedWithGENI_III_GIMI/Procedure/Execute/Labwiki_OpenID.png?format=raw "")

Figure (2)

Send your information. This allows LabWiki to use the GENI Portal ID to log you in to LabWiki. 

![Labwiki_sendinfo.png](http://groups.geni.net/geni/attachment/wiki/GEC17Agenda/GettingStartedWithGENI_III_GIMI/Procedure/Execute/Labwiki_sendinfo.png?format=raw "")

Figure (3)

####4.2 Plan####

The left column could contain the steps to run the experiment or general information about the experiment. 
These scripts are written using a simple markdown language.

The one we use here is gec15-tutorial.md. This script is already in your iRODs directory. You can upload your own scripts to your iRODs directory at /geniRenci/home/USERNAME/experimentScripts/wiki using iDrop.

    title: "GEC15 GIMI Tutorial"
    
    In this tutorial we describe a series of experiment
    that will allow a user to:
    * Verify that a slice has been set up correct
    * Establish certain routes within the slice
    * Verify that routes have been set up correct
    * Execute a throughput measurement
    
    ## Verification of Topology
    
    After establishing the slice on which the experiment will be executed, the experimenter will be most likely be interested in verifying if the slice has been initiated correctly. In this tutorial, we use an [OMF experiment script] (http://emmy9.casa.umass.edu/GEC15-GIMI-Tutorial/step1-ping_all.rb) that executes pings between neighboring nodes.
    The following figure shows that a total of 12 (between each pair of nodes and in each direction) ping are performed.
    
    ![12 Pings](http://emmy9.casa.umass.edu/GEC15-GIMI-Tutorial/images/ping.png)
    __Figure 1__. 12 pings.
    
    The corresponding experiment script can be found under
    "gec16/step1-ping_all.rb" To run the experiment perform the following:
    
    * Simply type "step1-ping_all.rb" in the search field all the way
    on the top of the "Prepare widget" and select the file
    and the scrip will show up in the prepare widget.
    * Drag the icon on top of the "Prepare" widget to the
    "Execute" widget.
    * Check if all the specified parameters are correct.
    * Start the experiment.
    
    ## Setup Routing in Experiment Topology
    
    In more complex topologies routing has to be set up. In our case, this is achieved with the aid of an [OMF experiment script](http://emmy9.casa.umass.edu/GEC15-GIMI-Tutorial/step2-routing.rb).
    
    The corresponding experiment script can be found under
    "gec16/step2-routing.rb" To run the experiment perform the following:
    
    * Simply type "step2-routing.rb" in the search field all the way
    on the top of the "Prepare widget" and select the file
    and the scrip will show up in the prepare widget.
    * Drag the icon on top of the "Prepare" widget to the
    "Execute" widget.
    * Check if all the specified parameters are correct.
    * Start the experiment.
    
    The step2-routing.rb script can be easily adapted if the experimenter wishes to set up the routing between the nodes differently.
    
    ## Verification of Routing
    
    After establishing the routing, we use an [OMF experiment script](http://emmy9.casa.umass.edu/GEC15-GIMI-Tutorial/step3-ping_e2e.rb) that executes pings between each pair of nodes that contains one hop, to verify the correctness of routing setup.
    
    ![](_)
    __Figure 2__. Route verification.
    
    The corresponding experiment script can be found under
    "gec16/step3-ping_e2e.rb" To run the experiment perform the following:
    
    * Simply type "step3-ping_e2e.rb" in the search field all the way
    on the top of the "Prepare widget" and select the file
    and the scrip will show up in the prepare widget.
    * Drag the icon on top of the "Prepare" widget to the
    "Execute" widget.
    * Check if all the specified parameters are correct.
    * Start the experiment.
    
    ## Running Actual Experiment
    
    We will use an [OMF experiment script](http://emmy9.casa.umass.edu/GEC15-GIMI-Tutorial/step4-otg_nmetrics.rb) to execute oml enabled traffic generator and receiver (otg and otr) to simulate network traffic, and use oml enabled nmetrics to measure the system usage (e.g., CPU, memory) and network interface usage on each of the participated ExoGENI nodes.
    
    ![](_)
    __Figure 3__. Actual experiment.
    
    The corresponding experiment script can be found under
    "gec16/step4-otg_nmetrics.rb" To run the experiment perform the following:
    
    * Simply type "step4-otg_nmetrics.rb" in the search field all the way
    on the top of the "Prepare widget" and select the file
    and the scrip will show up in the prepare widget.
    * Drag the icon on top of the "Prepare" widget to the
    "Execute" widget.
    * Check if all the specified parameters are correct.
    * Start the experiment.

![Labwiki_2.png](http://groups.geni.net/geni/attachment/wiki/GEC17Agenda/GettingStartedWithGENI_III_GIMI/Procedure/Execute/Labwiki_2.png?format=raw "")

Figure (4)

####4.3 Prepare####

In the Prepare column, you can select the experiment that you want to execute. In this column you will also be able to edit your experiment script.

![Labwiki_4.png](http://groups.geni.net/geni/attachment/wiki/GEC17Agenda/GettingStartedWithGENI_III_GIMI/Procedure/Execute/Labwiki_4.png?format=raw "")

Figure (5)

After editing, click on the icon at the top-left of the column to save your script. 

Next, click and drag the icon at the top left corner over to the right column Execute. 

####4.4 Execute####

Here, you can start your experiment and visualise it. In the name tab, type in the name you wish to give the experiment. Your name should only consist of alphanumeric characters. Only '_' is allowed as a special character.

####4.4.1 Add a Context####

If you do not want to create a new context, skip this step. 

At the top-right corner there is a button called 'Add Context'. This allows you to create an Experiment context which can be useful when you want to store related experiments in the same folder with associated metadata. This Context can then be browsed using the iRODs web interface. Comment: In GIMI language Context is used to group together measurement data and metadata that belong to one experiment. 

Give the context a name, as shown below and click on 'Save': 

![Labwiki_15.png](http://groups.geni.net/geni/attachment/wiki/GEC17Agenda/GettingStartedWithGENI_III_GIMI/Procedure/Execute/Labwiki_15.png?format=raw "")

Figure (6)

####4.4.2 Run Experiment####

Give your task a name. Select the Project, Experiment Context and Slice from the drop down menu on the screen.

Then scroll towards the bottom of this column and under the tab named Graph, type 'true'.This enables the graph view on your execute column.
Once the experiment starts running you will be able to scroll down and view the graph.

![Labwiki_16.png](http://groups.geni.net/geni/attachment/wiki/GEC17Agenda/GettingStartedWithGENI_III_GIMI/Procedure/Execute/Labwiki_16.png?format=raw "")

Figure (7)

Click on 'Start Experiment' at the bottom of the screen.

![Labwiki_19.png](http://groups.geni.net/geni/attachment/wiki/GEC17Agenda/GettingStartedWithGENI_III_GIMI/Procedure/Execute/Labwiki_19.png?format=raw "")

Figure (8)

After a couple of seconds, you can see the graph at the bottom of the screen.
You can click and drag it to the Plan screen just above Figure 1. This will display the graph along with the experiment description. This graph is also dynamic.

This allows you to add any comments or details about the experiment results.
Similarly, Experiments 2,3 and 4 can be run using the same procedure. Experiment 2 does not have a graph.

At any point during the run of your experiment or at the end of your experiment, click on Dump at the top of the Execute column to save your experiment data in iRODs.

Each time you click on Dump a new .sql file will be created in your measurementData folder in iRODs.

![Labwiki_12.png](http://groups.geni.net/geni/attachment/wiki/GEC17Agenda/GettingStartedWithGENI_III_GIMI/Procedure/Execute/Labwiki_12.png?format=raw "")

Figure(9)

Once you have your slice up and running you can visualize any experiment using LabWiki.

####4.4.3 View results in iDrop####

Any measurement related data will be stored on iRODs under the folder named with your experiment context. You can use iDrop to download your measurement data in .sql format.

![idrop2.png](http://groups.geni.net/geni/attachment/wiki/GEC18Agenda/GettingStartedWithGENI_III_GIMI/Procedure/Execute/idrop2.png?format=raw "")

As you can see on the right pane at the top, there is a button that says "Download". Browse to the desired project, Experiment Context and click on this to save your measurement data to your local system.

Click [here](http://wimax.orbit-lab.org/wiki/WiMAX/GIMIUse#Viewandanalyzeresults) to learn how to plot your data directly from iRODs.

##Finish##

###6. Delete Slice###

Once you are finished with your experiment, you could make them available to other experimenters by deleting your resources.

This can be done from teh GENI Portal page or through Omni.

Delete your resources as shown:

![Portal8.png](http://groups.geni.net/geni/attachment/wiki/GEC18Agenda/GettingStartedWithGENI_III_GIMI/Procedure/Finish/Portal8.png?format=raw "")
