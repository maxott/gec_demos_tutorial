title: GEC21 - OEDL Tutorial 1

# GEC21 - OEDL Tutorial 1

# Overview

This first part shows how to design, execute, and view the results of an experiment, which dynamically reacts to a user-defined event.

This experiment demonstrate OEDL's capability to allow user to define events which will trigger based on the state of the used resources. In other words, if one or more resources reaches a specific state, the event will trigger and some user-defined tasks will be executed.

In this experiment:

- we start with 4 resources, i.e. 2 initial 'workers' and 2 backup ones
- all workers have a ping application associated to them
- the 2 initial workers starts their ping applications
- we define a custom event which will trigger when a running ping application is stopped. The Experiment Controller will periodically monitor the state of all resources to check for this condition
- furthermore, we define a set of tasks to execute if the event is triggered. In this case, the task is to start a new ping application on one of the backup resources.
- every 20 seconds, we purposely stop the ping application running on one of the initial workers
- we display a graph of the ping's RTT for each of the 4 resources and observe that a new ping instance starts when a previously running one is stopped


![Experiment 1 Overview](https://raw.githubusercontent.com/mytestbed/gec_demos_tutorial/master/gec21_oedl_tutorial/tutorial_1.fig1.png)

# Step 1 - Design/Setup 

For specific help on using LabWiki, please refer to the [LabWiki introduction page](http://groups.geni.net/geni/wiki/GEC21Agenda/OEDL/Introduction)

**The OEDL experiment description**

- First, if you have not done it yet, login into LabWiki
- Load the 'gec21_exp1' experiment file in the 'Prepare' Panel of LabWiki. This file contains the OEDL script for this 1st experiment
- If you are not reading this using LabWiki, you can view this OEDL file online at: [http://git.io/AcVU1g](http://git.io/AcVU1g)

![Experiment 1 OEDL Extract](https://raw.githubusercontent.com/mytestbed/gec_demos_tutorial/master/gec21_oedl_tutorial/tutorial_1.fig2.png)

**Walk-through the OEDL experiment description**

1. First, a reminder that all details on OEDL are available in the [OEDL reference page](http://mytestbed.net/projects/omf6/wiki/OEDLOMF6)

2. [**loadOEDL**](http://mytestbed.net/projects/omf6/wiki/OEDLOMF6#loadOEDL) (line 12). This command is used to include in your OEDL experiment other external OEDL scripts. In this example, we are loading the definition of a ping application, which has been instrumented with [OML](http://oml.mytestbed.net)

3. [**defProperty**](http://mytestbed.net/projects/omf6/wiki/OEDLOMF6#defProperty-38-property-38-ensureProperty) (line 14-18). This command is used to define experiment properties (aka variables), you can set the values of these properties as parameters for each experiment trials, and access them throughout the entire experiment run. In this example, we are defining 5 properties, to hold the names of each of the resources that we will use and the target for the ping application.

4. **Some internal variables** (line 21-29). These are classic simple Ruby commands that allow us put all our resource in a single list, then split that list into one holding the 'initial' resources, and one holding the 'backup' resources. As opposed to the above defProperty variables, these internal variables cannot be set at the start of each experiment trial (without having to change the content of the OEDL script itself)

5. [**defGroup**](http://mytestbed.net/projects/omf6/wiki/OEDLOMF6#defGroup) (line 32-41). This command is used to define a group of resources which we will use in this experiment. A group may contain many resources or any other group, and a resource may be included in many groups. This commands may also be used to associate a set of configurations and applications to all resources in a group. In this example, we first define 4 groups (e.g. 'Worker_X'), each with only one resource, then we are associating an instrumented ping to the unique resource in each group. This association is done using the [**addApplication**](http://mytestbed.net/projects/omf6/wiki/OEDLOMF6#defGroup). Furthermore, we also define a final group ('Initial_Worker'), which will contain the 'Worker' groups with the initial resources.

6. [**defEvent**](http://mytestbed.net/projects/omf6/wiki/OEDLOMF6#defEvent) (line 23-53). This command defines the name of a user's custom event and the block of conditions which will be used to check if this event should be triggered.
    - Within the condition block we have access to the 'state' variable, which holds a array. Each element of that array represents a resource and is a hash of key/value pairs corresponding to each properties of that resource.
    - In this example, in our condition block we check for each resource if it failed before. If not we check if is an application and if it is currently stopped. If so then we add it to the list of failed resource, and we trigger the event.

7. [**onEvent**](http://mytestbed.net/projects/omf6/wiki/OEDLOMF6#onEvent) (line 55-61). This command declares the set of actions to perform when a specific event is triggered. In this example, the event is our previously defined "APP_EXITED". The actions to perform in this case is to select a backup resource and start its ping application. There is another **onEvent** declaration further (line 68-74), for the event "APP_UP_AND_INSTALLED", i.e. when all resources are ready to receive commands and all applications associated to them are installed. When this event triggers, we start the ping application on the resources within the 'Initial_Worker' group, then after 60 seconds we stop all applications and terminate the experiment trial.

8. [**defGraph**](http://mytestbed.net/projects/omf6/wiki/OEDLOMF6#defGraph) (line 76-83). This commands defines the graphs that will be displayed while the experiment trial is running. In this example, we define 1 graph showing the RTT values from the ping applications against time for each resources in our experiment. This graph will be drawn using measurements enabled in the previous defGroup blocks.


# Step 2 - Execute

- After reviewing this OEDL experiment description, drag-and-drop it from the "Prepare" panel to the "Execute" panel, as described on the [LabWiki introduction page]([http://groups.geni.net/geni/wiki/GEC21Agenda/OEDL/Introduction#Execute)
- Set the values of the properties 'res1' to 'res4' to the names of your allocated resources. Similarly set the 'Slice' property to your own slice.
(You can optionally decide to give a name to your experiment, if not LabWiki will assign a default unique name to it.)
- Click on the "Start Experiment" button. You will soon see output messages under the "Logging" section. Some of these messages are from the OMF Experiment Controller, which interprets your OEDL experiment description and sends corresponding commands to the resources. Other messages are from the resources themselves (either the VM nodes or the applications), reporting on configuration and command results.

![Experiment 1 Execute Screenshot](https://raw.githubusercontent.com/mytestbed/gec_demos_tutorial/master/gec21_oedl_tutorial/tutorial_1.fig3.png)

- Above that "Logging" section, you should soon see the graph, which we defined in the OEDL experiment description. It is drawn dynamically as measurements are collected from the resources.

![Experiment 1 Running Screenshot](https://raw.githubusercontent.com/mytestbed/gec_demos_tutorial/master/gec21_oedl_tutorial/tutorial_1.fig4.png)


# Step 3 - Finish

- A message in the "Execute" panel will appear to inform you that the experiment execution has finished. At this stage, you should have the complete graphs for this experiment in that panel, which should look as follows.

![Experiment 1 Result Screenshot](https://raw.githubusercontent.com/mytestbed/gec_demos_tutorial/master/gec21_oedl_tutorial/tutorial_1.fig5.png)

- You may interact to with these graphs, e.g. tick or un-tick the legend's keys to display only results from the first or/and second resource, hover the pointer above a graph point to display the underlying data point, drag-and-drop the graph via its icon to the "Plan" panel as described in the [LabWiki introduction page](http://groups.geni.net/geni/wiki/GEC21Agenda/OEDL/Introduction#Execute)

- The complete data set holding the measurements collected from this experiment is stored in an SQL database. You can retrieve a copy of that database by clicking on the 'Database Dump' buttom in the 'Execute' panel. The format of that copy is depends on your LabWiki's deployment configuration. It could be an iRODS dump, a Zipped archive of CSV files, a SQLite3 dump or a PostgreSQL dump. By default, it is a PostgreSQL dump.

![Database Dump](https://raw.githubusercontent.com/mytestbed/gec_demos_tutorial/master/gec21_oedl_tutorial/tutorial_1.fig6.png)

# Help & Additional Resources

 * [LabWiki quick guide](http://groups.geni.net/geni/wiki/GEC21Agenda/OEDL/Introduction)
 * [OEDL Reference Document](http://mytestbed.net/projects/omf6/wiki/OEDLOMF6)
 * [GEC21 GIMI and Labwiki Tutorial](http://groups.geni.net/geni/wiki/GEC21Agenda/LabWiki)
 * [OMF6 Documentation](http://mytestbed.net/projects/omf6/wiki/Wiki)
 * [OML Documentation](http://oml.mytestbed.net/projects/oml/wiki)
