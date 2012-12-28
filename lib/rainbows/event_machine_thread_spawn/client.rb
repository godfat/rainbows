# -*- encoding: binary -*-
# :enddoc:
class Rainbows::EventMachineThreadSpawn::Client < Rainbows::EventMachine::Client
  def app_dispatch
    @deferred = true
    Thread.new{
      begin
        status, headers, body = catch(:async) {
          APP.call(@env.merge!(RACK_DEFAULTS))
        }
        if nil == status || -1 == status
          @deferred = true
        else
          @deferred = nil
          ev_write_response(status, headers, body, @hp.next?)
        end
      rescue Exception => e
        handle_error(e)
      end
    }
  end
end
