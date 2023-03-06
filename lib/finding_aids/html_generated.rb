module FindingAids
  class HtmlGenerated < FindingAids.Event('ead.html.generated')
    auto_register

    attribute :ead_id, Types::String
  end
end
