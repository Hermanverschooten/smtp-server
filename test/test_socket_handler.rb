require 'minitest/autorun'
require 'smtp-server'
require 'net/smtp'
require 'byebug'

class TestSocketHandler < Minitest::Test
 
  HOST = '127.0.0.1'
  PORT = 10025
  
  class SmtpServerConnection < SMTP::Server::Connection

    def receive_sender(orig)
      puts orig
      @data = []
      true
    end

    def receive_recipient(rcpt)
      puts rcpt
      true
    end
    
    def receive_data_command
      @data = []
    end

    def receive_data_line(line)
      @data << line
    end

    def receive_message
      # reject message if it doesn't contain Hallo
      @data.join("\n") =~ /Hallo/
    end
  end
  
  def setup
    @thread = Thread.new do
      Thread.current.abort_on_exception = true
      server = TCPServer.new(HOST, PORT)
      SmtpServerConnection.handler(server.accept)
    end
    sleep 1  # wait for server to startup
  end
  
  def teardown
    @thread.join
  end
  
  def test_net_smtp_client
      smtp = Net::SMTP.new(HOST, PORT)
      smtp.set_debug_output $stderr
      smtp.start(Socket.gethostname) do
        smtp.send_mail("From: <maarten>\r\n\r\nHallo", 'foo@example.com', 'bar@example.com')
      end
  end
end
