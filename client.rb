

require 'em-zeromq'
require 'em-synchrony'
require_relative 'handler'

Thread.abort_on_exception = true

EM.epoll
EM.synchrony do
  @context = EM::ZeroMQ::Context.new(1)

  @requester = @context.connect(ZMQ::REQ, "tcp://127.0.0.1:8742")
  @handler = Handler.new(@requester)
  
  count = 1
  loop do
    message = "Hello: #{count}"
    return_code = @requester.handler.send_message(message)
    
    puts "Sent #{message} #{return_code}/#{ZMQ::Util.errno}" if count % 1000 == 0
    
    message = @requester.handler.receive_message
    
    puts "Received #{message} #{ZMQ::Util.errno}" if count % 1000 == 0
    count += 1
  end
end
