require "minuteman/keys_methods"
require "minuteman/bit_operations/data"

# Public: Minuteman core classs
#
class Minuteman
  module BitOperations
    # Public: The class to handle operations with datasets
    #
    #   type:       The operation type
    #   data:       The data to be permuted
    #   source_key: The original key to do the operation
    #
    class WithData < Struct.new(:type, :data, :source_key)
      extend Forwardable
      include KeysMethods

      def_delegators :Minuteman, :redis, :safe

      def call
        puts "WithData"
        key = destination_key("data-#{type}", normalized_data)
        puts "data-#{type}"
        if !safe { redis.exists(key) }
          puts "key#{key}"
          intersected_data.each do  |id|
            puts "id#{id}"
            safe { redis.setbit(key, id, 1) }

          end
        end

        Data.new(key, intersected_data)
      end

      private

      # Private: Normalized data
      #
      def normalized_data
        puts "normalized_data #{data}"
        Array(data)
      end

      # Private: Defines command to get executed based on the type
      #
      def command
        puts "command #{type}  "
        case type
        when "AND"    then :select
        when "MINUS"  then :reject
        end
      end

      # Private: The intersected data depending on the command executed
      #
      def intersected_data
        puts "intersected_data #{command} #{source_key}"
        normalized_data.send(command) do |id|
          Minuteman.redis.getbit(source_key, id) == 1
        end
      end
    end
  end
end
