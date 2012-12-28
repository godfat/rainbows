# -*- encoding: binary -*-
require 'eventmachine'
EM::VERSION >= '0.12.10' or abort 'eventmachine 0.12.10 is required'

# Implements a basic single-threaded event model with
# {EventMachine}[http://rubyeventmachine.com/].  It is capable of
# handling thousands of simultaneous client connections, but with only
# a single-threaded app dispatch.  It is suited for slow clients,
# and can work with slow applications via asynchronous libraries such as
# {async_sinatra}[http://github.com/raggi/async_sinatra],
# {Cramp}[http://cramp.in/],
# and {rack-fiber_pool}[http://github.com/mperham/rack-fiber_pool].
#
# It does not require your Rack application to be thread-safe,
# reentrancy is only required for the DevFdResponse body
# generator.
#
# Compatibility: Whatever \EventMachine ~> 0.12.10 and Unicorn both
# support, currently Ruby 1.8/1.9.
#
# This model is compatible with users of "async.callback" in the Rack
# environment such as
# {async_sinatra}[http://github.com/raggi/async_sinatra].
#
# For a complete asynchronous framework,
# {Cramp}[http://cramp.in/] is fully
# supported when using this concurrency model.
#
# This model is fully-compatible with
# {rack-fiber_pool}[http://github.com/mperham/rack-fiber_pool]
# which allows each request to run inside its own \Fiber after
# all request processing is complete.
#
# Merb (and other frameworks/apps) supporting +deferred?+ execution as
# documented at Rainbows::EventMachine::TryDefer
#
# This model does not implement as streaming "rack.input" which allows
# the Rack application to process data as it arrives.  This means
# "rack.input" will be fully buffered in memory or to a temporary file
# before the application is entered.
#
# === RubyGem Requirements
#
# * event_machine 0.12.10
module Rainbows::EventMachine
  autoload :ResponsePipe, 'rainbows/event_machine/response_pipe'
  autoload :ResponseChunkPipe, 'rainbows/event_machine/response_chunk_pipe'
  autoload :TryDefer, 'rainbows/event_machine/try_defer'
  autoload :Client, 'rainbows/event_machine/client'
end
# :enddoc:
require 'rainbows/event_machine/server'
require 'rainbows/event_machine/core'
Rainbows::EventMachine.__send__ :include, Rainbows::EventMachine::Core
