#ExoGENI/GIMI Tutorial#
###Session Leaders###
ExoGENI: Ilia Baldine (RENCI) 

GIMI: Mike Zink and David Irwin (UMass Amherst) 

###Abstract###
The ExoGENI project is designing, documenting, and building GENI racks, with a combination of host and networking resources, at several campus sites, for use by GENI experimenters.

The GIMI project is developing an instrumentation and measurement framework, capable of supporting the needs of both GENI experimenters and GENI infrastructure operators. It uses the ORBIT Measurement Library (OML) and integrated Rule Oriented Data System (iRODS) as its basis and the Internet Remote Emulation Experiment Laboratory (IREEL). It will provide libraries to instrument resources, to filter and process measurement flows, and to consume measurement flows. It will use the iRODS data grid for archiving and further processing. 

The first part of this tutorial will be focus on gathering resources for an experiment from ExoGENI racks into a slice, and then conducting a basic experiment. 

The second part of this session will introduce the GIMI instrumentation and measurement (I&M) tools, and then show how to instrument an experiment that is executed on an ExoGENI slice. 
After successfully finishing the tutorial, attendees should be able to instrument their own ExoGENI-based experiments. 

The GIMI project will develop and deploy an instrumentation and measurement framework, capable of supporting the needs of both GENI experimenters and GENI infrastructure operators. It uses the ORBIT Measurement Library (OML) and integrated Rule Oriented Data System (iRODS) as its basis and the Internet Remote Emulation Experiment Laboratory (IREEL). It will provide libraries to instrument resources, to filter and process measurement flows, and to consume measurement flows. It will use the iRODS data grid for archiving and further processing. 

In the GEC14 GIMI tutorial we will introduce its basic instrumentation and measurement tools. This introduction will be based on experiments that will be executed on ExoGENI slices which attendees will be instrumenting using GIMI tools. After successfully finishing the tutorial attendees should be able to instrument their own ExoGENI-based experiments. 

This tutorial assumes that attendees have a basic knowledge on ORCA/ExoGENI, and we recommend that interested participants also consider attending the ExoGENI tutorial offered at GEC 14. 

###Preparation###
This tutorial assumes that participants have a basic knowledge OMF; if necessary, they should attend the earlier [OMF tutorial] (http://groups.geni.net/geni/wiki/GEC14Agenda/OMFTutorial). 

Active participants will need a laptop equipped with a recent version of Virtual Box. If you are unable to bring one, you may partner with someone else.

###ORCA/ExoGENI Tutorial###

[ORCA/ExoGENI tutorial instructions] (http://groups.geni.net/geni/wiki/ORCAExoGENITutorial)

###The GIMI tutorial###

####Getting Ready####

+ Bring up tutorial VM and log in.
+ Open Firefox web browser
+ Open a terminal window
+ The software required for this tutorial is already installed in the tutorial VM.
+ Download GIMI tutorial specific configuration files by issuing the following command in a user workspace terminal:
    
        $ cd ~/Tutorials/GIMI/common/
        $ git pull
+ The iRODS client uses a configuration file (~/.irods/.irodsEnv) that sets certain parameter for the icommands. Here is and example:

        # iRODS personal configuration file.
        #
        # This file was automatically created during iRODS installation.
        #   Created Thu Feb 16 14:06:27 2012
        #
        # iRODS server host name:
        irodsHost 'emmy8.casa.umass.edu'
        # iRODS server port number:
        irodsPort 1247
            
        # Default storage resource name:
        irodsDefResource 'iRODSUmass'
        # Home directory in iRODS:
        irodsHome '/geniRenci/home/gimiXX'
        # Current directory in iRODS:
        irodsCwd '/geniRenci/home/gimiXX'
        # Account name:
        irodsUserName 'gimiXX'
        # Zone:
        irodsZone 'geniRenci'
        
+ First of all copy the template iRODS configuration file to .irodsEnv with the following command:

         $ cp ~/.irods/gimiIrodsEnv ~/.irods/.irodsEnv
         
+ Open ~/.irods/.irodsEnv with your favorite text editor (we recommend nano) and change gimiXX to your assigned username (e.g., gimi04).
+ Register with iRODS server by issuing the following command (more details on iRODS will be given shortly):

        $ iinit
        
+ You will be prompted for a password. Please type in the password you were provided with on the paper handout!!
+ The image below shows the topology and the interfaces and the routing that has been set up for the measurement:

![GIMI-3-node-ping.png](/home/cong/Dropbox/SHARED/GENI/GEC/GIMI-3-node-ping.png "")

###Part 1: OMF/OML on ExoGENI###
The goal of this part of the tutorial is to instrument the topology that has been created by the tutorial participants in the preceding ExoGENI tutorial. Perform Iperf measurement on top of that instrumented topology and analyze data from that measurement.
####1.1 Setting up the ExoGENI slice####
*THE NEXT STEPS ARE ONLY NECESSARY IF NOT PERFORMED IN EXOGENI TUTORIAL:*

1.1.1 Download the RDF file that describes the ExoGENI topology for your experiment with the following commands:

*Don't forget to replace gimiXX with your current userID.*

    $ cd ~/Tutorials/GIMI/gimiXX
    $ wget http://emmy9.casa.umass.edu/RDFs/gimiXX.rdf

1.1.2 Before starting Flukes, please open "~/.flukes.properties" file and edit "gimiXX" to your username.

1.1.3 In the tutorial VM start Flukes and load gimiXX.rdf. (Also here, replace gimiXX with your assigned user ID.) In Flukes select Files->Open Request->select gimiXX.rdf in ~/Tutorials/GIMI/gimiXX.

1.1.4 Verify settings and create slice. First select the the *Request View* tab.

+ To verify settings right-click on each node and select *Edit Properties*
+ To create a slice enter your slice name *gimiXX-tutorial* in to the empty field next to the *Submit Request* button and the click the latter.

1.1.5 To check if all the resources have come up go to the *Manifest View* tab and enter your slice name (*gimiXX-tutorial*) into the empty field. Then click *Query for Manifest*. After a short moment a box with all the requested resources and their respective status will appear. (This box does not update automatically and you have to hit the *Query for Manifest* button again to receive and update).

1.1.6 Each node uses the same image but runs a slightly different post boot script. The post boot scripts (specified in Flukes) are shown below.

+ Node A

        hostname gimi01-tutorial-nodeA
    
        apt-get update
    
        curl https://pkg.mytestbed.net/ubuntu/oneiric/oml2-iperf_2.0.5-1ubuntu5_amd64.deb -o /root/iperf.deb
        dpkg -i /root/iperf.deb
        
        route add -net 192.168.2.0 netmask 255.255.255.0  gw 192.168.1.11
        
        curl http://emmy9.casa.umass.edu/pingWrap.rb -o /root/pingWrap.rb
        chmod +x /root/pingWrap.rb
        gem install oml4r
        
        omf_create_psnode-5.4 emmy9.casa.umass.edu mkslice gimi01-tutorial gimi01-tutorial-nodeA
        
        curl http://emmy8.casa.umass.edu/enrolled.patch -o enrolled.patch
        patch -p1 &lt; /enrolled.patch
        
        curl http://emmy8.casa.umass.edu/omf-resctl.yaml -o /etc/omf-resctl-5.4/omf-resctl.yaml
        perl -i.bak -pe "s/\:slice\:/\:slice\: gimi01-tutorial/g" /etc/omf-resctl-5.4/omf-resctl.yaml
        
        /etc/init.d/omf-resctl-5.4 restart
        
+ Node B

        hostname gimi01-tutorial-nodeB

        apt-get update
        
        curl https://pkg.mytestbed.net/ubuntu/oneiric/oml2-iperf_2.0.5-1ubuntu5_amd64.deb -o /root/iperf.deb
        dpkg -i /root/iperf.deb
        
        route add -net 192.168.2.0 netmask 255.255.255.0  gw 192.168.1.11
        
        curl http://emmy9.casa.umass.edu/pingWrap.rb -o /root/pingWrap.rb
        chmod +x /root/pingWrap.rb
        gem install oml4r
        
        omf_create_psnode-5.4 emmy9.casa.umass.edu mkslice gimi01-tutorial gimi01-tutorial-nodeB
        
        curl http://emmy8.casa.umass.edu/enrolled.patch -o enrolled.patch
        patch -p1 &lt; /enrolled.patch
        
        curl http://emmy8.casa.umass.edu/omf-resctl.yaml -o /etc/omf-resctl-5.4/omf-resctl.yaml
        perl -i.bak -pe "s/\:slice\:/\:slice\: gimi01-tutorial/g" /etc/omf-resctl-5.4/omf-resctl.yaml
        
        /etc/init.d/omf-resctl-5.4 restart
        
+ Node C

        hostname gimi01-tutorial-nodeC

        apt-get update
        
        curl https://pkg.mytestbed.net/ubuntu/oneiric/oml2-iperf_2.0.5-1ubuntu5_amd64.deb -o /root/iperf.deb
        dpkg -i /root/iperf.deb
        
        route add -net 192.168.2.0 netmask 255.255.255.0  gw 192.168.1.11
        
        curl http://emmy9.casa.umass.edu/pingWrap.rb -o /root/pingWrap.rb
        chmod +x /root/pingWrap.rb
        gem install oml4r
        
        omf_create_psnode-5.4 emmy9.casa.umass.edu mkslice gimi01-tutorial gimi01-tutorial-nodeC
        
        curl http://emmy8.casa.umass.edu/enrolled.patch -o enrolled.patch
        patch -p1 &lt; /enrolled.patch
        
        curl http://emmy8.casa.umass.edu/omf-resctl.yaml -o /etc/omf-resctl-5.4/omf-resctl.yaml
        perl -i.bak -pe "s/\:slice\:/\:slice\: gimi01-tutorial/g" /etc/omf-resctl-5.4/omf-resctl.yaml
        
        /etc/init.d/omf-resctl-5.4 restart
        
1.1.5 The images running on the ExoGENI nodes include the following software:
+ OMF (AM, RC, EC)
+ OML
+ OMLified Iperf, nmetrics
+ iRODS client

1.1.6 For those who would like to use this image as a basis for their own experiment on ExoGENI it can be found here: http://emmy9.casa.umass.edu/GEC14-GIMI-Tutorial/dilip-gec14.xml

1.1.7 Note

+ The OMF experiment controller (EC) that controls the experiment is based on unique host name and experiment name
+ After initial boot up ExoGENI nodes host names are always initially set to "debian"
+ The node names will be automatically set to the correct names by a post boot script (defined in Flukes). The code snippet below shows the section of the post boot script that performs this step (for the case of node A) :

        $ hostname gimiXX-tutorial-nodeA
        
The experiment name has to be set to the unique slice name of your ExoGENI request. *This is already done in the post boot script for this tutorial.*

+ If you want to perform a measurement on a different slice, we here outline the steps to adapt the post boot script for that scenario.
    + Change the post boot script option to add slice name as the experiment name. Therefore change the existing experiment name "gec14-gimi01" in line five to the experiment that includes your account name. E.g., if your account name is "gimi05" the experiment name has to be changed to "gimi05-tutorial"!!

            curl http://emmy8.casa.umass.edu/omf-resctl.yaml -o
            /etc/omf-resctl-5.4/omf-resctl.yaml
            
            perl -i.bak -pe "s/\:slice\:/\:slice\: gimi05-tutorial/g"
            /etc/omf-resctl-5.4/omf-resctl.yaml
            
    + Request the ExoGENI slice using Flukes

####1.2 Registering the slice with XMPP server####

The RCs and the EC communicate via an XMPP server. The GIMI XMPP is running on emmy9.casa.umass.edu.

The registration of the RCs and EC for this tutorial is automated in the post boot script. We list the following steps to show you how this can be done manually, if necessary.

+ First the ExoGENI instances and the experiment slice should be registered with the XMPP server. You can achieve this using the OMF AM by issuing the following command from a terminal in the user workspace. In the following command, please change "gimiXX" to the user name provided to you.

        $ omf_create_psnode-5.4 "XMPP Server" mkslice "slice_name" "list_of_nodenames"
        
        E.g., omf_create_psnode-5.4 emmy9.casa.umass.edu mkslice gimiXX-tutorial gimiXX-tutorial-nodeA gimiXX-tutorial-nodeB gimiXX-tutorial-nodeC
        
If this succeeds you should see an output similar to the one below

    DEBUG: Try to connect to Pubsub Gateway 'emmy9.casa.umass.edu'...
    DEBUG: Try to connect to Pubsub Gateway 'emmy9.casa.umass.edu:5222'...
    DEBUG: Connected as 'aggmgr@emmy9.casa.umass.edu' to XMPP server: 'emmy9.casa.umass.edu'
    Connected to PubSub Server: 'emmy9.casa.umass.edu'
    
####1.3 Starting the resource controller (RC)####
*For this tutorial the first step is automated in the post boot script. We list it here to show you how this can be done manually, if necessary.*

+ Login to nodes A, B, and C through Flukes and start the RC daemon by issuing the following command:
        $ /etc/init.d/omf-resctl.5.4 restart
        
+ Finally, verify that the RC has been brought up and is listening to the XMPP server by checking the RC log.
        $ cat /var/log/omf-resctl-5.4.log
        
And you should see the following as the last two lines of the log file:

    2012-06-30 23:49:10 DEBUG nodeAgent::OMFPubSubTransport: Listening on '/OMF/dilip-testing/resources/nodeA' at 'emmy9.casa.umass.edu'
    2012-06-30 23:49:10 DEBUG nodeAgent::OMFPubSubTransport: Listening on '/OMF/dilip-testing' at 'emmy9.casa.umass.edu'
    
####1.4 Starting the OML Server (if needed)####
For this tutorial we have an OML server running on emmy9.casa.umass.edu, which collects the measurement data as an sqlite3 database and at the end of the experiment it pushes the data to IRODS.
+ Here is how you would have to start an OML server if you wanted to run this on a different machine (OML2.8 is required.) DO NOT perform this task in the tutorial.
This is explained the [OML installation file].

        $ oml2-server --listen=3003 --data-dir=~ --logfile=oml_server.log -H ~/oml2-2.8.0/server/oml2-server-hook.sh
        
The latest version of OML offers the capability of executing a script after the measurement has finished. In OML terminology this is called a "hook". The hook script we use is attached at the bottom of this wiki page (oml2-server-hook.sh).

####1.5 Running the experiment####

1.5.1 The experiment will be automatically executed by the OMF EC which is defined by a experiment description file (EDF) written in ruby.

1.5.2 We have prepared the necessary ED files for the experiment described above. The file can be found in the tutorial VM under ﻿~/Tutorials/GIMI/common/tcp_iperf.rb

1.5.3 We start the experiment running the following command from the user workspace terminal:

    $ cd ~/Tutorials/GIMI/common/
    $ omf-5.4 exec --no-cmc -S <slice_name> <ED file name> -- --source1 <hostname> --sink <hostname>
    
    Eg., omf-5.4 exec --no-cmc -S gimiXX-tutorial tcp_iperf.rb -- --source1 gimiXX-tutorial-nodeA --sink gimiXX-tutorial-nodeC
    
1.5.4 The command tries to load the topology and start the experiment and you should see XMPP messages such as below.

    INFO NodeHandler: OMF Experiment Controller 5.4 (git 529a626)
     INFO NodeHandler: Slice ID: dilip-testing (default)
     INFO NodeHandler: Experiment ID: dilip-testing
     INFO NodeHandler: Message authentication is disabled
     INFO Experiment: load system:exp:stdlib
     INFO property.resetDelay: value = 210 (Fixnum)
     INFO property.resetTries: value = 1 (Fixnum)
     INFO Experiment: load system:exp:eventlib
     INFO Experiment: load tcp_iperf.rb
     INFO property.source1: value = "nodeA" (String)
     INFO property.sink: value = "nodeC" (String)
     INFO Topology: Loading topology 'nodeA'.
     INFO Topology: Loading topology 'nodeA'.
     INFO Topology: Loading topology 'nodeC'.
     INFO ALL_UP_AND_INSTALLED: Event triggered. Starting the associated tasks.
     INFO exp: Request from Experiment Script: Wait for 10s....
     
1.5.5 Ignore the error messages that are shown during the execution of the experiment. They are essentially warnings! If everything goes well with the experiment, you should see the XMPP messages on the screen stop at this point for few seconds,

    ERROR NodeHandler:   The resource 'nodeC' reports that an error occured 
    ERROR NodeHandler:   while running the application 'iperf_app#3'
    ERROR NodeHandler:   The error message is 'INFO   Net_stream: connecting to host tcp://emmy9.casa.umass.edu:3003'
    
1.5.6 If you do not see the following message after approximately 3 minutes, then please call for help!!

    INFO EXPERIMENT_DONE: Event triggered. Starting the associated tasks.
    INFO NodeHandler: 
    INFO NodeHandler: Shutting down experiment, please wait...
    INFO NodeHandler: 
    INFO run: Experiment gimi04Test070204 finished after 3:02
    
1.5.7 Wait until the experiment has ended before going to the next step.

####1.6 Visualization####
+ Once you have started the experiment and it is running without errors, please open another terminal in you user workspace. Goto "~/Tutorials/GIMI/common" directory, and run the following command to create the visualization of the experiment carried out. Please change "gimiXX" in the command to your username.

        $ cd ~/Tutorials/GIMI/common
        $ ./tutorial_viz.sh gimiXX-tutorial
        
+ Please open the firefox browser and type "127.0.0.1/oml.html" to view the visualization!! You should see something similar to what's shown below. 
![gec14-visualization.png](/home/cong/Dropbox/SHARED/GENI/GEC/gec14-visualization.png "GIMI Visualization")
+ The visualization script contains a "R" script to generate pdf/jpg based on the sqlite3 measurement database file generated by the OMLified application. The script is located in ~/Tutorials/GIMI/common/R_script_viz.r.
+ If you want to run the experiment for long time, edit the "tcp_iperf.rb" file to change the interval or edit the "tutorial_ec_script.sh" to change the EC command and run the experiment in a loop. After you have done editing, execute the bash script in command line by typing "./tutorial_ec_script.sh".

###Part 2: iRODS - GIMI's Measurement Repository###
In GIMI, iRODS is used as the repository for measurement data. At the moment our iRODS data system consist of three servers (RENCI, NICTA, and UMass) and a metadata catalog (located at RENCI).

We will use part 2 of this tutorial to make the participants more familiar with iRODS and how we use it in GIMI.

*After successful completion of part 1 of the tutorial the measurement data from the experiment has been stored in iRODS. We will now look into two options on how this data can be handled.

1. iRODS command line tools in the user work space:
 + The GENI User Workspace comes already with the iRODS command line tools installed.
 + If you have not done so far use iinit to create a file that contains your iRODS password in a scrambled form. This will then be used automatically by the icommands for authentication with the server.
   
               $ iinit
         
You will be prompted for a password. Please enter the one given on the paper handout.

+ The iRODS client uses a configuration file (~/.irods/.irodsEnv) that sets certain parameter for the icommands. Here is and example:

        # iRODS personal configuration file.
        #
        # This file was automatically created during iRODS installation.
        #   Created Thu Feb 16 14:06:27 2012
        #
        # iRODS server host name:
        irodsHost 'emmy8.casa.umass.edu'
        # iRODS server port number:
        irodsPort 1247
        
        # Default storage resource name:
        irodsDefResource 'iRODSUmass'
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

        $ iput <file_name>
        
2. iRODS web interface:

    iRODS also provides a nice and easy to use web interface, which we will explore in the following.
    
+ Point the browser in your user workspace to the following link: https://www.irods.org/web/index.php
+ Input the following information to sign in:

        Host/IP: emmy8.casa.umass.edu
        Port: 1247
        Username: as given on printout
        Password: as given on printout
        
+ The following screenshot shows an example for the web interface: 
![gec13-irods_screen.png](/home/cong/Dropbox/SHARED/GENI/GEC/gec13-irods_screen.png "iRODS web interface")

3. IRODS and OML

    In GIMI we have enabled an option in OML2.8 that allows the execution of script. We use this functionality to automatically save measurement results in IRODS after a measurement has successfully completed.
    
4. DISCLAIMER

    The iRODS service we are offering within the scope of GIMI does NOT guarantee 100% reliable data storage (i.e., we do NOT back up the data). If you are performing your own experiments and want to use iRODS you are absolutely welcome but be aware that we do NOT guarantee recovery from data loss.
    