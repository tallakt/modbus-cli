require 'modbus-cli/commands_common'
require 'yaml'

module Modbus
  module Cli
    class DumpCommand < Clamp::Command
      extend CommandsCommon::ClassMethods
      include CommandsCommon

      parameter 'FILES ...', 'restore data in FILES to original devices (created by modbus read command)', :attribute_name => :files do |f|
        f.map do |filename| 
          YAML.load_file(filename).dup.tap do |ff|
            #parameter takes presedence
            ff[:host] = host || ff[:host]
            ff[:slave] = slave || ff[:slave]
            ff[:offset] = offset || ff[:offset]
          end
        end
      end

      option ["-h", "--host"], 'ADDR', "use the address/hostname ADDR instead of the stored one"

      option ["-s", "--slave"], 'ID', "use slave ID instead of the stored one" do |s|
        Integer(s).tap {|slave| raise ArgumentError 'Slave address should be in the range 0..255' unless (0..255).member? slave }
      end

      option ["-o", "--offset"], 'OFFSET', "start writing at address OFFSET instead of original location" do |o|
        raise ArgumentError 'Illegal offset address: ' + o unless modicon_match(o) || schneider_match(o)
        o
      end

      def execute
        host_ids = files.map {|d| d[:host] }.sort.uniq
        host_ids.each {|host_id| execute_host host_id }
      end

      def execute_host(host_id)
        slave_ids =   files.select {|d| d[:host] == host_id }.map {|d| d[:slave] }.sort.uniq
        ModBus::TCPClient.connect(host_id) do |client|
          slave_ids.each {|slave_id| execute_slave host_id, slave_id, client }
        end
      end

      def execute_slave(host_id, slave_id, client)
        client.with_slave(slave_id) do |slave|
            files.select {|d| d[:host] == host_id && d[:slave] == slave_id }.each do |file_data|
            execute_single_file slave, file_data
          end
        end
      end

      def execute_single_file(slave, file_data)
        address = modicon_match(file_data[:offset].to_s) || schneider_match(file_data[:offset].to_s)
        case address[:datatype]
        when :bit
          sliced_write_coils slave, address[:offset], file_data[:data]
        when :word
          sliced_write_registers slave, address[:offset], file_data[:data]
        end
      end
    end
  end
end

