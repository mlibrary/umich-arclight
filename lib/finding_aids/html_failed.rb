module FindingAids
  class HtmlFailed < FindingAids.Event('ead.html.failed')
    auto_register

    attribute :ead_id, Types::String
    attribute :error, Types::String
  end
end
