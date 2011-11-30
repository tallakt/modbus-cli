require 'spec_helper'



describe Modbus::Cli::DumpCommand do
  before(:each) do
    stub_tcpip
  end

  it 'reads the file and write the contents to the original device' do
    client = mock 'client'
    slave = mock 'slave'
    YAML.should_receive(:load_file).with('dump.yml').and_return(:host => '1.2.3.4', :slave => 5, :offset => 400123, :data => [4, 5, 6])
    ModBus::TCPClient.should_receive(:connect).with('1.2.3.4').and_yield(client)
    client.should_receive(:with_slave).with(5).and_yield(slave)
    slave.should_receive(:write_holding_registers).with(122, [4, 5, 6])
    cmd.run %w(dump dump.yml)
  end

  it 'can read two files from separate hosts' do
    client1 = mock 'client1'
    client2 = mock 'client2'
    slave1 = mock 'slave1'
    slave2 = mock 'slave2'
    yml = {:host => 'X', :slave => 5, :offset => 400010, :data => [99]}
    YAML.should_receive(:load_file).with('a.yml').and_return(yml)
    YAML.should_receive(:load_file).with('b.yml').and_return(yml.dup.tap {|y| y[:host] = 'Y' })
    ModBus::TCPClient.should_receive(:connect).with('X').and_yield(client1)
    ModBus::TCPClient.should_receive(:connect).with('Y').and_yield(client2)
    client1.should_receive(:with_slave).with(5).and_yield(slave1)
    client2.should_receive(:with_slave).with(5).and_yield(slave2)
    slave1.should_receive(:write_holding_registers).with(9, [99])
    slave2.should_receive(:write_holding_registers).with(9, [99])
    cmd.run %w(dump a.yml b.yml)
  end

  it 'can dump two files from separate slaves on same host' do
    client1 = mock 'client1'
    slave1 = mock 'slave1'
    slave2 = mock 'slave2'
    yml = {:host => 'X', :slave => 5, :offset => 400010, :data => [99]}
    YAML.should_receive(:load_file).with('a.yml').and_return(yml)
    YAML.should_receive(:load_file).with('b.yml').and_return(yml.dup.tap {|y| y[:slave] = 99 })
    ModBus::TCPClient.should_receive(:connect).with('X').and_yield(client1)
    client1.should_receive(:with_slave).with(5).and_yield(slave1)
    client1.should_receive(:with_slave).with(99).and_yield(slave2)
    slave1.should_receive(:write_holding_registers).with(9, [99])
    slave2.should_receive(:write_holding_registers).with(9, [99])
    cmd.run %w(dump a.yml b.yml)
  end

  it 'can dump two files from one slave' do
    client1 = mock 'client1'
    slave1 = mock 'slave1'
    yml = {:host => 'X', :slave => 5, :offset => 400010, :data => [99]}
    YAML.should_receive(:load_file).with('a.yml').and_return(yml)
    YAML.should_receive(:load_file).with('b.yml').and_return(yml.dup)
    ModBus::TCPClient.should_receive(:connect).with('X').and_yield(client1)
    client1.should_receive(:with_slave).with(5).and_yield(slave1)
    slave1.should_receive(:write_holding_registers).with(9, [99])
    slave1.should_receive(:write_holding_registers).with(9, [99])
    cmd.run %w(dump a.yml b.yml)
  end

  it 'accepts the --host <hostname> parameter' do
    YAML.should_receive(:load_file).with('dump.yml').and_return(:host => '1.2.3.4', :slave => 5, :offset => 123, :data => [4, 5, 6])
    ModBus::TCPClient.should_receive(:connect).with('Y')
    cmd.run %w(dump --host Y dump.yml)
  end

  it 'accepts the --slave <id> parameter' do
    client = mock 'client'
    YAML.should_receive(:load_file).with('dump.yml').and_return(:host => '1.2.3.4', :slave => 5, :offset => 123, :data => [4, 5, 6])
    ModBus::TCPClient.should_receive(:connect).with('1.2.3.4').and_yield(client)
    client.should_receive(:with_slave).with(99)
    cmd.run %w(dump --slave 99 dump.yml)
  end

  it 'accepts the --offset <n> parameter with modicon addressing' do
    client = mock 'client'
    slave = mock 'slave'
    YAML.should_receive(:load_file).with('dump.yml').and_return(:host => '1.2.3.4', :slave => 5, :offset => 123, :data => [4, 5, 6])
    ModBus::TCPClient.should_receive(:connect).with('1.2.3.4').and_yield(client)
    client.should_receive(:with_slave).with(5).and_yield(slave)
    slave.should_receive(:write_holding_registers).with(100, [4, 5, 6])
    cmd.run %w(dump --offset 400101 dump.yml)
  end

  it 'accepts the --offset <n> parameter with schneider addressing' do
    client = mock 'client'
    slave = mock 'slave'
    YAML.should_receive(:load_file).with('dump.yml').and_return(:host => '1.2.3.4', :slave => 5, :offset => 123, :data => [4, 5, 6])
    ModBus::TCPClient.should_receive(:connect).with('1.2.3.4').and_yield(client)
    client.should_receive(:with_slave).with(5).and_yield(slave)
    slave.should_receive(:write_holding_registers).with(100, [4, 5, 6])
    cmd.run %w(dump --offset %MW100 dump.yml)
  end
end






