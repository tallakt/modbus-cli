require 'clamp'

# do it this way to not have serialport warning on startup
# require 'rmodbus'
require 'rmodbus/errors'
require 'rmodbus/ext'
require 'rmodbus/debug'
require 'rmodbus/options'
require 'rmodbus/rtu'
require 'rmodbus/tcp'
require 'rmodbus/slave'
require 'rmodbus/client'
require 'rmodbus/server'
require 'rmodbus/tcp_slave'
require 'rmodbus/tcp_client'
require 'rmodbus/tcp_server'

require 'modbus-cli/version'
require 'modbus-cli/read_command'
require 'modbus-cli/write_command'
require 'modbus-cli/dump_command'

module Modbus
  module Cli
    DEFAULT_SLAVE = 1

    class CommandLineRunner < Clamp::Command
      subcommand 'read', 'read from the device', ReadCommand
      subcommand 'write', 'write to the device', WriteCommand
      subcommand 'dump', 'copy contents of read file to the device', DumpCommand
    end
  end
end
