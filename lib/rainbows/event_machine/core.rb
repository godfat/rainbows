
module Rainbows::EventMachine::Core
  include Rainbows::Base

  # Cramp (and possibly others) can subclass Rainbows::EventMachine::Client
  # and provide the :em_client_class option.  We /don't/ want to load
  # Rainbows::EventMachine::Client in the master process since we need
  # reloadability.
  def em_client_class
    case klass = Rainbows::O[:em_client_class]
    when Proc
      klass.call # e.g.: proc { Cramp::WebSocket::Rainbows }
    when Symbol, String
      eval(klass.to_s) # Object.const_get won't resolve multi-level paths
    else # @use should be either :EventMachine or :NeverBlock
      Rainbows.const_get(@use).const_get(:Client)
    end
  end

  # runs inside each forked worker, this sits around and waits
  # for connections and doesn't die until the parent dies (or is
  # given a INT, QUIT, or TERM signal)
  def worker_loop(worker) # :nodoc:
    init_worker_process(worker)
    server = Rainbows.server
    server.app.respond_to?(:deferred?) and
      server.app = Rainbows::EventMachine::TryDefer.new(server.app)

    # enable them both, should be non-fatal if not supported
    EM.epoll
    EM.kqueue
    logger.info "#@use: epoll=#{EM.epoll?} kqueue=#{EM.kqueue?}"
    client_class = em_client_class
    max = worker_connections + LISTENERS.size
    Rainbows::EventMachine::Server.const_set(:MAX, max)
    Rainbows::EventMachine::Server.const_set(:CL, client_class)
    Rainbows::EventMachine::Client.const_set(:APP, Rainbows.server.app)
    EM.run {
      conns = EM.instance_variable_get(:@conns) or
        raise RuntimeError, "EM @conns instance variable not accessible!"
      Rainbows::EventMachine::Server.const_set(:CUR, conns)
      Rainbows.at_quit do
        EM.next_tick { conns.each_value { |c| client_class === c and c.quit } }
      end
      EM.add_periodic_timer(1) do
        EM.stop if ! Rainbows.tick && conns.empty? && EM.reactor_running?
      end
      LISTENERS.map! do |s|
        EM.watch(s, Rainbows::EventMachine::Server) do |c|
          c.notify_readable = true
        end
      end
    }
  end
end
