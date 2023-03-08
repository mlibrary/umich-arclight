module FindingAids
  class IngestStarted < FindingAids.Event('ead.ingest.started')
    auto_register

    # TODO: Add workflow/correlation ID
    attribute :file_path, Types::String
  end
end
