require 'modbus-cli/commands_common'

module Modbus
  module Cli
    class WriteCommand < Clamp::Command
      extend CommandsCommon::ClassMethods
      include CommandsCommon

      MAX_WRITE_COILS = 1968
      MAX_WRITE_WORDS = 123

      host_parameter
      address_parameter

      parameter 'VALUES ...', 'values to write, nonzero counts as true for discrete values', :attribute_name => :values do |vv|
        case addr_type

        when :bit
          int_parameter vv, 0, 1
        when :word
          int_parameter vv, 0, 0xffff
        when :dword
          int_parameter vv, 0, 0xffffffff
        when :float
          vv.map {|v| Float(v) }
        end
      end



      def execute
        ModBus::TCPClient.connect(host) do |cl|
          cl.with_slave(DEFAULT_SLAVE) do |sl|
            case addr_type
            when :bit
              write_coils sl
            when :word
              write_words sl
            when :float
              write_floats sl
            when :dword
              write_dwords sl
            end
          end
        end
      end

      def write_coils(slave)
        write_range.each_slice(MAX_WRITE_COILS) do |slice|
          result = slave.write_multiple_coils(slice.first + addr_offset, values.values_at(*slice))
        end
      end

      def write_words(slave)
        sliced_write_registers(slave, values)
      end

      def write_floats(slave)
        pack_and_write slave, 'g'
      end

      def write_dwords(slave)
        pack_and_write slave, 'N'
      end

      def sliced_write_registers(slave, data)
        write_range.each_slice(MAX_WRITE_WORDS) do |slice|
          result = slave.write_holding_registers(slice.first + addr_offset, data.values_at(*slice))
        end
      end

      def pack_and_write(slave, format)
        # the word ordering is wrong. calling reverse two times effectively swaps every pair
        sliced_write_registers(slave, values.reverse.pack("#{format}*").unpack('n*').reverse)
      end

      def write_range
        0..(values.count * data_size - 1)
      end

      def int_parameter(vv, min, max)
        vv.map {|v| Integer(v) }.tap do |values|
          values.each do |v|
            raise ArgumentError, "Value should be in the range #{min}..#{max}" unless (min..max).member? v
          end
        end
      end
    end
  end
end
