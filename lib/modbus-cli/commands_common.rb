module Modbus
  module Cli
    module CommandsCommon
      
      MAX_WRITE_COILS = 1968
      MAX_WRITE_WORDS = 123
      DEFAULT_SLAVE = 1

      module ClassMethods

        def host_parameter
          parameter 'HOST', 'IP address or hostname for the Modbus device', :attribute_name => :host
        end


        def address_parameter
          parameter 'ADDRESS', 'Start address (eg %M100, %MW100, 101, 400101)', :attribute_name => :address do |a|
            schneider_match(a) || modicon_match(a) || raise(ArgumentError, "Illegal address #{a}")
          end
        end

        def datatype_options
          option ["-w", "--word"], :flag, "use unsigned 16 bit integers"
          option ["-i", "--int"], :flag, "use signed 16 bit integers"
          option ["-d", "--dword"], :flag, "use unsigned 32 bit integers"
          option ["-f", "--float"], :flag, "use signed 32 bit floating point values"
        end

        def format_options
          option ["--modicon"], :flag, "use Modicon addressing (eg. coil: 101, word: 400001)"
          option ["--schneider"], :flag, "use Schneider addressing (eg. coil: %M100, word: %MW0, float: %MF0, dword: %MD0)"
        end

        def slave_option
          option ["-s", "--slave"], 'ID', "use slave id ID", :default => 1 do |s|
            Integer(s).tap {|slave| raise ArgumentError 'Slave must be in the range 0..255' unless (0..255).member?(slave) }
          end
        end

        def host_option
          option ["-p", "--port"], 'PORT', "use TCP port", :default => 502
        end

        def output_option
        end

        def debug_option
          option ["-D", "--debug"], :flag, "show debug messages"
        end
      end


      def data_size
        case addr_type
        when :bit, :word, :int
          1
        when :float, :dword
          2
        end
      end


      def addr_offset
        address[:offset]
      end

      def addr_type
        if int?
          :int
        elsif dword?
          :dword
        elsif float?
          :float
        elsif word?
          :word
        else
          address[:datatype]
        end
      end


      def schneider_match(address)
        schneider_match =  address.match /%M([FWD])?(\d+)/i
        if schneider_match
          {:offset => schneider_match[2].to_i, :format => :schneider}.tap do |result|
            case schneider_match[1]
            when nil
              result[:datatype] = :bit
            when 'W', 'w'
              result[:datatype] = :word
            when 'F', 'f'
              result[:datatype] = :float
            when 'D', 'd'
              result[:datatype] = :dword
            end
          end
        end
      end


      def modicon_match(address)
        if address.match /^\d+$/ 
          offset = address.to_i
          case offset
          when 1..99999
            {:offset => offset - 1, :datatype => :bit, :format => :modicon}
          when 400001..499999
            {:offset => offset - 400001, :datatype => :word, :format => :modicon}
          end
        end
      end

      def addr_format
        if schneider?
          :schneider
        elsif modicon?
          :modicon
        else
          address[:format]
        end
      end

      def sliced_write_registers(sl, offset, data)
        (0..(data.count - 1)).each_slice(MAX_WRITE_WORDS) do |slice|
          result = sl.write_holding_registers(slice.first + offset, data.values_at(*slice))
        end
      end

      def sliced_write_coils(sl, offset, data)
        (0..(data.count - 1)).each_slice(MAX_WRITE_COILS) do |slice|
          result = sl.write_multiple_coils(slice.first + offset, data.values_at(*slice))
        end
      end

    end
  end
end

