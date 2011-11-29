module Modbus
  module Cli
    module CommandsCommon
      DEFAULT_SLAVE = 1
      module ClassMethods

        def host_parameter
          parameter 'HOST', 'IP address or hostname for the Modbus device', :attribute_name => :host
        end


        def address_parameter
          parameter 'ADDRESS', 'Start address, in Schneider format (eg %M100, %MW100)', :attribute_name => :address do |a|
            m = a.match /%M([FWD])?(\d+)/i
            raise ArgumentError, "Illegal address #{a}" unless m

            case m[1]
            when nil
              {:offset => m[2].to_i, :datatype => :bit}
            when 'W', 'w'
              {:offset => m[2].to_i, :datatype => :word}
            when 'F', 'f'
              {:offset => m[2].to_i, :datatype => :float}
            when 'D', 'd'
              {:offset => m[2].to_i, :datatype => :dword}
            end
          end
        end
      end



      def data_size
        case address[:datatype]
        when :bit, :word
          1
        when :float, :dword
          2
        end
      end


      def addr_offset
        address[:offset]
      end

      def addr_type
        address[:datatype]
      end


    end
  end
end

