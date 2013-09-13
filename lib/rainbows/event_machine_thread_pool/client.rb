# -*- encoding: binary -*-
# :enddoc:
class Rainbows::EventMachineThreadPool::Client <
      Rainbows::EventMachine::ThreadClient

  # QUEUE constant will be set in worker_loop
  def app_dispatch
    QUEUE << self
  end
end
