# frozen_string_literal: true

module Lexicon
  module Common
    module Mixin
      module LoggerAware
        attr_accessor :logger

        def log(*args, **options)
          if !logger.nil?
            logger.log(*args, **options)
          end
        end

        def log_error(error)
          if error.nil?
            log("Error (nil)")
          else
            log([error.message, *error.backtrace].join("\n"))
          end
        end
      end
    end
  end
end
