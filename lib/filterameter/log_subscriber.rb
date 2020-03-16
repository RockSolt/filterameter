# frozen_string_literal: true

module Filterameter
  # = Log Subscriber
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
        keys = event.payload[:keys]
        "  Undeclared filter parameter#{'s' if keys.size > 1}: #{keys.map { |e| ":#{e}" }.join(', ')}"
      end
    end
  end
end

Filterameter::LogSubscriber.attach_to :filterameter
