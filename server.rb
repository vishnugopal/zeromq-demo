

require 'ffi-rzmq'

context = ZMQ::Context.new(1)

# Socket to talk to server
puts "Connecting to hello world server..."
responder = context.socket(ZMQ::REP)
responder.bind("tcp://*:5555")
puts "Connected"

loop do
  request = responder.recv_string ''
  
  sleep 1
  
  responder.send_string "World"
end
