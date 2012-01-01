require 'modbus-cli/commands_common'

module Modbus
  module Cli
    class WriteCommand < Clamp::Command
      extend CommandsCommon::ClassMethods
      include CommandsCommon


      datatype_options
      format_options
      slave_option
      host_parameter
      host_option
      address_parameter
      debug_option

      parameter 'VALUES ...', 'values to write, nonzero counts as true for discrete values', :attribute_name => :values do |vv|
        case addr_type

        when :bit
          int_parameter vv, 0, 1
        when :word
          int_parameter vv, 0, 0xffff
        when :int
          int_parameter vv, -32768, 32767
        when :dword
          int_parameter vv, 0, 0xffffffff
        when :float
          vv.map {|v| Float(v) }
        end
      end



      def execute
        ModBus::TCPClient.connect(host, port) do |cl|
          cl.with_slave(slave) do |sl|
            sl.debug = true if debug?

            case addr_type
            when :bit
              write_coils sl
            when :word, :int
              write_words sl
            when :float
              write_floats sl
            when :dword
              write_dwords sl
            end
          end
        end
      end

      def write_coils(sl)
        sliced_write_coils sl, addr_offset, values
      end

      def write_words(sl)
        sliced_write_registers sl, addr_offset, values.pack('S*').unpack('S*')
      end

      def write_floats(sl)
        pack_and_write sl, 'g'
      end

      def write_dwords(sl)
        pack_and_write sl, 'N'
      end

      def pack_and_write(sl, format)
        # the word ordering is wrong. calling reverse two times effectively swaps every pair
        sliced_write_registers(sl, addr_offset, values.reverse.pack("#{format}*").unpack('n*').reverse)
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
