require 'spec_helper'



describe Modbus::Cli::DumpCommand do
	include OutputCapture

  before(:each) do
    stub_tcpip
  end

  it 'reads the file to the stored device' do
    fail
  end

  it 'accepts the --host <hostname> parameter' do
    fail
  end

  it 'accepts the --slave <id> parameter' do
    fail
  end
end






