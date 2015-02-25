# Thanks to @minhajuddin for the template
# http://minhajuddin.com/2010/06/06/redirector-a-simple-rack-application-which-makes-redirection-of-multiple-domains-a-breeze
#
require 'yaml'

class Redirector

  PREFIX = "net_"
  @@config = YAML::load(File.open('/root/web-redirector/config.yaml'))

  def self.config
    @@config
  end

  def call(env)
    redirect_info = get_redirect_info(env['REMOTE_ADDR'])
    puts "-- #{Time.now} -- Host: #{env['REMOTE_ADDR']} -- Redirect: #{redirect_info['location']}"
    [redirect_info['status'], {'Content-Type' => 'text','Location' => redirect_info['location']}, get_host_response( redirect_info ) ]
    #['200', {'Content-Type' => 'text/html'}, ['get rack\'d']]
  end

  private
  def get_host_response(redirect_info)
    ["#{redirect_info['status']} moved. The document has moved to #{redirect_info['location']}"]
  end

  def get_redirect_info(host)
    (0..3).each do |i|
      net = PREFIX+host.split('.')[0,(4-i)].join('_')
      return @@config[net] unless @@config[net].nil?
    end
    return @@config['default']
  end
end
