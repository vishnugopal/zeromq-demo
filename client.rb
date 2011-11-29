

require 'ffi-rzmq'

context = ZMQ::Context.new(1)

# Socket to talk to server
puts "Connecting to hello world server..."
requester = context.socket(ZMQ::REQ)
requester.connect("tcp://127.0.0.1:5555")

request_number = 1
loop do
  puts "Sending request #{request_number}..."
  message = "Hello #{request_number}"
  return_code = requester.send_string message
  puts "Sent #{message} #{return_code}/#{ZMQ::Util.errno}"
  
  message = ""
  return_code = requester.recv_string message
  puts "Received #{message} #{return_code}/#{ZMQ::Util.errno}"
  
  request_number += 1
end
