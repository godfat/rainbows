# -*- encoding: binary -*-
# A combination of the EventMachine and ThreadSpawn models.  This allows Ruby
# Thread-based concurrency for application processing.  It DOES NOT
# expose a streamable "rack.input" for upload processing within the
# app.  DevFdResponse should be used with this class to proxy
# asynchronous responses.  All network I/O between the client and
# server are handled by the main thread and outside of the core
# application dispatch.
#
# Unlike ThreadSpawn, EventMachine makes this model highly suitable for
# slow clients and applications with medium-to-slow response times
# (I/O bound), but less suitable for sleepy applications.
#
# This concurrency model is designed for Ruby 1.9, and Ruby 1.8
# users are NOT advised to use this due to high CPU usage.
#
# === RubyGem Requirements
#
# * event_machine 0.12.10
module Rainbows::EventMachineThreadSpawn
  # :stopdoc:
  autoload :Client, 'rainbows/event_machine_thread_spawn/client'
  #:startdoc:
  include Rainbows::EventMachine::Core
end
# :enddoc:
