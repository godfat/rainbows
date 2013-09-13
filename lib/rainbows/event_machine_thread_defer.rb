# -*- encoding: binary -*-

module Rainbows::EventMachineThreadDefer
  autoload :Client, 'rainbows/event_machine_thread_defer/client'
  extend  Rainbows::PoolSize
  include Rainbows::EventMachine

  def init_worker_process(worker)
    EM.threadpool_size = Rainbows::O[:pool_size]
    logger.info "EventMachineThreadDefer pool_size=#{Rainbows::O[:pool_size]}"
    super
  end
end
