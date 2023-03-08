Sneakers.configure amqp: 'amqp://guest:guest@rabbit:5672',
                   workers: 2,
                   prefetch: 1,
                   threads: 1,
                   exchange: 'findingaids',
                   exchange_type: 'topic',
                   durable: true

Sneakers::ContentType.register(
  content_type: "application/json",
  serializer: ->(object) { JSON.dump(object) },
  deserializer: ->(json) { JSON.parse(json, symbolize_names: true) }
)

Sneakers.logger.level = Logger::INFO
