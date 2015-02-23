require './redirector'

use Rack::ContentLength

app = proc do |env|
  app = Redirector.new()
  status, headers, response = app.call(env)
  [ status, headers, response ] 
end

run app
