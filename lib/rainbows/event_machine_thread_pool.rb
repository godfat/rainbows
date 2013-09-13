# -*- encoding: binary -*-

module Rainbows::EventMachineThreadPool
  autoload :Client, 'rainbows/event_machine_thread_pool/client'
  extend  Rainbows::PoolSize
  include Rainbows::EventMachine

  def init_worker_threads(queue) # :nodoc:
    Rainbows::O[:pool_size].times.map do
      Thread.new do
        begin
          client = queue.pop
          response = client.app_response
          EM.next_tick { client.response_write(response) }
        rescue => e
          Rainbows::Error.listen_loop(e)
        end while Rainbows.alive
      end
    end
  end

  def init_worker_process(worker)
    queue = Client.const_set(:QUEUE, Queue.new)
    threads = init_worker_threads(queue)
    logger.info "EventMachineThreadPool pool_size=#{Rainbows::O[:pool_size]}"
    super
  end
end
