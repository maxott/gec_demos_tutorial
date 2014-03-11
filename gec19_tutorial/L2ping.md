#Example: Writing an OML Layer 2 Ping Application (aka pingPlus)#

##Prerequisites##
Setup your experiment as shown here with this pingPlus package [download tar](http://www.gpolab.bbn.com/experiment-support/gec17/pingPlus/pingPlus_v3.tar.gz):

http://groups.geni.net/geni/wiki/Tutorials/ICDCS2013/GettingStartedWithGENI_I/Procedure/DesignSetup



##Write your Application##

To write a omlified ping application, we can firstly parse output to get Measurement points:

	def process_output(row)
	  if not (parse= /RQ:'(?<pktsnt1>\d*)\+(?<pktsnt2>\d*)' to (?<host>[a-f0-9:]*)/.match(row)).nil?
	  puts "ReturnQual #{parse[:pktsnt1]}\n" 
	  MPrt.inject(parse[:pktsnt1], parse[:pktsnt2],parse[:host])
	  
	  elsif not (parse= /RL:(?<numofpkt1>\d*)\+(?<numofpkt2>\d*)=(?<totpktrec>\d*) from (?<dest_hw_addr>[a-f0-9:]*)/.match(row)).nil?
	  puts "ReturnLength\n"
	  p parse
	  p MPrl.inject(parse[:numofpkt1],parse[:numofpkt2],parse[:totpktrec],parse[:dest_hw_addr]) 
	  
	  elsif not (parse = /RTT = (?<rtt>[0-9.]*)/.match(row)).nil?
	  puts "RoundTripTime #{parse[:rtt]}\n"
	  p parse
	  p MPrtt.inject(parse[:rtt])
	  end
	end

Then write the whole application script:

	#!/usr/bin/ruby1.9.1
	require 'rubygems'
	require 'oml4r'
	
	class MPrt < OML4R::MPBase
	   name :pingrt
	   param :pktsnt1, :type => :uint64
	   param :pktsnt2, :type => :uint64
	   param :host, :type => :string
	end
	
	class MPrl < OML4R::MPBase
	   name :pingrl
	   param :totpktrec, :type => :uint64
	   param :numofpkt1, :type => :uint64
	   param :numofpkt2, :type => :uint64
	   param :dest_hw_addr, :type => :string
	end
	
	class MPrtt < OML4R::MPBase
	   name :pingrtt
	   param :rtt, :type => :double
	end
	
	class Pingl2Wrapper
	
	  def initialize(args)
	     @addr = nil
	     @if_num = ''
	     @eth = nil
	     @verbose = true
	     @numeric = ''
	     
	     leftover = OML4R::init(args, :appName => 'pingl2') do |argParser|
	       argParser.banner = "Runs layer 2 ping and reports measurements via OML\n\n"
	       argParser.on("-a" , "--dest_hw_addr ADDRESS", "Hardware address to ping (the -a switch is optional)"){ |address| @addr = address.to_s() }
	       argParser.on("-i","--interface IFNUM","Interface number"){ |if_num| @if_num ="#{if_num.to_i()}" }
	       argParser.on("-e", "--eth ETHTYPE","Ethernet Type") { |ethtype| @eth = ethtype.to_s() }
	       argParser.on("-c","--count NUMBER","Number of pings (default: infinite)"){ |count| @count = "#{count.to_i()}"}
	       argParser.on("-q", "--no-quiet ","Don't show layer 2 ping output on console"){ @verbose = false }
	       argParser.on("-n", "--[no]-numeric ", "No attempt twill be made to look up symbolic names for host addresses"){ @numeric ='-n' }
	    end
	    
	    if @addr.nil?
	      if leftover.length > 0
	        @addr = leftover [0]
	      else
	        raise "You did not specify an address to ping!"
	      end
	    end
	    
	end
	
	def process_output(row)
	  if not (parse= /RQ:'(?<pktsnt1>\d*)\+(?<pktsnt2>\d*)' to (?<host>[a-f0-9:]*)/.match(row)).nil?
	  puts "ReturnQual #{parse[:pktsnt1]}\n" 
	  MPrt.inject(parse[:pktsnt1], parse[:pktsnt2],parse[:host])
	  
	  elsif not (parse= /RL:(?<numofpkt1>\d*)\+(?<numofpkt2>\d*)=(?<totpktrec>\d*) from (?<dest_hw_addr>[a-f0-9:]*)/.match(row)).nil?
	  puts "ReturnLength\n"
	  p parse
	  p MPrl.inject(parse[:numofpkt1],parse[:numofpkt2],parse[:totpktrec],parse[:dest_hw_addr]) 
	  
	  elsif not (parse = /RTT = (?<rtt>[0-9.]*)/.match(row)).nil?
	  puts "RoundTripTime #{parse[:rtt]}\n"
	  p parse
	  p MPrtt.inject(parse[:rtt])
	  end
	end
	  
	def pingl2()
	   @pingio = IO.popen("/bin/pingPlus #{@addr} #{@eth} #{@if_num} #{@count}")
	   while true
	    row = @pingio.readline
	    puts row if @verbose
	    process_output(row)
	    end
	end
	
	def start()
	    return if not @pingio.nil?
	    
	    # handle for OMF's exit command
	    a = Thread.new do
	      $stdin.each do |line|
	    if /^exit/ =~ line
	      Process.kill("INT",0)    
	    end
	      end
	    end
	    
	    # Handle Ctrl+C and OMF's SIGTERM
	    Signal.trap("INT", stop)
	    Signal.trap("TERM", stop)
	    
	    begin
	      pingl2
	    rescue EOFError
	    
	    end
	end
	
	def stop()
	   return if @pingio.nil?
	   # Kill the ping process, which will result in EOFError from ping()
	   Process.kill("INT", @pingio.pid)
	end
	
	end
	begin
	  $stderr.puts "INFO\tpingl2 2.11.0\n"
	  app = Pingl2Wrapper.new(ARGV)
	  app.start()
	  sleep 1
	rescue Interrupt
	rescue Exception => ex
	   $stderr.puts "Error\t#{ex}\n"
	end
	
	
	
	# Local Variables:
	# mode:ruby  
	# End:
	# vim: ft=ruby:sw=2

##Test your Application##
Finally write OEDL Script to test application:

	defProperty('source1', "client-testpingplus", "ID of a resource")
	#defProperty('source2', "ig-utah-testBBN", "ID of a resource")
	#defProperty('source3', "nodeC-createexoimage", "ID of a resource")
	#defProperty('source4', "nodeD-createexoimage", "ID of a resource")
	#defProperty('source5', "nodeE-createexoimage", "ID of a resource")
	defProperty('graph', true, "Display graph or not")
	
	
	defProperty('sinkaddr11', 'fe:16:3e:00:74:38', "Ping destination address")
	defProperty('eth11','eth1',"Output Eth interface")
	defProperty('sinkaddr12', 'fe:16:3e:00:74:38', "Ping destination address")
	
	#defProperty('sinkaddr11', '192.168.6.10', "Ping destination address")
	#defProperty('sinkaddr12', '192.168.5.12', "Ping destination address")
	
	#defProperty('sinkaddr21', '192.168.4.11', "Ping destination address")
	#defProperty('sinkaddr22', '192.168.2.12', "Ping destination address")
	#defProperty('sinkaddr23', '192.168.1.13', "Ping destination address")
	
	#defProperty('sinkaddr31', '192.168.5.11', "Ping destination address")
	#defProperty('sinkaddr32', '192.168.2.10', "Ping destination address")
	#defProperty('sinkaddr33', '192.168.3.13', "Ping destination address")
	#defProperty('sinkaddr34', '192.168.6.14', "Ping destination address")
	
	#defProperty('sinkaddr41', '192.168.1.10', "Ping destination address")
	#defProperty('sinkaddr42', '192.168.3.12', "Ping destination address")
	
	#defProperty('sinkaddr51', '192.168.6.12', "Ping destination address")
	
	defApplication('ping') do |app|
	  app.description = 'Simple Definition for the pingl2 application'
	  # Define the path to the binary executable for this application
	  app.binary_path = '/usr/local/bin/pingl2'
	  # Define the configurable parameters for this application
	  # For example if target is set to foo.com and count is set to 2, then the 
	  # application will be started with the command line:
	  # /usr/bin/ping-oml2 -a foo.com -c 2
	  app.defProperty('target', 'Address to ping', '-a', {:type => :string})
	  app.defProperty('count', 'Number of times to ping', '-c', {:type => :integer})
	  app.defProperty('if_num', 'interface number', '-i', {:type => :integer})
	  app.defProperty('eth', 'Ethernet Type', '-e', {:type => :string})
	  # Define the OML2 measurement point that this application provides.
	  # Here we have only one measurement point (MP) named 'ping'. Each measurement
	  # sample from this MP will be composed of a 4-tuples (addr,ttl,rtt,rtt_unit)
	  app.defMeasurement('ping') do |m|
	    m.defMetric('hw_dest_addr',:string)
	    m.defMetric('rtt',:double)
	  end
	end
	defGroup('Source1', property.source1) do |node|
	  node.addApplication("ping") do |app|
	    app.setProperty('target', property.sinkaddr11)
	    app.setProperty('count', 30)
	    app.setProperty('if_num', 10002)
	    app.setProperty('eth',property.eth11)
	    app.measure('ping', :samples => 1)
	  end
	end
	
	
	#defGroup('Source2', property.source2) do |node|
	 # node.addApplication("ping") do |app|
	  #  app.setProperty('target', property.sinkaddr11)
	   # app.setProperty('count', 30)
	    #app.setProperty('interval', 1)
	   # app.measure('ping', :samples => 1)
	  #end
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
	  g.ms('ping').select(:oml_seq, :hw_dest_addr, :rtt) 
	  g.caption "RTT of received packets."
	  g.type 'line_chart3'
	  g.mapping :x_axis => :oml_seq, :y_axis => :rtt, :group_by => :hw_dest_addr
	  g.xaxis :legend => 'oml_seq'
	  g.yaxis :legend => 'rtt', :ticks => {:format => 's'}
	end



##Troubleshooting##
To debug and test application manually on RC (resource controller):

Manually run the command and store data on any location in the RC (~/testpingnow.out) 

	env -i /usr/local/bin/pingl2 -a fe:16:3e:00:74:38 -c 5 -i 10002 -e eth1 --oml-id pingl2 --oml-domain tetspingl2 --oml-collect file:/home/dbhat/testpingnow.out

Contents of ~/testpingnow.out:

	protocol: 4
	content: text
	domain: tetspingl2
	start-time: 1387350654
	sender-id: pingl2
	app-name: pingl2
	schema: 0 _experiment_metadata subject:string key:string value:string
	schema: 1 pingl2_pingrt pktsnt1:integer pktsnt2:integer host:string
	schema: 2 pingl2_pingrl totpktrec:integer numofpkt1:integer numofpkt2:integer dest_hw_addr:string
	schema: 3 pingl2_pingrtt rtt:double
	
	0.008326062     1       1       8769    3486    fe:16:3e:0:74:38
	0.008561018     2       1       8769    3486    12255   fe:16:3e:0:74:38
	0.008747358     3       1       4.083984
	0.008879672     1       2       219     3026    fe:16:3e:0:74:38
	0.009011919     2       2       8769    3486    12255   fe:16:3e:0:74:38
	0.009165199     3       2       1.743896
	
