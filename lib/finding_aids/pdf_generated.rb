module FindingAids
  class PdfGenerated < FindingAids.Event('ead.pdf.generated')
    auto_register

    attribute :ead_id, Types::String
  end
end
