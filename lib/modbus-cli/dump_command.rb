require 'modbus-cli/commands_common'

module Modbus
  module Cli
    class DumpCommand < Clamp::Command
      extend CommandsCommon::ClassMethods
      include CommandsCommon
    end
  end
end

