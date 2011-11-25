require 'spec_helper'



describe Modbus::Cli::CommandLineRunner do
	include OutputCapture

  before(:each) do
    stub_tcpip
  end

  it 'has help describing the read and write commands' do
    c = cmd
    Proc.new { c.run(%w(--help)) }.should raise_exception(Clamp::HelpWanted)
    c.help.should match /usage:/i
    c.help.should match /read/
    c.help.should match /write/
  end
end




