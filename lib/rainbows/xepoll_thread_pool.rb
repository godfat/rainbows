# -*- encoding: binary -*-
require "thread"
require "sleepy_penguin"
require "raindrops"

# This is an edge-triggered epoll concurrency model with blocking
# accept() in a (hopefully) native thread.  This is comparable to
# ThreadPool and CoolioThreadPool, but is Linux-only and able to exploit
# "wake one" accept() behavior of a blocking accept() call when used
# with native threads.
#
# This supports streaming "rack.input" and allows +:pool_size+ tuning
# independently of +worker_connections+
#
# === Disadvantages
#
# This is only supported under Linux 2.6 kernels.
#
# === Compared to CoolioThreadPool
#
# This does not buffer outgoing responses in userspace at all, meaning
# it can lower response latency to fast clients and also prevent
# starvation of other clients when reading slow disks for responses
# (when combined with native threads).
#
# CoolioThreadPool is likely better for trickling large static files or
# proxying responses to slow clients, but this is likely better for fast
# clients.
#
# Unlikely CoolioThreadPool, this supports streaming "rack.input" which
# is useful for reading large uploads from fast clients.
#
# This exposes no special API or extensions on top of Rack.
#
# === Compared to ThreadPool
#
# This can maintain idle connections without the memory overhead of an
# idle Thread.  The cost of handling/dispatching active connections is
# exactly the same for an equivalent number of active connections
# (but independently tunable).
#
# Since +:pool_size+ and +worker_connections+ is independently tunable,
# it is possible to get into situations where active connections need
# to wait for an idle thread in the thread pool before being processed

module Rainbows::XEpollThreadPool
  extend Rainbows::PoolSize

  # :stopdoc:
  include Rainbows::Base

  def init_worker_process(worker)
    super
    require "rainbows/xepoll_thread_pool/client"
    Rainbows::Client.__send__ :include, Client
  end

  def worker_loop(worker) # :nodoc:
    init_worker_process(worker)
    Client.loop
  end
  # :startdoc:
end
