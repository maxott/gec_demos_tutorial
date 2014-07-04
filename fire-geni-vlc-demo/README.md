# Fed4Fire - GIMI Demonstration June 2014

During this demonstration, we will use resources from both 
Fed4Fire facilities in Europe and Geni facilities in the US.
In a first time we will use the jFed tool to provision up to 
100 nodes accross multiple sites. Then we will run an experiment 
described below over the set of nodes.

----

## 1. The Experiment

In this experiment we want to understand the implications of using a distributed
file system for web-based video content providers.

Current web technologies provide robust solutions for user-web server interaction
but server to storage for large content providers is still an active area.

<img src="https://raw.githubusercontent.com/mytestbed/gec_demos_tutorial/master/fire-geni-vlc-demo/idea1.png" style="width: 70%;" />

We are essentially interested in the following architecture

<img src="https://raw.githubusercontent.com/mytestbed/gec_demos_tutorial/master/fire-geni-vlc-demo/idea2.png" style="width: 70%;" />

Let us have a look at how a distributed file system is actually deployed to get a better idea on
how to design experiments to get a better understanding of impairment scenarios.

<img src="https://raw.githubusercontent.com/mytestbed/gec_demos_tutorial/master/fire-geni-vlc-demo/idea4.png" style="width: 70%;" />

We therefore decided to create the following 
topology:

<img src="https://raw.githubusercontent.com/mytestbed/gec_demos_tutorial/master/fire-geni-vlc-demo/topo.png" style="width: 90%;" />

In this topology, you can see two Virtual Walls or equivalent (we can obviously have more) represented by sites A and B. In each of these sites, we would have an XtreemFS cluster for the replicated files and several VLC clients or HTTP clients using Selenium to manipulate the browser. 

In only one of these sites, we would have a webserver where DASH would be operating. The DASH files would be stored in a directory on top of XtreemFS.

The scenario would be as follows:

+  At time t=0 we would start copying the file into the XtreemFS directory (optional)
+  Once that's done, we would start a video client then we would start more and more clients to fill the pipe from the server (we would use netem to limit the bandwidth
+  Then we might decrease the amount of client to have the best bit rate
+  We would then cut the connection to the main storage, this should trigger XtreemFS to pull the file from the backup storage
+  End of the experiment


----

## 2. Provisioning with jFed

jFed makes it possible to learn the SFA architecture and 
APIs, and also to easily develop java based client tools 
for testbed federation. The suite includes also automated 
testing tools and an experimenter tool.

<img src="https://raw.githubusercontent.com/mytestbed/gec_demos_tutorial/master/fire-geni-vlc-demo/jfed.png" style="width: 400px;" />



----

## 3. Preparing with LabWiki


In LabWiki **Prepare** panel allows you to create, edit and view your experiment
description, which is written using the [OEDL language.](http://mytestbed.net/projects/omf6/wiki/OEDLOMF6)


To **create** a new experiment description, click on the "+" sign, enter a new 
filename, select "OEDL", and click on the "Create" button.

![](https://raw.githubusercontent.com/mytestbed/labwiki/master/doc/quickstart/lw_prepare2.png)

To **view** and **edit** an experiment description, type its name in the search
field, for example the simple experiment `demo.oedl`. 

![](https://raw.githubusercontent.com/mytestbed/labwiki/master/doc/quickstart/lw_prepare3.png)

After editing your experiment, do not forget to save it by clicking on the disk 
icon.

![](https://raw.githubusercontent.com/mytestbed/labwiki/master/doc/quickstart/lw_prepare4.png)


----

## 4. Execute your experiment

In the **Execute** panel, you configure and run your experiment, as well as
view its progress and any defined graphs.

![](https://raw.githubusercontent.com/mytestbed/labwiki/master/doc/quickstart/lw_execute.png)

First, load an experiment description in the **Prepare** panel. For 
example, load the `demo.oedl`, then drag and drop the pen-and-paper icon 
from the **Prepare** to the **Execute** panel.

![](https://raw.githubusercontent.com/mytestbed/labwiki/master/doc/quickstart/lw_execute2.png)

You can now **configure** the parameters of your experiment, and press the Start
button to **run** the experiment!

![](https://raw.githubusercontent.com/mytestbed/labwiki/master/doc/quickstart/lw_execute3.png)

----

## 5. Observe and analyse

While the experiment is running you can view its properties, any defined graph,
and any message it produces.

![](https://raw.githubusercontent.com/mytestbed/labwiki/master/doc/quickstart/lw_execute4.png)


