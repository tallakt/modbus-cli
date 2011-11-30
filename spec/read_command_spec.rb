require 'spec_helper'
require 'yaml'



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


  it 'can read floating point numbers' do
    client, slave = standard_connect_helper '1.2.3.4'
    slave.should_receive(:read_holding_registers).with(100, 4).and_return([52429, 17095, 52429, 17095])
    cmd.run %w(read 1.2.3.4 %MF100 2)
    stdout.should match(/^\s*%MF102\s*99[.]9(00[0-9]*)?$/)
  end

  it 'can read double word numbers' do
    client, slave = standard_connect_helper '1.2.3.4'
    slave.should_receive(:read_holding_registers).with(100, 4).and_return([16959, 15, 16959, 15])
    cmd.run %w(read 1.2.3.4 %MD100 2)
    stdout.should match(/^\s*%MD102\s*999999$/)
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
    lambda { cmd.run %w(read 1.2.3.4 %MW100 9.9) }.should raise_exception(Clamp::UsageError)
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

  it 'can read registers as ints' do
    client, slave = standard_connect_helper '1.2.3.4'
    slave.should_receive(:read_holding_registers).with(100, 1).and_return([0xffff])
    cmd.run %w(read --int 1.2.3.4 %MW100 1)
    stdout.should match(/^\s*%MW100\s*-1$/)
  end

  it 'can read registers as floats' do
    client, slave = standard_connect_helper '1.2.3.4'
    slave.should_receive(:read_holding_registers).with(100, 2).and_return([0,0])
    cmd.run %w(read --float 1.2.3.4 %MW100 1)
  end

  it 'can read registers as dwords' do
    client, slave = standard_connect_helper '1.2.3.4'
    slave.should_receive(:read_holding_registers).with(100, 2).and_return([0,0])
    cmd.run %w(read --dword 1.2.3.4 %MW100 1)
  end

  it 'can read registers as words' do
    client, slave = standard_connect_helper '1.2.3.4'
    slave.should_receive(:read_holding_registers).with(100, 1).and_return([0])
    cmd.run %w(read --word 1.2.3.4 %MD100 1)
  end

  it 'accepts Modicon addresses for coils' do
    client, slave = standard_connect_helper '1.2.3.4'
    slave.should_receive(:read_coils).with(100, 10).and_return([1, 0] * 5)
    cmd.run %w(read 1.2.3.4 101 10)
    stdout.should match(/^\s*106\s*0$/)
  end

  it 'accepts Modicon addresses for registers' do
    client, slave = standard_connect_helper '1.2.3.4'
    slave.should_receive(:read_holding_registers).with(100, 10).and_return((0..9).to_a)
    cmd.run %w(read 1.2.3.4 400101 10)
    stdout.should match(/^\s*400106\s*5$/)
  end


  it 'should accept the --modicon option to force modicon output' do
    client, slave = standard_connect_helper '1.2.3.4'
    slave.should_receive(:read_holding_registers).with(100, 10).and_return((0..9).to_a)
    cmd.run %w(read --modicon 1.2.3.4 %MW100 10)
    stdout.should match(/^\s*400106\s*5$/)
  end

  it 'should accept the --schneider option to force schneider output' do 
    client, slave = standard_connect_helper '1.2.3.4'
    slave.should_receive(:read_holding_registers).with(100, 10).and_return((0..9).to_a)
    cmd.run %w(read --schneider 1.2.3.4 400101 10)
    stdout.should match(/^\s*%MW105\s*5$/)
  end

  it 'has a --slave parameter' do
    client = mock 'client'
    ModBus::TCPClient.should_receive(:connect).with('X').and_yield(client)
    client.should_receive(:with_slave).with(99)
    cmd.run %w(read --slave 99 X 101 1)
  end

  it 'can write the output from reading registers to a yaml file using the -o <filename> parameter' do
    client, slave = standard_connect_helper '1.2.3.4'
    slave.should_receive(:read_holding_registers).with(100, 1).and_return([1])
    file_mock = mock('file')
    File.should_receive(:open).and_yield(file_mock)
    file_mock.should_receive(:puts).with({:host => '1.2.3.4', :slave => 1, :offset => '400101', :data => [1]}.to_yaml)
    cmd.run %w(read --output filename.yml 1.2.3.4 %MW100 1)
    stdout.should_not match(/./)
  end

  it 'can write the output from reading coils to a yaml file using the -o <filename> parameter' do
    client, slave = standard_connect_helper '1.2.3.4'
    slave.should_receive(:read_coils).with(100, 1).and_return([1])
    file_mock = mock('file')
    File.should_receive(:open).and_yield(file_mock)
    file_mock.should_receive(:puts).with({:host => '1.2.3.4', :slave => 1, :offset => '101', :data => [1]}.to_yaml)
    cmd.run %w(read --output filename.yml 1.2.3.4 %M100 1)
    stdout.should_not match(/./)
  end


end





