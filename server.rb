

require 'em-zeromq'
require 'em-synchrony'
require_relative 'handler'

Thread.abort_on_exception = true

EM.epoll
EM.synchrony do
  @context = EM::ZeroMQ::Context.new(1)
  @responder = @context.bind(ZMQ::REP, "tcp://127.0.0.1:8742")
  @responder.notify_writable = false
  puts "Connected"
  
  loop do
    @responder.handler = Handler.new(@responder)
    request = @responder.handler.receive_message
    
    count = request.match(/[0-9]+/).to_a[0].to_i
    
    puts "Received #{request}/#{ZMQ::Util.errno}" if count % 1000 == 0
    response = "World: #{count}"
    
    return_value = @responder.handler.send_message(response)
    puts "Sent #{response} #{return_value}/#{ZMQ::Util.errno}" if count % 1000 == 0
  end
end
