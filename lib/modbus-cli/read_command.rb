require 'modbus-cli/commands_common'
require 'yaml'

module Modbus
  module Cli
    class ReadCommand < Clamp::Command
      extend CommandsCommon::ClassMethods
      include CommandsCommon

      MAX_READ_COIL_COUNT = 2000
      MAX_READ_WORD_COUNT = 125

      datatype_options
      format_options
      slave_option
      host_parameter
      address_parameter
      option ["-o", "--output"], 'FILE', "write results to file FILE"
      
      parameter 'COUNT', 'number of data to read', :attribute_name => :count do |c|
        result = Integer(c)
        raise ArgumentError, 'Count must be positive' if result <= 0
        result

      end

      def read_floats(sl)
        floats = read_and_unpack(sl, 'g')
        (0...count).each do |n|
          puts "#{ '%-10s' % address_to_s(addr_offset + n * data_size)} #{nice_float('% 16.8f' % floats[n])}"
        end
      end

      def read_dwords(sl)
        dwords = read_and_unpack(sl, 'N')
        (0...count).each do |n|
          puts "#{ '%-10s' % address_to_s(addr_offset + n * data_size)} #{'%10d' % dwords[n]}"
        end
      end

      def read_registers(sl, options = {})
        data = read_data_words(sl)
        if options[:int]
          data = data.pack('S').unpack('s')
        end
        read_range.zip(data).each do |pair|
          puts "#{ '%-10s' % address_to_s(pair.first)} #{'%6d' % pair.last}"
        end
      end

      def read_words_to_file(sl)
        write_data_to_file(read_data_words(sl))
      end

      def read_coils_to_file(sl)
        write_data_to_file(read_data_coils(sl))
      end

      def write_data_to_file(data)
        File.open(output, 'w') do |file|
          file.puts({ :host => host, :slave => slave, :offset => address_to_s(addr_offset, :modicon), :data => data }.to_yaml)
        end
      end

      def read_coils(sl)
        data = read_data_coils(sl)
        read_range.zip(data) do |pair|
          puts "#{ '%-10s' % address_to_s(pair.first)} #{'%d' % pair.last}"
        end
      end

      def execute
        ModBus::TCPClient.connect(host) do |cl|
          cl.with_slave(slave) do |sl|
            if output then
              case addr_type
              when :bit
                read_coils_to_file(sl)
              else
                read_words_to_file(sl)
              end
            else
              case addr_type
              when :bit
                read_coils(sl)
              when :int
                read_registers(sl, :int => true)
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
      end

      def read_and_unpack(sl, format)
        # the word ordering is wrong. calling reverse two times effectively swaps every pair
        read_data_words(sl).reverse.pack('n*').unpack("#{format}*").reverse
      end

      def read_data_words(sl)
        result = []
        read_range.each_slice(MAX_READ_WORD_COUNT) {|slice| result += sl.read_holding_registers(slice.first, slice.count) }
        result
      end


      def read_data_coils(sl)
        result = []
        read_range.each_slice(MAX_READ_COIL_COUNT) do |slice|
          result += sl.read_coils(slice.first, slice.count)
        end
        result
      end

      def read_range
        (addr_offset..(addr_offset + count * data_size - 1))
      end


      def nice_float(str)
        m = str.match /^(.*[.][0-9])0*$/
        if m
          m[1]
        else
          str
        end
      end

      def address_to_s(addr, format = addr_format)
        case format
        when :schneider
          case addr_type
          when :bit
            '%M' + addr.to_s
          when :word, :int
            '%MW' + addr.to_s
          when :dword
            '%MD' + addr.to_s
          when :float
            '%MF' + addr.to_s
          end
        when :modicon
          case addr_type
          when :bit
            (addr + 1).to_s
          when :word, :int
            (addr + 400001).to_s
          end
        end
      end
    end
  end
end


