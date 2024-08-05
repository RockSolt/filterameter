# frozen_string_literal: true

module Filterameter
  # # Log Subscriber
  #
  # Class LogSubscriber provides instrumentation for events.
  class LogSubscriber < ActiveSupport::LogSubscriber
    def validation_failure(event)
      debug do
        errors = event.payload[:errors]
        (['  The following filter validation errors occurred:'] + errors.full_messages).join("\n  - ")
      end
    end

    def undeclared_parameters(event)
      debug do
        key = event.payload[:key]
        "  Undeclared filter parameter: #{key}"
      end
    end
  end
end

Filterameter::LogSubscriber.attach_to :filterameter
