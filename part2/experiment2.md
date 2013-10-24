# Experiment 2

## Overview

The goal of this second part of the tutorial is to showcase a realistic research experiment.

A researcher developed a new algorithm which allows the [BitTorrent file sharing protocol](http://en.wikipedia.org/wiki/BitTorrent) to be used to stream videos. She implemented her algorithm into the 'transmission' BitTorrent software, and would like to evaluate that prototype. This algorithm is based on the work:

["Toward efficient on-demand streaming with bittorrent"](http://www.nicta.com.au/pub?doc=3428).
Y. Borghol  NICTA, S. Ardon, N. Carlsson, A. Mahanti.
NETWORKING'10 Proceedings of the 9th IFIP TC 6 international conference on Networking, 2010.

The scenario of this simple experiment involves 4 ExoGENI virtual machine resources

* one resource will be a [seed](http://en.wikipedia.org/wiki/BitTorrent#Operation), i.e. a BitTorrent peer which has the complete video file available and shares it with others
* one resource will be a [tracker](http://en.wikipedia.org/wiki/BitTorrent#Operation), i.e. an entity that maintain a list of peers interested in the video file
* two resources act as [leechers](http://en.wikipedia.org/wiki/BitTorrent#Operation),  i.e. a BitTorrent peer which are downloading the video file. These two leechers will run the modified BitTorrent transmission software, which includes the researcher's algorithm (aka SBT, Streaming BitTorrent). In addition, they will each also run a VLC player software, which will play the video as it is being received by the peer.  

<img src="https://raw.github.com/mytestbed/gec18-tutorial/master/part2/exp2_overview.png">

In this experiment scenario, we will collect the following measurements:
  * from the modified BitTorrent transmission client running on each peer, we will collect the upload rate, the download rate, and the percentage of completion for the video file
  * from the VLC player running on the leechers, we will collect the amount of decoded, lost and played video frame

## Part 1 - Design/Setup 

For help on all actions regarding LabWiki, please refer to the [LabWiki and OEDL introduction page](http://groups.geni.net/geni/wiki/GEC18Agenda/LabWikiAndOEDL/Introduction)

**The OEDL experiment description**

1. First, if you have not done it yet, login into LabWiki

2. Create a new experiment file with the name of your choice

3.  Cut-and-paste the following OEDL experiment description into that file, then save it

        defProperty('slice', 'oedl-', "slice name")
        defProperty('tracker', "0", "ID of tracker node")
        defProperty('leecher_player', "1,2", "List of leecher/player nodes")
        defProperty('seeder', "3", "List of seeder nodes")
        defProperty('upload', 2500, 'Maximum torrent upload speed in kb/s')

        tracker = property.tracker.to_s.split(',').map { |x| "#{x}-#{property.slice}" }
        leecher_player = property.leecher_player.to_s.split(',').map { |x| "#{x}-#{property.slice}" }
        seeder = property.seeder.value.to_s.split(',').map { |x| "#{x}-#{property.slice}" }
        allresources = tracker + leecher_player + seeder

        defApplication('clean_all') do |app|
          app.description = 'Some commands to ensure that we start with a clean slate'
          app.binary_path = 'killall -s9 bttrack transmission-daemon vlc; rm -f /root/.config/transmission-daemon/settings.json; '
          app.quiet = true
        end

        defApplication('clean_leechers') do |app|
          app.description = 'Ensure that leechers do not have the file to download'
          app.binary_path = 'rm -f /root/Downloads/* /root/.config/transmission-daemon/resume/* /root/.config/transmission-daemon/torrents/*'
          app.quiet = true
        end

        defApplication('bttrack') do |app|
          app.description = 'Bittornado BT tracker'
          app.binary_path = '/usr/bin/bttrack'
          app.defProperty('dfile', 'Database file', '--dfile', {:type => :string})
          app.defProperty('port', 'Port number', '--port', {:type => :integer})  
          app.quiet = true
        end

        defApplication('transmission_daemon') do |app|
          app.description = 'bittorrent client with video streaming support'
          app.binary_path = '/usr/local/bin/transmission-daemon'
          app.defProperty('foreground', 'Run in foreground', '-f', {:type => :boolean})
          app.quiet = true
          app.defMeasurement("stats") do |mp|
            mp.defMetric('tor_id', :int32)
            mp.defMetric('tor_name', :string)
            mp.defMetric('dl_rate', :double)
            mp.defMetric('ul_rate', :double)
            mp.defMetric('percent_done', :double)
          end
        end

        defApplication('vlc') do |app|
          app.description = 'VideoLAN client media player'
          app.binary_path = 'usr/local/bin/vlc.sh'
          app.defProperty('vstream', 'URL to play stream from', nil, {:type => :string})
          app.quiet = true
          app.defMeasurement("video") do |mp|
            mp.defMetric('i_decoded_video_blocks', :int32)
            mp.defMetric('i_played_video_frames', :int32)
            mp.defMetric('i_lost_video_frames', :int32)
          end
        end

        defGroup('tracker', *tracker) do |g|
          g.addApplication("bttrack") do |app|
            app.setProperty('dfile', "/tmp/dfile_#{Time.now.to_i}")
            app.setProperty('port', 6969)
          end
        end

        defGroup('seeder', *seeder) do |g|
          g.addApplication("transmission_daemon") do |app|
            app.setProperty('foreground', true)
            app.measure('stats', :samples => 1)
          end
        end

        defGroup('leecher', *leecher_player) do |g|
          g.addApplication("transmission_daemon") do |app|
            app.setProperty('foreground', true)
            app.measure('stats', :samples => 1)
          end
        end

        defGroup('player', *leecher_player) do |g|
          g.addApplication("vlc") do |app|
            app.setProperty('vstream', "http://localhost:8080/big_buck_bunny_480p_stereo.avi?tor_url=http://192.168.1.1/big_buck_bunny_480p_stereo.avi.torrent")
            app.measure('video', :samples => 1)
          end
        end

        defGroup('all_resources', *allresources) do |g|
          g.addApplication("clean_all")
        end

        defGroup('all_leechers', *leecher_player) do |g|
          g.addApplication("clean_leechers")
        end

        onEvent(:ALL_UP_AND_INSTALLED) do |event|
          group("all_leechers").startApplications
          group("all_resources").startApplications
          after 10 do
            info "Starting tracker"
            group("tracker").startApplications
          end
          after 15 do
           info "Starting seeders"
           group("seeder").startApplications
           info "Starting leechers"
           group("leecher").startApplications
          end
          after 20 do
            # set the upload speed limit
            allGroups.exec("/usr/local/bin/transmission-remote -u #{property.upload.value}")
          end
          after 25 do
            info "Starting players"
            group("player").startApplications
          end
          after 220 do
            group("all_resources").startApplications
            Experiment.done
          end
        end

        defGraph 'Bittorrent' do |g|
          g.ms('stats').select {[ :oml_sender_id, :oml_seq, :oml_ts_server, :percent_done ]}
          g.caption "Bittorrent (torrent completion)"
          g.type 'line_chart3'
          g.mapping :x_axis => :oml_ts_server, :y_axis => :percent_done, :group_by => :oml_sender_id
          g.xaxis :legend => 'time [s]'
          g.yaxis :legend => 'Completion', :ticks => {:format => 's'}
        end

        defGraph 'VLC Player' do |g|
          g.ms('video').select {[ :oml_sender_id, :oml_seq, :oml_ts_server, :i_played_video_frames ]}
          g.caption "VLC Player (frames played)"
          g.type 'line_chart3'
          g.mapping :x_axis => :oml_ts_server, :y_axis => :i_played_video_frames, :group_by => :oml_sender_id
          g.xaxis :legend => 'time [s]'
          g.yaxis :legend => 'Frames played', :ticks => {:format => 's'}
        end

**Walk-through the above OEDL experiment description**

1. Here we define some experiment properties, which will allow us to parameterize the values for the slice, the resources, and the application settings used in the experiment. As mentioned earlier, these values may be customized for each experiment run. Compared to the previous first simple experiment, here we further declare variables (internal to the experiment descriptions), which facilitate our specific use of properties within this given experiment example.

          defProperty('slice', 'oedl-', "slice name")
          ...

          tracker = property.tracker.to_s.split(',').map { |x| "#{x}-#{property.slice}" }
          ... 
2. Then we declare the applications that we will use in this experiment. Similar to the previous first experiment, we use the [defApplication command](http://mytestbed.net/projects/omf6/wiki/OEDLOMF6#defApplication) for these declarations.
  * The first two applications are bundles of command lines which ensure that no processes or created files from previous experiment runs remain
  * The third application is the modified and instrumented BitTorrent prototype which we would like to evaluate. This application has been instrumented with [OML](http://oml.mytestbed.net) and provides statistics about downloaded content
  * Finally the last application is the instrumented VLC player, which we will use to assess the efficiency of the prototype. This application is also OML-instrumented and provides information about the played video content

          defApplication('clean_all') do |app|
          ...
          end

          defApplication('clean_leechers') do |app|
          ...
          end
          ...
3. Compared to the previous experiment, here we are setting the attribute *quiet* of the application to *true*. This tells the resource controller which starts and monitors the application to log any application outputs locally, thus they will not be reported in Labwiki's Execute column.

          defApplication('clean_all') do |app|
             ...
            app.quiet = true
          end
4. We follow with the definition of the groups of resources, which we will use in this experiment
  * tracker: this group includes a single resource, which will act as the BitTorrent tracker for the other resources. We associate a *bttrack* application to this group, and set the parameter properties for that application.
  * seeder: this group holds the resources which will seed the video content to the other resources. Thus it has a transmission daemon application associated to it, with the correct parameter set.
  * leecher: this group contains the resources which will download the video content from other peers. It also has an associated transmission daemon application (modified to include the streaming algorithm extension)
  * player: this group has the same resources as the previous leecher groups and differs only by its associated application, which in this case is the VLC player, configured with the URI of the video content to play.
  * allresources: this group includes all resources used in this experiment, and is used to make sure that any previous application instances from previous experiment runs are terminated at the beginning of this particular run.
  * all_leechers: this groups contains the same resources as the leecher group, and is used to ensure that no previously downloaded content remains on these peers before they start their current download.

          defGroup('tracker', *tracker) do |g|
            ...
          end

          defGroup('seeder', *seeder) do |g|
            ...
          end
          ...
5. We then define the tasks to perform at time **t** when all the resources and declared applications in all the defined groups are ready. The time offsets below are in seconds.
  * t: we start the cleaning applications on all the leechers and all the resources
  * t+10: we start the tracker application on the tracker resource
  * t+15: we start the modified BitTorrent applications on the peers (i.e. seeders and leechers)
  * t+20: we limit the upload rate on all the peers. Note that here we are using the *exec* OEDL command, which allows you to request the execution of a shell command on a group of resources.
  * t+25: we start the VLC application on the peers downloading the video content
  * we let the experiment run until t+220, when we perform another cleaning task before terminating the experiment run
6. Finally at the end of this file, we declare the graphs that LabWiki should plot while the experiment is running. In this second example, we are interested in 2 graphs.
  a. The first graph shows the download completion (as a percentage) for the video content for all peers as a function of time
  b. The second graph shows the number of continuous frame played by the VLC player agains the time throughout the experiment execution

## Part 2 - Execute

1. After saving the above OEDL experiment description, drag-and-drop it from the "Prepare" column to the "Execute" column, as described on the [LabWiki introduction page]([http://groups.geni.net/geni/wiki/GEC18Agenda/LabWikiAndOEDL/Introduction#Execute)

2. Set the value of the property *slice* to the pre-allocated slice number which was assigned to you.

<img src="https://raw.github.com/mytestbed/gec18-tutorial/master/part2/labwiki_exp2_1.png">

3. Click on the "Start Experiment" button. You will shortly see output messages under the "Logging" section. Some of these messages are from the OMF Experiment Controller, which is interpreting your OEDL experiment description and sending corresponding commands to the resources. Other messages are from the resources themselves (either the VM nodes or the applications), reporting on configuration and command results. 

<img src="https://raw.github.com/mytestbed/gec18-tutorial/master/part2/labwiki_exp2_3.png">

4. If you scroll down below the "Logging" section or if you collapse it, you should see the graphs defined in the OEDL experiment description being drawn dynamically as measurements are collected from the resources.

<img src="https://raw.github.com/mytestbed/gec18-tutorial/master/part2/labwiki_exp2_4.png">


## Part 3 - Finish

1. A message in the "Execute" column will appear to inform you that the experiment execution has finished. At this stage, you should have the complete graphs for this experiment at the bottom of that column, which should look as follows.

<img src="https://raw.github.com/mytestbed/gec18-tutorial/master/part2/labwiki_exp2_5.png">

2. From these 2 graphs, we can see that as the video content is downloaded by the modified BitTorrent application on the leechers, the VLC players running on the same resources report a continuously increasing number of of frames being played. The relatively 'smooth' linear increase in these numbers indicate that the players never ran out of continuous frames to play. This demonstrate that the modified !BitTorrent application is suitable for video streaming.


## Help & Additional Resources

 * [LabWiki quick guide](http://groups.geni.net/geni/wiki/GEC18Agenda/LabWikiAndOEDL/Introduction)
 * [OEDL Reference Document](http://mytestbed.net/projects/omf6/wiki/OEDLOMF6)
 * [Getting Started with GENI and the GENI Portal - Part III - GIMI](http://groups.geni.net/geni/wiki/GEC18Agenda/GettingStartedWithGENI_III_GIMI)
 * [OMF6 Documentation](http://mytestbed.net/projects/omf6/wiki/Wiki)
 * [OML Documentation](http://oml.mytestbed.net/projects/oml/wiki)