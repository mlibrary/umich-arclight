module FindingAids
  # Event type registry and deserializer
  #
  # Raw events (hashes) can be classified to see what kind of event class
  # matches, or deserialized, which instantiates an event with the hash.
  class Events
    class NotAnEventError < StandardError; end

    class UnregisteredEventTypeError < StandardError; end

    def self.[](event_key)
      registry[event_key]
    end

    def self.register(event_class)
      registry[event_class::KEY] = event_class
    end

    def self.classify(raw_event)
      if raw_event.include?(:event_key)
        registry[raw_event[:event_key]]
      end
    end

    def self.deserialize(raw_event)
      classify(raw_event)&.new(raw_event.reject { |k| k == :event_key })
    end

    def self.classify!(raw_event)
      typecheck_raw!(raw_event)
      ensure_registered!(raw_event)

      registry[raw_event[:event_key]]
    end

    def self.deserialize!(raw_event)
      classify!(raw_event).new(raw_event.reject { |k| k == :event_key })
    end

    def self.typecheck_class!(event_class)
      unless event_class.const_defined?(:KEY)
        raise NotAnEventError, "Event class does not have a KEY defined: #{event_class}"
      end
    end

    def self.typecheck!(event)
      typecheck_class!(event.class)
    end

    def self.typecheck_raw!(raw_event)
      unless raw_event.respond_to?(:event_key) || (raw_event.respond_to?(:[]) && raw_event[:event_key])
        raise NotAnEventError, "Raw event object does not have an event_key property: #{raw_event.class} (objectid: #{raw_event.object_id})"
      end
    end

    def self.ensure_registered!(raw_event)
      unless registry.include?(raw_event[:event_key])
        raise UnregisteredEventTypeError, "No event class registered for type: #{raw_event[:event_key]}"
      end
    end

    def self.registry
      @@registry ||= {}
    end

    private_class_method :registry
  end
end
