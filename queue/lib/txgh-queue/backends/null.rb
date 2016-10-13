require 'txgh'

module TxghQueue
  module Backends
    module Null

      class << self
        def producer_for(*args)
          raise BackendNotConfiguredError, 'No queue backend has been configured'
        end

        def consumer_for(*args)
          raise BackendNotConfiguredError, 'No queue backend has been configured'
        end
      end

    end
  end
end
