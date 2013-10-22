#!/usr/bin/env ruby
for i in (1..9)
  spawn "echo #{i}: `timeout -2 80 omf_ec -u xmpp://emmy9.casa.umass.edu exec test.rb -- --slice cdw_#{i} | grep ALL_NODES_UP` >> nodes.out"
end
Process.waitall
system "sort nodes.out -g; rm nodes.out"