module FindingAids
  class PdfFailed < FindingAids.Event('ead.pdf.failed')
    auto_register

    attribute :ead_id, Types::String
    attribute :error, Types::String
  end
end
