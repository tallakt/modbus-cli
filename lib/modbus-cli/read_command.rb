require 'modbus-cli/commands_common'

module Modbus
  module Cli
    class ReadCommand < Clamp::Command
      extend CommandsCommon

      host_parameter
      address_parameter
      
      parameter 'COUNT', 'number of data to read', :attribute_name => :count do |c|
        result = Integer(c)
        raise ArgumentError, 'Count must be positive' if result <= 0
        result

      end

      def read_registers(slave)
        read_range.each_slice(125) do |slice|
          values = slave.read_holding_registers(slice.first, slice.count)
          slice.zip(values).each do |pair|
            puts "%MW#{ '%-7d' % pair.first} #{'%6d' % pair.last}"
          end
        end
      end

      def read_coils(slave)
        read_range.each_slice(2000) do |slice|
          values = slave.read_coils(slice.first, slice.count)
          slice.zip(values).each do |pair|
            puts "%M#{ '%-7d' % pair.first} #{'%d' % pair.last}"
          end
        end
      end

      def execute
        ModBus::TCPClient.connect(host) do |cl|
          cl.with_slave(DEFAULT_SLAVE) do |sl|
            case address[:datatype]
            when :bit
              read_coils(sl)
            when :word
              read_registers(sl)
            end
          end
        end
      end

      def read_range
        (address[:offset]..(address[:offset] + count - 1))
      end
    end
  end
end


