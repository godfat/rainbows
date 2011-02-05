# -*- encoding: binary -*-
# :enddoc:
require 'sleepy_penguin'
require 'sendfile'

# Edge-triggered epoll concurrency model.  This is extremely unfair
# and optimized for throughput at the expense of fairness
module Rainbows::Epoll
  include Rainbows::Base
  ReRun = []
  autoload :Server, 'rainbows/epoll/server'
  autoload :Client, 'rainbows/epoll/client'
  autoload :ResponsePipe, 'rainbows/epoll/response_pipe'
  autoload :ResponseChunkPipe, 'rainbows/epoll/response_chunk_pipe'

  def self.rerun
    while obj = ReRun.shift
      obj.epoll_run
    end
  end

  def init_worker_process(worker)
    super
    Rainbows::Epoll.const_set :EP, SleepyPenguin::Epoll.new
    Rainbows::Client.__send__ :include, Client
  end

  def worker_loop(worker) # :nodoc:
    init_worker_process(worker)
    Server.run
  end
end
