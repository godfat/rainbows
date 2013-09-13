# -*- encoding: binary -*-
# :enddoc:
class Rainbows::EventMachineThreadDefer::Client <
      Rainbows::EventMachine::ThreadClient

  def app_dispatch
    EM.defer(method(:app_response), method(:response_write))
  end
end
