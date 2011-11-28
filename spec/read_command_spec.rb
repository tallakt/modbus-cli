require 'spec_helper'



describe Modbus::Cli::ReadCommand do
	include OutputCapture

  before(:each) do
    stub_tcpip
  end

  it 'can read registers' do
    client, slave = standard_connect_helper '1.2.3.4'
    slave.should_receive(:read_holding_registers).with(100, 10).and_return((0..9).to_a)
    cmd.run %w(read 1.2.3.4 %MW100 10)
    stdout.should match(/^\s*%MW105\s*5$/)
  end

  it 'can read coils' do
    client, slave = standard_connect_helper '1.2.3.4'
    slave.should_receive(:read_coils).with(100, 10).and_return([1, 0] * 5)
    cmd.run %w(read 1.2.3.4 %M100 10)
    stdout.should match(/^\s*%M105\s*0$/)
  end


  it 'rejects illegal counts' do
    lambda { cmd.run %w(read 1.2.3.4 %MW100 1+0) }.should raise_exception(Clamp::UsageError)
    lambda { cmd.run %w(read 1.2.3.4 %MW100 -10) }.should raise_exception(Clamp::UsageError)
  end

  it 'rejects illegal addresses' do
    lambda { cmd.run %w(read 1.2.3.4 %MW1+00) }.should raise_exception(Clamp::UsageError)
  end

  it 'should split large reads into smaller chunks for words' do
    client, slave = standard_connect_helper '1.2.3.4'
    slave.should_receive(:read_holding_registers).with(100, 125).and_return([1, 0] * 1000)
    slave.should_receive(:read_holding_registers).with(225, 25).and_return([1, 0] * 1000)
    cmd.run %w(read 1.2.3.4 %MW100 150)
  end

  it 'should split large reads into smaller chunks for coils' do
    client, slave = standard_connect_helper '1.2.3.4'
    slave.should_receive(:read_coils).with(100, 2000).and_return([1, 0] * 1000)
    slave.should_receive(:read_coils).with(2100, 1000).and_return([1, 0] * 500)
    cmd.run %w(read 1.2.3.4 %M100 3000)
  end
end





