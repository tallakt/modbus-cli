require 'spec_helper'



describe Modbus::Cli::ReadCommand do
	include OutputCapture

  before(:each) do
    stub_tcpip
  end

  it 'can read registers' do
    client, slave = standard_connect_helper '1.2.3.4'
    slave.should_receive(:read_holding_registers).with(100, 10).and_return((1..10).to_a)
    cmd.run %w(read 1.2.3.4 %MW100 10)
    stdout.should match(/^\s*%MW105\s*5$/)
  end

  it 'can read coils' do
    client, slave = standard_connect_helper '1.2.3.4'
    slave.should_receive(:read_multiple_coils).with(100, 10).and_return([1, 0] * 5)
    cmd.run %w(read 1.2.3.4 %M100 10)
    stdout.should match(/^\s*%M105\s*1$/)
  end


  it 'rejects illegal counts' do
    lambda { cmd.run %w(read 1.2.3.4 %MW100 1+0) }.should raise_exception(Clamp::UsageError)
    lambda { cmd.run %w(read 1.2.3.4 %MW100 -10) }.should raise_exception(Clamp::UsageError)
    lambda { cmd.run %w(read 1.2.3.4 %MW100 150) }.should raise_exception(Clamp::UsageError)
  end

  it 'rejects illegal addresses' do
    lambda { cmd.run %w(read 1.2.3.4 %MW1+00) }.should raise_exception(Clamp::UsageError)
  end
end





