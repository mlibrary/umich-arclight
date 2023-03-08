module FindingAids
  class Broker
    attr_accessor :publisher

    def initialize(publisher: Sneakers::Publisher.new)
      @publisher = publisher
    end

    def publish(event)
      publisher.publish(event.to_h, routing_key: event.event_key, content_type: 'application/json')
    end
  end
end
