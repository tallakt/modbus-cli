require 'spec_helper'



describe Modbus::Cli::WriteCommand do
	include OutputCapture

  before(:each) do
    stub_tcpip
  end

  it 'can write to registers' do
    client, slave = standard_connect_helper 'HOST'
    slave.should_receive(:write_holding_registers).with(100, [1, 2, 3, 4])
    cmd.run %w(write HOST %MW100 1 2 3 4)
  end

  it 'can write to coils' do
    client, slave = standard_connect_helper 'HOST'
    slave.should_receive(:write_multiple_coils).with(100, [1, 0, 1, 0, 1, 0, 0, 1, 1])
    cmd.run %w(write HOST %M100 1 0 1 0 1 0 0 1 1)
  end

  it 'rejects illegal values' do
    lambda { cmd.run %w(write 1.2.3.4 %MW100 10 tust) }.should raise_exception(Clamp::UsageError)
    lambda { cmd.run %w(write 1.2.3.4 %MW100 9999999) }.should raise_exception(Clamp::UsageError)
  end

  it 'rejects illegal addresses' do
    lambda { cmd.run %w(write 1.2.3.4 %MW1+00 ) }.should raise_exception(Clamp::UsageError)
  end


  it 'should split large writes in chunks for words' do
    client, slave = standard_connect_helper 'HOST'
    slave.should_receive(:write_holding_registers).with(100, (1..123).to_a)
    slave.should_receive(:write_holding_registers).with(223, (124..150).to_a)
    cmd.run %w(write HOST %MW100) + (1..150).to_a
  end

  it 'should split large writes in chunks for coils' do
    client, slave = standard_connect_helper 'HOST'
    slave.should_receive(:write_multiple_coils).with(100, (1..1968).to_a)
    slave.should_receive(:write_multiple_coils).with(2068, (1969..2000).to_a)
    cmd.run %w(write HOST %M100) + (1..2000).to_a
  end
end





