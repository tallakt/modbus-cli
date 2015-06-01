require 'rspec'
require 'clamp'
require 'stringio'
require 'modbus-cli'

# keep old fashioned should syntax for now, would be better to convert to new 
# syntax
RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.syntax = [:should, :expect]
  end
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end

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
  # prevent any real TCP communications
  allow(TCPSocket).to receive(:new).and_return("TCPSocket")
end


def standard_connect_helper(address, port)
  client = double 'client'
  slave = double 'slave'
  ModBus::TCPClient.should_receive(:connect).with(address, port).and_yield(client)
  client.should_receive(:with_slave).with(1).and_yield(slave)
  return client, slave
end


def cmd
 Modbus::Cli::CommandLineRunner.new('modbus-cli') 
end
