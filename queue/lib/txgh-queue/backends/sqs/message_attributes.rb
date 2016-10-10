module TxghQueue
  module Backends
    module Sqs
      class MessageAttributes
        class << self
          def from_message(message)
            history_sequence = HistorySequence.from_message(message)
            new(history_sequence)
          end

          def from_h(hash)
            history_sequence = HistorySequence.from_h(hash)
            new(history_sequence)
          end
        end

        attr_reader :history_sequence

        def initialize(history_sequence)
          @history_sequence = history_sequence
        end

        def to_h
          { history_sequence: history_sequence.to_h }
        end

        def dup
          self.class.new(history_sequence.dup)
        end
      end
    end
  end
end
