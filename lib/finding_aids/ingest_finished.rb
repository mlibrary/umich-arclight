module FindingAids
  class IngestFinished < FindingAids.Event('ead.ingest.finished')
    auto_register

    attribute :ead_id, Types::String
  end
end
