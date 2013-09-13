# -*- encoding: binary -*-
# :enddoc:
class Rainbows::EventMachineThreadSpawn::Client <
      Rainbows::EventMachine::ThreadClient

  def app_dispatch
    Thread.new do
      response = app_response
      EM.next_tick { response_write(response) }
    end
  end
end
