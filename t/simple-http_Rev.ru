use Rack::ContentLength
use Rack::ContentType
run lambda { |env|
  if env['rack.multithread'] == false && env['rainbows.model'] == :Rev
    [ 200, {}, [ env.inspect << "\n" ] ]
  else
    raise "rack.multithread is true"
  end
}
