require 'modbus-cli/commands_common'

module Modbus
  module Cli
    class WriteCommand < Clamp::Command
      extend CommandsCommon

      host_parameter
      address_parameter

      parameter 'VALUES ...', 'values to write, nonzero counts as true for discrete values', :attribute_name => :values do |vv|
        values = vv.map {|v| Integer(v) }
        values.each do |v|
          raise Clamp::UsageError, 'Too small value' if v < -36863
          raise Clamp::UsageError, 'Too big value' if v > 36862
        end
        values
      end



      def execute
        ModBus::TCPClient.connect(host) do |cl|
          cl.with_slave(DEFAULT_SLAVE) do |sl|
            result = sl.write_holding_registers(address[:offset], values)
          end
        end
      end
    end
  end
end
