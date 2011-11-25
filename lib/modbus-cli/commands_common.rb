module Modbus
  module Cli
    module CommandsCommon
      DEFAULT_SLAVE = 1

      def host_parameter
        parameter 'HOST', 'IP address or hostname for the Modbus device', :attribute_name => :host
      end


      def address_parameter
        parameter 'ADDRESS', 'Start address, in Schneider format (eg %M100, %MW100)', :attribute_name => :address do |a|
          m = a.match /%M(W)?(\d+)/i
          raise ArgumentError, "Illegal address #{a}" unless m
          {:offset => m[2].to_i, :datatype => (if m[1] then :word else :bit end)}
        end
      end


    end
  end
end

