# Experiment 1

## Overview

The objective of this first step is to show how to design, execute, and view the result of a very simple experiment using LabWiki and OEDL.

The scenario of this simple experiment involves 2 computing resources (i.e. ExoGENI virtual machines), which will send ping probes to each other, and report the observed delays.

<img src="https://raw.github.com/mytestbed/gec18-tutorial/master/part1/exp1_overview.png">

As mentioned [earlier](http://groups.geni.net/geni/wiki/GEC18Agenda/LabWikiAndOEDL#Pre-Requisites), the resources for this experiment have already been allocated and provisioned. Thus at this stage, you should have received the names of your allocated resource, if not please let the session presenters know. 

## Part 1 - Design/Setup 

For help on all actions regarding LabWiki, please refer to the [LabWiki and OEDL introduction page](http://groups.geni.net/geni/wiki/GEC18Agenda/LabWikiAndOEDL/Introduction)

**The OEDL experiment description**

1. First, if you have not done it yet, login into LabWiki
2. Create a new experiment file with the name of your choice
3. Cut-and-paste the following OEDL experiment description into that file, then save it

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

       defGraph 'RTT3' do |g|
         g.ms('ping').select {[ :oml_sender_id, :oml_ts_client, :oml_ts_server, :rtt ]}.where("rtt < 1")
         g.caption "Histogram of RTT counts [ms]"
         g.type 'histogram2'
         g.mapping :value => :rtt, :group_by => :oml_sender_id
         g.yaxis :legend => 'Count'
         g.xaxis :legend => ' ', :ticks => {:format => ',.2f'}
       end


**Walk-through the above OEDL experiment description**

1. For more details on each OEDL commands described below, please refer to the [OEDL reference page](http://mytestbed.net/projects/omf6/wiki/OEDLOMF6)

2. **defProperty**. This command is used to define experiment properties (aka variables), you can set the values of these properties as parameters for each experiment instances, and access them throughout the entire experiment run. In this example, we are defining 2 properties, to hold the names of each of the resources that we will use. Its syntax is available [here](http://mytestbed.net/projects/omf6/wiki/OEDLOMF6#defProperty-38-property)

3. **defApplication**. This command declares the details of an application that we would like to use in this experiment. The application may be already installed on the resources or may be deployed as part of the experiment's execution. The information declared via this command are generic attributes of the application (e.g. the path to its binary), the parameters that it accepts (e.g. 'target' in this example), and the measurements that it provides (e.g. "rtt_stats" in this example). This command's syntax is available [here](http://mytestbed.net/projects/omf6/wiki/OEDLOMF6#defApplication)

4. **.defGroup**. This command is used to define a group of resources which we will use in this experiment. A group may contain many resources and a resource may be included in many groups. This commands may also be used to associate a set of configurations and applications to all resources in a group. In this example, we are defining 2 groups (First_Peer and Second_Peer), each with only one resource, then we are configuring the IP addresses of these resources, and associating the previously declared application to them. Its syntax is available [here](http://mytestbed.net/projects/omf6/wiki/OEDLOMF6#defGroup)

5. **onEvent**. This command declares the set of actions to perform when some specific event is triggered. In this example, the event is "ALL_UP_AND_INSTALLED", i.e. when all node resources are ready to receive commands and all applications associated to them are installed. The actions to perform when such event triggers are: print some message, start the applications associated to each group with some delay, wait some time and then stop the experiment. The syntax for this is available [here](http://mytestbed.net/projects/omf6/wiki/OEDLOMF6#onEvent.)
6. **defGraph**. This commands defines the graph that we would like to generate while the application is running. In this example, we are defining 2 graphs, one is a line chart and the other a pie chart. These graphs will be drawn using measurements declared in the previous defApplication command, and requested in the previous defGroup commands. The syntax for this is available [here](http://mytestbed.net/projects/omf6/wiki/OEDLOMF6#defGraph)


## Part 2 - Execute

1. After saving the above OEDL experiment description, drag-and-drop it from the "Prepare" column to the "Execute" column, as described on the [LabWiki introduction page]([http://groups.geni.net/geni/wiki/GEC18Agenda/LabWikiAndOEDL/Introduction#Execute)

<img src="https://raw.github.com/mytestbed/gec18-tutorial/master/part1/labwiki_exp1_1.png">

2. Set the values of the properties 'resource1' and 'resource2' according to the following:
  * if your pre-allocated slice as the number X
  * then set the value of the 'resource1' property to *1-oedl-X*
  * and set the value of the 'resource2' property to *2-oedl-X*

(You can optionally decide to give a name to your experiment, if not LabWiki will assign a default unique name to it. The slice name is also optional for this tutorial)

<img src="https://raw.github.com/mytestbed/gec18-tutorial/master/part1/labwiki_exp1_2.png">

3. Click on the "Start Experiment" button. You will shortly see output messages under the "Logging" section. Some of these messages are from the OMF Experiment Controller, which is interpreting your OEDL experiment description and sending corresponding commands to the resources. Other messages are from the resources themselves (either the VM nodes or the applications), reporting on configuration and command results.

<img src="https://raw.github.com/mytestbed/gec18-tutorial/master/part1/labwiki_exp1_3.png">

4. If you scroll down below the "Logging" section or if you collapse it, you should see the graphs defined in the OEDL experiment description being drawn dynamically as measurements are collected from the resources.

<img src="https://raw.github.com/mytestbed/gec18-tutorial/master/part1/labwiki_exp1_4.png">


## Part 3 - Finish

1. A message in the "Execute" column will appear to inform you that the experiment execution has finished. At this stage, you should have the complete graphs for this experiment at the bottom of that column, which should look as follows.

<img src="https://raw.github.com/mytestbed/gec18-tutorial/master/part1/labwiki_exp1_5.png">

2. You may interact to with these graphs, e.g. tick or un-tick the legend's keys to display only results from the first or/and second resource, hover the pointer above a graph point to display the underlying data point, drag-and-drop the graph via its icon to the "Plan" column as [LabWiki introduction page](http://groups.geni.net/geni/wiki/GEC18Agenda/LabWikiAndOEDL/Introduction#Execute)

3. The complete data set holding the measurements collected from this experiment should be stored in your personal iRods account. A complete tutorial on how to setup your iRods account, manage and access your data sets is available later in the [Getting Started with GENI and the GENI Portal - Part III - GIMI](http://groups.geni.net/geni/wiki/GEC18Agenda/GettingStartedWithGENI_III_GIMI) session, which starts after this tutorial.


## Help & Additional Resources

 * [LabWiki quick guide](http://groups.geni.net/geni/wiki/GEC18Agenda/LabWikiAndOEDL/Introduction)
 * [OEDL Reference Document](http://mytestbed.net/projects/omf6/wiki/OEDLOMF6)
 * [Getting Started with GENI and the GENI Portal - Part III - GIMI](http://groups.geni.net/geni/wiki/GEC18Agenda/GettingStartedWithGENI_III_GIMI)
 * [OMF6 Documentation](http://mytestbed.net/projects/omf6/wiki/Wiki)
 * [OML Documentation](http://oml.mytestbed.net/projects/oml/wiki)