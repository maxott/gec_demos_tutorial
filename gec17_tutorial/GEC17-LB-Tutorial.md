#OpenFlow LoadBalancer Tutorial#

In this tutorial, we will show how do Network Load Balancing using OpenFlow on GENI. Network Load Balancing is the division of traffic of multiple path to improve performance.

###Overview###
This tutorial leverages resources on the GENI aggregate in order to experiment with OpenFlow. For this tutorial, you will design a load-balancing OpenFlow controller capable of collecting flow status data from OpenFlow switches and using it to divide traffic between dissimilar network paths so as to achieve full bandwidth utilization. We are going to use OpenFlow Virtual Switches (OVS) and implement a Load Balancer OpenFlow Controller using Trema. 
Please remember to release the resources you when you are done with them. The following is the topology that you will be creating: 

![OpenFlowLB-topo.png](http://groups.geni.net/geni/attachment/wiki/GEC17Agenda/AdvancedOpenFlow/Procedure/OpenFlowLB-topo.png?format=raw "")

###Prerequisites###

+ A GENI account, if you don't have one [sign up](http://groups.geni.net/geni/wiki/SignMeUp)!
+ Familiarity with how to reserve GENI resources with any of the GENI Tools (GENI Experimenter Portal, Omni, Flack). If you don't know you can take any of the tutorials:
    + Reserving resources using [Flack tutorial](http://groups.geni.net/geni/wiki/GENIExperimenter/Tutorials/RunHelloGENI)
    + Reserving resources using [Omni tutorial](http://groups.geni.net/geni/wiki/GENIExperimenter/Tutorials/HelloOmni)
+ Familiarity with [logging in to GENI compute resources](http://groups.geni.net/geni/wiki/HowTo/LoginToNodes).
+ Basic understanding of OpenFlow. If you are going over this tutorial at home, flip through the [tutorial's slides](http://groups.geni.net/geni/attachment/wiki/GEC17Agenda/AdvancedOpenFlowTutorial/AdvancedOpenFlow-GEC17.pptx)
+ [Create iRODs account](http://groups.geni.net/geni/wiki/GEC18Agenda/GettingStartedWithGENI_III_GIMI/Procedure/DesignSetup#iRODs)
+ Introduction to [LabWiki tutorial](http://groups.geni.net/geni/wiki/GEC18Agenda/GettingStartedWithGENI_III_GIMI)
+ Familiarity with Unix Command line - See "Tools" section
+ A moderately deep understanding of the [OpenFlow controller model](http://www.openflow.org/) and API is required.
+ The OpenFlow specification, [version 1.0](http://www.openflow.org/documents/openflow-spec-v1.1.0.pdf) is a valuable reference for OpenFlow and the controller model.

###Tools###

**1. Trema **
Each exercise in this assignment will require you to design and implement an OpenFlow controller. Numerous libraries and controller frameworks are available for this task. The guidelines in this assignment assume that you are using the Trema controller framework. The Trema project web site, http://trema.github.com/trema/, contains documentation, a number of helpful examples, and some tutorial material for learning to use Trema.

**2. Traffic Control (tc)**
The tc command is available in the GNU Linux distributions on GENI nodes, found in the /sbin directory. This command manipulates the Linux network forwarding tables, allowing for configuration of queuing disciplines, which change the policies controlling which packets are forwarded in what order and which are dropped; and network emulation, which allows the Linux kernel to emulate various network conditions such as delay or loss. These two effects are provided by the qdisc and netem subcommands, respectively. In these exercises, tc will be used to modify network conditions and enable different scheduling policies. Example command lines will be provided.

**3. Iperf**
Iperf is available on the GENI nodes, located at /usr/local/etc/emulab/emulab-iperf. Iperf is used to measure the bandwidth performance of Internet links. In these exercises, it is used to study the behavior of TCP in the face of changing link characteristics. Iperf runs as both a server and a client. The server is started with the -s command line option, and listens for connections from the client. The client is started with the -c <server> command line option, and connects to the server and sends data at either the fastest possible rate (given the underlying network) or a user-specified rate. The -u option causes the sender or receiver to use UDP instead of TCP. Various other options will be required for these exercises, and provided in the appropriate sections. All Iperf measurement data should be recorded from the TCP receiver (server) side.

###How to get Help###
+ Always ask your tutors (tutorial helper/presenter/TA) first. They are the fastest way to solve the problem.
+ If you are using a specific aggregate or tool, you should consider registering in their [mailing list](http://groups.geni.net/geni/wiki/NikySandbox/GENIExperimenter/GENICommunity#Joinusermailinglists). It is a great way to get connected with other GENI users and it is an excellent source of wisdom.
+ Send mail to the GENI help list: help@geni.net.
+ If you want to chat real-time with other GENI users and ask questions, [join us](http://groups.geni.net/geni/wiki/HowTo/ConnectToGENIChatRoom) in a GENI chatroom.

##1. Obtain resources

For this experiment we are going to use ExoGENI resources, we will need:

+ 6 VM (KVM): 2 (inside, outside) act as regular hosts; 2 (left, right) as regular switches; 2 (aggregator, switch) as OpenFlow switches (we will only program one: switch)

If you are attending a Tutorial, the resources might have already been reserved for you, check with your instructor and skip this step.

![OpenFlowLBExo.png](http://groups.geni.net/geni/attachment/wiki/GEC17Agenda/AdvancedOpenFlow/Procedure/DesignSetup/OpenFlowLBExo.png?format=raw "")

The various parts of the diagram are as follows:

+ Inside and Outside Nodes: These nodes can be any ExoGENI Virtual Nodes.
+ Switch: This node is a Linux host running Open vSwitch. Your Load Balancing OpenFlow Controller will be running on this node as well. This is the main node that you will be working on.
+ Traffic Shaping Nodes (Left and Right): These are Linux hosts with two network interfaces. You can configure netem on the two traffic shaping nodes to have differing characteristics; the specific values don’t matter, as long as they are reasonable. Use several different delay/loss combinations as you test your load balancer.
+ Aggregator: This node is a Linux host running Open vSwitch with a switch controller that will cause TCP connections to “follow” the decisions made by your OpenFlow controller on the Switch node. You will not need to change anything on this node, you only need to implement the OpenFlow controller on node "Switch".

You can use any reservation tool you want to reserve this topology:

+ For Omni or Flack you can use the [RSpec](http://groups.geni.net/geni/wiki/GENIExperimenter/RSpecs) that is published at: http://emmy9.casa.umass.edu/GEC-19/openflow-loadbalancer-kvm.rspec and any ExoGENI AM
+ At the GENI Experimenter Portal there is a public RSpec called "GEC19LoadBal" that you can use, and either of the ExoGENI AMs

Look at the [Prerequisites](http://groups.geni.net/geni/wiki/GEC17Agenda/AdvancedOpenFlow/Procedure#Prerequisites) for Tutorials about reserving resources.

##1.1 Login to Nodes Switch and Aggregator##
###1.1.1 Find your Aggregate###
Click on your Slice name in the GENI Portal and scroll to the aggregate where you reserved your resources. 

![FindAM.png](http://groups.geni.net/geni/attachment/wiki/GEC17Agenda/AdvancedOpenFlow/Procedure/DesignSetup/FindAM.png?format=raw "")

Click on "Details" next to it. You will see a page as below.

![LoginAM.png](http://groups.geni.net/geni/attachment/wiki/GEC17Agenda/AdvancedOpenFlow/Procedure/DesignSetup/LoginAM.png?format=raw "")

Use the Login information obtained here to login to your nodes using any SSH client.

##2. Configure and Initialize Services##

###2.1 Login to Nodes Switch, Aggregator, Inside and Outside###

####2.1.1 Get your reservation details####
Click on your Slice name in the GENI Portal, scroll to the aggregate where you reserved your resources and click on "Details" next to it. You will see a page as below. 

![FindAM.png](http://groups.geni.net/geni/attachment/wiki/GEC17Agenda/AdvancedOpenFlow/Procedure/Execute/FindAM.png?format=raw "")

Use the Login information obtained here to login to any node using any SSH client. Please login on 4 different ssh windows to: switch, aggregator, inside, outside. 

![LoginAM.png](http://groups.geni.net/geni/attachment/wiki/GEC17Agenda/AdvancedOpenFlow/Procedure/Execute/LoginAM.png?format=raw "")

###2.2. Setup your nodes###
**2.2.1 Check that all interfaces on the switch and on the aggregator are configured: Issue /sbin/ifconfig and make sure eth1, eth2, eth3 are up and assigned with valid IP addresses.**

 You may not be able to see all interfaces up immediately when node "Switch" is ready; wait for some more time (about 1 min) then try "ifconfig" again. On the switch node note which interfaces have the following IP addresses:
 
     192.168.2.1(left) 
     192.168.3.1(right)
     
**2.2.2** Setup the switch and the aggregator
On the Aggregator Node run

      sudo bash
      source  /etc/profile.d/rvm.sh
      trema run /tmp/aggregator/aggregator.rb >& /tmp/trema.run &

On the Switch Node run

     sudo bash
     source  /etc/profile.d/rvm.sh
     
 We have already installed and configured the OVS switch, if you want to take a look at the configuration and understand more look at the output of these commands
 
      ovs-vsctl list-br
      ovs-vsctl list-ports br0
      ovs-vsctl show br0
      ovs-ofctl show br0
  
###2.3. Configure LabWiki to orchestrate and monitor your experiment###

**2.3.1** Log on to LabWiki on http://emmy9.casa.umass.edu:<port> 
use the port given to you

For this tutorial, we have a preloaded script (loadbalancer.rb). Type this in the Prepare column. Your script should appear. Click on it. If the script does not appear then create one yourself.

in the Prepare Column, create a new Ruby script by clicking on the "*" at the top-left of the column.

![labwikinew.png](http://groups.geni.net/geni/attachment/wiki/GEC17Agenda/AdvancedOpenFlow/Procedure/Execute/labwikinew.png?format=raw "")

Type a name for the script, eg. loadbalancer and save it as an OEDL file. Enter the name of the script you just created, in the prepare column. It is now ready for editing.

![labwikinew2.png](http://groups.geni.net/geni/attachment/wiki/GEC17Agenda/AdvancedOpenFlow/Procedure/Execute/labwikinew2.png?format=raw "")

Copy the contents of the script from Appendix A, paste it in LabWiki and save it. 

  Make sure that the save icon is deactivated after you press save, if it is not it means you have not successfully saved, try again.
 
##3. Run your experiment##
###3.1 Start your experiment###
**3.1.1** Start the controller on switch. An example OpenFlow Controller that assigns incoming TCP connections to alternating paths based on total number of flows (round robin) is already downloaded for you. You can find it (load-balancer.rb) in the home directory on node "Switch". 

    trema run /root/load-balancer.rb
    
After you started your Load Balancer, you should be able to see the following (Switch id may vary):

      OpenFlow Load Balancer Conltroller Started!
      Switch is Ready! Switch id: 196242264273477
      
This means the OpenFlow Switch is connected to your controller and you can start testing your OpenFlow Load Balancer now.

**3.1.2** Start your experiment in LabWiki.
**3.1.2.1** Drag the file Icon at the left-top corner on your LabWiki page from Prepare column and drop it to Execute column.
**3.1.2.2** Fill in the the experiment properties in the Execute column:
+ name of your LabWiki experiment (this can be anything that does not contain
spaces, it is just to help you track the experiments you run)
+ select your project from the drop-down list
+ select your slice from the list,
+ Change theSender, theReceiver and theSwitch to include your slice name. For e.g outside-loadbaltest should be outside-<yourslicename>
+ fill in the left and right interfaces for the switch node as you gathered them at step 2.2.1

 If you want instead of changing them at the Execute pane every time you run an experiment you can change them once in the script. Just modify these lines to the appropriate values:
 
![editscriptLW.png](http://groups.geni.net/geni/attachment/wiki/GEC17Agenda/AdvancedOpenFlow/Procedure/Execute/editscriptLW.png?format=raw "")

**3.1.2.3** Press the "Start Experiment" button.

**3.1.2** When your experiment is finished:
+ Kill the controller at the switch node by pressing Ctrl-c
+ Kill the iperf processes on outside and inside nodes. On both nodes do: ps aux | grep "iperf". Output should look like:

    root      4728  0.0  1.1 273368  6044 ?        Ssl  19:13   0:00 /usr/bin/iperf_oml2 -s -p 6001 --oml-config /tmp/51449a37-ab3e-43a3-a872-37931c7785ee-1389294789.xml
    
Execute kill -9 <process_id> for the above case <process_id> would be 4278

###3.2 Run the experiment in paths with different bandwidth###

**3.2.1** Log on to node "left" (use the readyToLogin.py script) and change the link capacity for the interface with IP address "192.168.2.2" (use "ifconfig" to find the correct interface, here we assume eth1 is the interface connecting to node "Switch"):

     ovs-vsctl set Interface eth1 ingress_policing_rate=10000
     
The above will rate-limit the connection from node "Switch" to node "left" to have a bandwidth of 10Mbps.
+ Other ways to e.g., change link delay and loss-rate using "tc qdisc netem" can be found in Appendix D.
**3.2.2** Re-run your experiment with the new setting following the same instructions as in 3.1.

**Questions**

+ Did you see any difference from the graphs plotted on LabWiki, compared with the graphs plotted in the first experiment? why?
+ Check out the output of the Load Balancer on node "Switch" and tell how many flows are directed to the left path and how many are on the right path, why?
+ To answer the above question, you need to understand the Load Balancing controller. Check out the "load-balancer.rb" file in your home directory on node "Switch". Check Appendix B for hints/explanations about this OpenFlow Controller.

###3.3 Modify the OpenFlow Controller to balance throughput among all the TCP flows###

+ You need to calculate the average per-flow throughput observed from both left and right paths. The modifications need to happen in the function "stats_reply" in load-balancer.rb
+ In function "decide_path", change the path decision based on the calculated average per-flow throughput: forward the flow onto the path with more average per-flow throughput. (Why? TCP tries its best to consume the whole bandwidth so more throughput means network is not congested)
    + Helpful tips about debugging your OpenFlow controller can be found in Appendix E
    + If you really do not know where to start, the answer can be found on node "Switch", at /tmp/load-balancer/load-balancer-solution.rb
    + Copy the above solution into your home directory then re-do the experiment on LabWiki. 
+ You need to change your script to use the correct Load Balancing controller (e.g., if your controller is "load-balancer-solution.rb", you should run "/opt/trema-trema-f995284/trema run /root/load-balancer-solution.rb")
+ Rerun the experiment using your new OpenFlow Controller following the steps of Section 3.1, check the graphs plotted on LabWiki as well as the controller's log on node "Switch" and see the difference.

###3.4 Automate your experiment using LabWiki###
**3.4.1** Add code in your LabWiki script to automate starting and stopping your OpenFlow Controller:

+ 3.4.1.1 Go back to your LabWiki page, un-comment the script from line 184 to line 189 to start your OpenFlow Controller automatically on LabWiki 
 You might need to change line 185 to use the correct load balancer controller
+ 3.4.1.2 In your script, uncomment lines 205 to line 209 to stop your OpenFlow Controller automatically on LabWiki
**3.4.2** On your LabWiki web page, drag and drop the file icon and repeat the experiment, as described in section 3.1, using a different experiment name (the slice name should stay the same).
+ If you have more time or are interested in trying out things, go ahead and try section 3.5. The tutorial is over now and feel free to ask questions :-)

##3.5(Optional) Try different kinds of OpenFlow Load Balancers##

+ You can find more load balancers under /tmp/load-balancer/ on node "Switch"
+ To try out any one of them, follow the steps:
    + At the home directory on node "Switch", copy the load balancer you want to try out, e.g.,      
    + cp /tmp/load-balancer/load-balancer-random.rb /root/
    + Change your LabWiki code at line 185 to use the correct OpenFlow controller.
    + On LabWiki, drag and drop the "File" icon and re-do the experiment as described in section 3.1

+ Some explanations about the different load balancers:
    + "load-balancer-random.rb" is the load balancer that picks path randomly: each path has 50% of the chance to get picked
    + "load-balancer-roundrobin.rb" is the load balancer that picks path in a round robin fashion: right path is picked first, then left path, etc.
    + Load balancers that begin with "load-balancer-bytes" picks path based on the total number of bytes sent out to each path: the one with fewer bytes sent out is picked
        + "load-balancer-bytes-thread.rb" sends out flow stats request in function "packet_in" upon the arrival of a new TCP flow and waits until flow stats reply is received in function "stats_reply" before a decision is made. As a result, this balancer gets the most up-to-date flow stats to make a decision. However, it needs to wait for at least the round-trip time from the controller to the switch (for the flow stats reply) before a decision can be made.
        + "load-balancer-bytes-auto-thread.rb" sends out flow stats request once every 5 seconds in a separate thread, and makes path decisions based on the most recently received flow stats reply. As a result, this balancer makes path decisions based on some old statistics (up to 5 seconds) but reacts fast upon the arrival of a new TCP flow (i.e., no need to wait for flow stats reply)
    + Load balancers that begin with "load-balancer-flows" picks path based on the total number of flows sent out to each path: the one with fewer flows sent out is picked
    + Load balancers that begin with "load-balancer-throughput" picks path based on the total throughput sent out to each path: the one with more throughput is picked

##4. Release Resources##

After you are done with this experiment, release your resources using the reservation tool of choice. 
Simply follow the tutorial on TeardownExperiment to tear down your experiment and release the resources you reserved.

Look at the Prerequisites for Tutorials on reservation tools.

Now you can start designing and running your own experiments.