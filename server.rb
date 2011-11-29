

require 'ffi-rzmq'

context = ZMQ::Context.new(1)

# Socket to talk to server
puts "Connecting to hello world server..."
responder = context.socket(ZMQ::REP)
responder.bind("tcp://*:5555")
puts "Connected"

loop do
  message = ""
  return_code = responder.recv_string message
  puts "Received: #{message} #{return_code}/#{ZMQ::Util.errno}"
  
  response = "World #{message.match(/[0-9]+/).to_a[0]}"
  sleep 0.01
  
  return_code = responder.send_string response
  puts "Sent: #{response} #{return_code}/#{ZMQ::Util.errno}"
end
