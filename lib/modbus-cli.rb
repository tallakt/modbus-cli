require "modbus-cli/version"
require 'clamp'

module Modbus
  module Cli

    class ReadCommand < Clamp::Command
      parameter 'HOST', 'IP address or hostname to the Modbus server', :attribute_name => :host
      parameter 'ADDRESS', 'Start address, in Schneider format (eg %M100, %MW100)', :attribute_name => :address do |a|
        m = a.match /%M(W)(\d+)/
        raise Clamp::UsageError "Illegal address #{a}" unless m
        {:offset => m[2].to_i, :datatype => (if m[1] then :word else :bit end)}
      end
      parameter 'COUNT', 'number of data to read', :attribute_name => :count

      def execute
        puts "reading from host: #{host} #{count} values starting from address #{address}"
      end
    end

    class WriteCommand < Clamp::Command
      parameter 'HOST', 'IP address or hostname to the Modbus server', :attribute_name => :host
      parameter 'ADDRESS', 'Start address, in Schneider format (eg %M100, %MW100)', :attribute_name => :address do |a|
        m = a.match /%M(W)(\d+)/
        raise Clamp::UsageError "Illegal address #{a}" unless m
        {:offset => m[2].to_i, :datatype => (if m[1] then :word else :bit end)}
      end
      parameter 'VALUES ...', 'values to write, nonzero counts as true for discrete values', :attribute_name => :values

      def execute
        puts "wrriting to host: #{host} #{values.join ", "} values starting from address #{address}"
      end
    end

    class CommandLineRunner < Clamp::Command
      self.default_subcommand = "read"

      subcommand 'read', 'read from the device', ReadCommand
      subcommand 'write', 'write to the device', WriteCommand
    end
  end
end
