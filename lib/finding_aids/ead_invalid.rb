module FindingAids
  class EadInvalid < FindingAids.Event('ead.invalid')
    auto_register

    attribute :file_path, Types::String
    attribute :errors, Types.Array(Types::String).default([].freeze)
  end
end
