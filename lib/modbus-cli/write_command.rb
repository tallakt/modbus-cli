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
            case address[:datatype]
            when :bit
              write_coils sl
            when :word
              write_words sl
            end
          end
        end
      end

      def write_coils(slave)
        write_range.each_slice(1968) do |slice|
          result = slave.write_multiple_coils(slice.first + address[:offset], values.values_at(*slice))
        end
      end

      def write_words(slave)
        write_range.each_slice(123) do |slice|
          result = slave.write_holding_registers(slice.first + address[:offset], values.values_at(*slice))
        end
      end

      def write_range
        0..(values.count - 1)
      end


    end
  end
end
