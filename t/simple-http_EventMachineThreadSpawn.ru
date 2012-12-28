use Rack::ContentLength
use Rack::ContentType
run lambda { |env|
  if env['rack.multithread'] == true &&
     env['rainbows.model'] == :EventMachineThreadSpawn
    [ 200, {}, [ env.inspect << "\n" ] ]
  else
    raise "rack.multithread is false"
  end
}
