

require 'em-zeromq'

Thread.abort_on_exception = true

class Handler
  attr_accessor :request
  
  def on_readable(connection, message)
    @request = message.map(&:copy_out_string).join
    message.each { |part| part.close }
    puts "Received #{@request}/#{ZMQ::Util.errno}"
    
    EM.add_timer(0.01) { connection.register_writable }
  end
  
  def on_writable(connection)
    message = @request.match(/[0-9]+/).to_a[0]
    @request = nil
    
    message = "World: #{message}"
    return_value = connection.send_msg message
    puts "Sent #{message} #{return_value}/#{ZMQ::Util.errno}"
    EM.next_tick { connection.register_readable }
  end
  
  def unbind(connection)
    puts "Unbound!"
  end
end

EM.epoll
EM.run do
  @context = EM::ZeroMQ::Context.new(1)

  # Socket to talk to server
  puts "Connecting to hello world server..."
  @responder = @context.bind(ZMQ::REP, "tcp://*:8742", Handler.new)
  @responder.identity = "server"
  @responder.notify_writable = false
  puts "Connected"

  EM.next_tick { @responder.register_readable }
end