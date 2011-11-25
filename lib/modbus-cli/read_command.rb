require 'modbus-cli/commands_common'

module Modbus
  module Cli
    class ReadCommand < Clamp::Command
      extend CommandsCommon

      host_parameter
      address_parameter
      
      parameter 'COUNT', 'number of data to read', :attribute_name => :count do |c|
        Integer(c)
      end


      def read_registers(slave)
        values = slave.read_holding_registers(address[:offset], count)
        (1..count).zip(values).each do |pair|
          puts "%MW#{ '%-7d' % (address[:offset] + pair.first)} #{'%6d' % pair.last}"
        end
      end

      def read_coils(slave)
        values = slave.read_coils(address[:offset], count)
        (1..count).zip(values).each do |pair|
          puts "%M#{ '%-7d' % (address[:offset] + pair.first)} #{'%d' % pair.last}"
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
    end
  end
end


