require 'modbus-cli/commands_common'

module Modbus
  module Cli
    class ReadCommand < Clamp::Command
      extend CommandsCommon::ClassMethods
      include CommandsCommon

      MAX_READ_COIL_COUNT = 2000
      MAX_READ_WORD_COUNT = 125

      host_parameter
      address_parameter
      
      parameter 'COUNT', 'number of data to read', :attribute_name => :count do |c|
        result = Integer(c)
        raise ArgumentError, 'Count must be positive' if result <= 0
        result

      end

      def read_floats(slave)
        floats = read_and_unpack(slave, 'g')
        (0...count).each do |n|
          puts "%MF#{ '%-7d' % (addr_offset + n * data_size)} #{nice_float('% 16.8f' % floats[n])}"
        end
      end

      def read_dwords(slave)
        dwords = read_and_unpack(slave, 'N')
        (0...count).each do |n|
          puts "%MD#{ '%-7d' % (addr_offset + n * data_size)} #{'%10d' % dwords[n]}"
        end
      end

      def read_registers(slave)
        read_range.zip(read_data_words(slave)).each do |pair|
          puts "%MW#{ '%-7d' % pair.first} #{'%6d' % pair.last}"
        end
      end

      def read_coils(slave)
        read_range.each_slice(MAX_READ_COIL_COUNT) do |slice|
          values = slave.read_coils(slice.first, slice.count)
          slice.zip(values).each do |pair|
            puts "%M#{ '%-7d' % pair.first} #{'%d' % pair.last}"
          end
        end
      end

      def execute
        ModBus::TCPClient.connect(host) do |cl|
          cl.with_slave(DEFAULT_SLAVE) do |sl|
            case addr_type
            when :bit
              read_coils(sl)
            when :word
              read_registers(sl)
            when :float
              read_floats(sl)
            when :dword
              read_dwords(sl)
            end
          end
        end
      end

      def read_and_unpack(slave, format)
        # the word ordering is wrong. calling reverse two times effectively swaps every pair
        read_data_words(slave).reverse.pack('n*').unpack("#{format}*").reverse
      end

      def read_data_words(slave)
        result = []
        read_range.each_slice(MAX_READ_WORD_COUNT) {|slice| result += slave.read_holding_registers(slice.first, slice.count) }
        result
      end

      def read_range
        (addr_offset..(addr_offset + count * data_size - 1))
      end


      def nice_float(str)
        m = str.match /(.*[.][0-9])0*/
        if m
          m[1]
        else
          str
        end
      end
    end
  end
end


