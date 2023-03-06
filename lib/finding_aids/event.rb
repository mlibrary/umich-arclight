module FindingAids
  # Abstract/base Event type, designed for creating value objects that can be
  # published and consumed as event messages conveniently.
  #
  # To create a new event type, call `Event()` with the intended event key,
  # and extend the result, which will be a fixed-keyed Dry::Struct, ready for
  # schema/attribute definition.
  class Event < Dry::Struct
    transform_keys(&:to_sym)

    class << self
      protected

      def auto_register
        Events.register self
      end
    end
  end

  # Create an Event class to extend, with a given event key (for example,
  # 'ead.uploaded').
  #
  # By using this creator method and extending the result, you get a base
  # implementation that handles the key automatically, as a constant, making
  # it available as `WhateverEvent::KEY` and as `#key` on each instance.
  #
  # These types are convenient for serialization to and from hashes, with the
  # base Event class offering global registration by using `::auto_register` in
  # the definition and dry-struct / dry-types providing for schema definition.
  #
  # Dry::Types is aliased as FindingAids::Types for convenience in definitions.
  #
  # @example
  #
  #   class FindingAidDeleted < Event("findingaid.deleted")
  #     auto_register
  #     attribute :ead_id, Types::String
  #   end
  #
  #   FindingAidDeleted::KEY
  #   # => "findingaid.deleted"
  #
  #   event = FindingAidDeleted.new(ead_id: "some-id")
  #   # => #<FindingAidDeleted event_key="findingaid.deleted", ead_id="some-id">
  #
  #   event.ead_id
  #   # => "some-id"
  #
  #   event.to_h
  #   # => {:event_key=>"findingaid.deleted", :ead_id=>"some-id"}
  #
  def self.Event(event_key)
    Class.new(FindingAids::Event) do
      const_set(:KEY, event_key.freeze)

      attribute :event_key, Types.Constant(event_key.freeze).default(event_key.freeze)
    end
  end
end
