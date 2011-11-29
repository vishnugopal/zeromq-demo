

require 'em-zeromq'

class Handler
  attr_accessor :counter
  
  def initialize
    @counter = 0
  end
  
  def on_readable(connection, message)
    puts "Received reply: #{message.map(&:copy_out_string)}"
    
    EM.add_timer(0.01) { connection.register_writable }
  end
  
  def on_writable(connection)
    @counter += 1
    message = "Hello #{counter}"
    return_value = connection.send_msg message
    puts "Sent message: #{message}"
    puts "Sent: #{return_value}/#{ZMQ::Util.errno}"
    
    EM.next_tick { connection.register_readable }
  end
end

EM.run do
  context = EM::ZeroMQ::Context.new(1)

  # Socket to talk to server
  puts "Connecting to hello world server..."
  
  handler = Handler.new
  requester = context.connect(ZMQ::REQ, "tcp://127.0.0.1:8742", handler)
  requester.identity = "client#{rand(100)}"
  requester.notify_writable = false
  
  EM.next_tick { requester.register_writable }
  
  EM.add_timer(10) { EM.stop }
end
