nr = 1..20

puts '<rspec type="request" xsi:schemaLocation="http://www.geni.net/resources/rspec/3 http://www.geni.net/resources/rspec/3/request.xsd" xmlns:ns3="http://groups.geni.net/exogeni/attachment/wiki/RspecExtensions/slice-info/1" xmlns:flack="http://www.protogeni.net/resources/rspec/ext/flack/1" xmlns:client="http://www.protogeni.net/resources/rspec/ext/client/1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.geni.net/resources/rspec/3">'

nr.each {|n|
	puts "  <node client_id=\"#{n}\" component_manager_id=\"urn:publicid:IDN+exogeni.net+authority+am\" exclusive=\"true\">
    <sliver_type name=\"XOSmall\">
      <disk_image name=\"http://pkg.mytestbed.net/geni/deb7-64-p2p.xml\" version=\"59565a2e778d7791cf2847edca541110e08de501\"/>
    </sliver_type>
    <services>
      <execute command=\"chmod +x /deb7-64-p2p.postboot.sh; /deb7-64-p2p.postboot.sh $self.Name() $sliceName\" shell=\"sh\"/>
      <install install_path=\"/\" url=\"http://pkg.mytestbed.net/geni/deb7-64-p2p.postboot.sh\"/>
    </services>
    <interface client_id=\"#{n}:if0\">
      <ip address=\"192.168.1.#{n}\" netmask=\"255.255.255.0\" type=\"\"/>
    </interface>
  </node>"
}

puts '  <link client_id="link0">
    <component_manager name="urn:publicid:IDN+exogeni.net+authority+am"/>'

nr.each {|n|
	puts "    <interface_ref client_id=\"#{n}:if0\"/>"
	nr.each {|m|
		puts "    <property source_id=\"#{n}:if0\" dest_id=\"#{m}:if0\"/>" if m!=n
	}
}

puts '  </link>
</rspec>'