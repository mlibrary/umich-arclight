module FindingAids
  # Start the complete ingest process for an EAD file.
  class IngestEad < FindingAids.Event('ead.ingest')
    auto_register

    attribute :file_path, Types::String
  end
end
