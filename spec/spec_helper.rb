require 'rspec'
require 'clamp'
require 'stringio'
require 'modbus-cli'

# Borrowed from Clamp tests
module OutputCapture

  def self.included(target)
    target.before do
      $stdout = @out = StringIO.new
      $stderr = @err = StringIO.new
    end
    target.after do
      $stdout = STDOUT
      $stderr = STDERR
    end
  end

  def stdout
    @out.string
  end

  def stderr
    @err.string
  end



end

def stub_tcpip
  TCPSocket.stub!(:new) # prevent comms with actual PLC or device
end


def standard_connect_helper(address, port)
  client = mock 'client'
  slave = mock 'slave'
  ModBus::TCPClient.should_receive(:connect).with(address, port).and_yield(client)
  client.should_receive(:with_slave).with(1).and_yield(slave)
  return client, slave
end


def cmd
 Modbus::Cli::CommandLineRunner.new('modbus-cli') 
end
