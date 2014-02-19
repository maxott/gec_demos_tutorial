# Experiment 3

## Overview

The goal of this third and final part of the tutorial is to demonstrate how easy it is to scale your OEDL experiment up to use more resources.

The scenario of this experiment is similar to the [previous part 2 experiment](http://groups.geni.net/geni/wiki/GEC18Agenda/LabWikiAndOEDL/Experiment2), except that this time we will use more peers, i.e. up to 10 or 20 depending on the available resources on the current ExoGENI Racks for each group of attendees and hopefully around 50 or more for the tutorial presenters. In this experiment, we will also collect the same measurements as in the [previous part 2 experiment](http://groups.geni.net/geni/wiki/GEC18Agenda/LabWikiAndOEDL/Experiment2).

<img src="https://raw.github.com/mytestbed/gec_demos_tutorial/master/part3/exp3_overview.png">

As you will see below, running this scaled-up experiment is almost identical to running the original small-scale one, we just need to set more resources to a couple of OEDL experiment properties.

## Part 1 - Design/Setup

For help on all actions regarding LabWiki, please refer to the [LabWiki and OEDL introduction page](http://groups.geni.net/geni/wiki/GEC18Agenda/LabWikiAndOEDL/Introduction)

**The OEDL experiment description**

* Duplicate the [previous part 2 OEDL experiment description](http://groups.geni.net/geni/wiki/GEC18Agenda/LabWikiAndOEDL/Experiment2) into a new experiment description file for this third part of the tutorial

**Walk-through the above OEDL experiment description**

 * As we are using the same OEDL experiment description as in the [part 2 experiment](http://groups.geni.net/geni/wiki/GEC18Agenda/LabWikiAndOEDL/Experiment2), please refer to [the part 2 'walk-through' section](http://groups.geni.net/geni/wiki/GEC18Agenda/LabWikiAndOEDL/Experiment2#Part1-DesignSetup)

## Part 2 - Execute

1. After saving the above OEDL experiment description, drag-and-drop it from the "Prepare" column to the "Execute" column, as described on the [LabWiki introduction page]([http://groups.geni.net/geni/wiki/GEC18Agenda/LabWikiAndOEDL/Introduction#Execute)
2. Set the value of the property *slice* to the pre-allocated slice number which was assigned to you.
3. Now set the list of leecher_player to include more resources than previously (e.g. 1,2,3,4)
4. Similarly set the list of seeders to include more resources than previously (e.g. 5,6,7,8,9)
  * NOTE: a resource that was previously used as a leecher_player in a previous experiment run must have completed downloaded the full video to be able to be a seeder in a subsequent run, i.e. to avoid cluttering the experiment description we did not include tasks to ensure that seeders do indeed have the complete video before starting the other tasks.

<img src="https://raw.github.com/mytestbed/gec_demos_tutorial/master/part3/labwiki_exp3_1.png">

 5. Click on the "Start Experiment" button. You will shortly see output messages under the "Logging" section and later graphs being drawn under the "Graphs" section.

<img src="https://raw.github.com/mytestbed/gec_demos_tutorial/master/part3/labwiki_exp3_2.png">
<img src="https://raw.github.com/mytestbed/gec_demos_tutorial/master/part3/labwiki_exp3_3.png">

## Part 3 - Finish

 1. A message in the "Execute" column will appear to inform you that the experiment execution has finished. At this stage, you should have the complete graphs for this experiment at the bottom of that column, which should be look like below depending on the number of resources you set as leecher_players or seeders.

<img src="https://raw.github.com/mytestbed/gec_demos_tutorial/master/part3/labwiki_exp3_4.png">

 2. We now encourage you to read more about [OEDL](http://mytestbed.net/projects/omf6/wiki/OEDLOMF6) and start writing your own experiments with it, and execute them on GENI Rack Resources using LawbWiki!


## Help & Additional Resources

 * [LabWiki quick guide](http://groups.geni.net/geni/wiki/GEC18Agenda/LabWikiAndOEDL/Introduction)
 * [OEDL Reference Document](http://mytestbed.net/projects/omf6/wiki/OEDLOMF6)
 * [Getting Started with GENI and the GENI Portal - Part III - GIMI](http://groups.geni.net/geni/wiki/GEC18Agenda/GettingStartedWithGENI_III_GIMI)
 * [OMF6 Documentation](http://mytestbed.net/projects/omf6/wiki/Wiki)
 * [OML Documentation](http://oml.mytestbed.net/projects/oml/wiki)
