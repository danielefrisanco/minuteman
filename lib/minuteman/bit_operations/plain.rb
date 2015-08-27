require "minuteman/keys_methods"
require "minuteman/bit_operations/result"

# Public: Minuteman core classs
#
class Minuteman
  module BitOperations
    # Public: The class to handle operations with others timespans
    #
    #   type:       The operation type
    #   timespan:   The timespan to be permuted
    #   source_key: The original key to do the operation
    #
    class Plain < Struct.new(:type, :timespan, :source_key)
      extend Forwardable
      include KeysMethods

      def_delegators :Minuteman, :redis, :safe

      def call
        puts "plain#{source_key}"
        events = if source_key == timespan
                   Array(source_key)
                 else
                   [source_key, timespan.key]
                 end

        key = destination_key(type, events)
        safe { redis.bitop(type, key, events) }

        Result.new(key)
      end
    end
  end
end
