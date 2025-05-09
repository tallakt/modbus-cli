require 'spec_helper'



describe Modbus::Cli::WriteCommand do
	include OutputCapture

  before(:each) do
    stub_tcpip
  end

  it 'can write to registers' do
    _client, slave = standard_connect_helper 'HOST', 502
    slave.should_receive(:write_holding_registers).with(100, [1, 2, 3, 4])
    cmd.run %w(write HOST %MW100 1 2 3 4)
  end


  it 'can write floating point numbers' do
    _client, slave = standard_connect_helper 'HOST', 502
    slave.should_receive(:write_holding_registers).with(100, [52429, 17095, 52429, 17095])
    cmd.run %w(write HOST %MF100 99.9 99.9)
  end

  it 'can write double word numbers' do
    _client, slave = standard_connect_helper 'HOST', 502
    slave.should_receive(:write_holding_registers).with(100, [16959, 15, 16959, 15])
    cmd.run %w(write HOST %MD100 999999 999999)
  end

  it 'can write to coils' do
    _client, slave = standard_connect_helper 'HOST', 502
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
    _client, slave = standard_connect_helper 'HOST', 502
    slave.should_receive(:write_holding_registers).with(100, (1..123).to_a)
    slave.should_receive(:write_holding_registers).with(223, (124..150).to_a)
    cmd.run %w(write HOST %MW100) + (1..150).to_a
  end

  it 'should split large writes in chunks for coils' do
    _client, slave = standard_connect_helper 'HOST', 502
    slave.should_receive(:write_multiple_coils).with(100, [0, 1] * 400)
    slave.should_receive(:write_multiple_coils).with(900, [0, 1] * 400)
    slave.should_receive(:write_multiple_coils).with(1700, [0, 1] * 200)
    cmd.run %w(write HOST %M100) + [0, 1] * 1000
  end

  it 'can write to registers as ints' do
    _client, slave = standard_connect_helper 'HOST', 502
    slave.should_receive(:write_holding_registers).with(100, [0xffff])
    cmd.run %w(write --int HOST %MW100 -1)
  end

  it 'can write to registers as floats' do
    _client, slave = standard_connect_helper 'HOST', 502
    slave.should_receive(:write_holding_registers).with(100, [52429, 17095])
    cmd.run %w(write --float HOST %MW100 99.9)
  end

  it 'can write to registers as double words' do
    _client, slave = standard_connect_helper 'HOST', 502
    slave.should_receive(:write_holding_registers).with(100, [16959, 15])
    cmd.run %w(write --dword HOST %MW100 999999)
  end

  it 'can write to registers as words' do
    _client, slave = standard_connect_helper 'HOST', 502
    slave.should_receive(:write_holding_registers).with(100, [99])
    cmd.run %w(write --word HOST %MF100 99)
  end

  it 'can write to registers using Modicon addressing' do
    _client, slave = standard_connect_helper 'HOST', 502
    slave.should_receive(:write_holding_registers).with(100, [1, 2, 3, 4])
    cmd.run %w(write HOST 400101 1 2 3 4)
  end

  it 'can write to coils using Modicon addressing' do
    _client, slave = standard_connect_helper 'HOST', 502
    slave.should_receive(:write_multiple_coils).with(100, [1, 0, 1, 0, 1, 0, 0, 1, 1])
    cmd.run %w(write HOST 101 1 0 1 0 1 0 0 1 1)
  end

  it 'has a --slave parameter' do
    client = double 'client'
    ModBus::TCPClient.should_receive(:connect).with('X', 502).and_yield(client)
    client.should_receive(:with_slave).with(99)
    cmd.run %w(write --slave 99 X 101 1)
  end

  it 'has a --debug flag' do
    _client, slave = standard_connect_helper 'HOST', 502
    slave.should_receive(:debug=).with(true)
    slave.should_receive(:write_multiple_coils)
    cmd.run %w(write --debug HOST 101 1)
  end

  it 'has a --timeout flag' do
    _client, slave = standard_connect_helper 'HOST', 502
    slave.should_receive(:read_retry_timeout=).with(99)
    slave.should_receive(:write_multiple_coils)
    cmd.run %w(write --timeout 99 HOST 101 1)
  end

  it 'has a --connect-timeout flag' do
    ModBus::TCPClient.should_receive(:connect).with('X', 502, {connect_timeout: 99})
    cmd.run %w(write --connect-timeout 99 X %MW100 10)
  end
end





