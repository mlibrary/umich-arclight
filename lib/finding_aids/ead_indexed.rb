module FindingAids
  class EadIndexed < FindingAids.Event('ead.indexed')
    auto_register

    attribute :repo_id, Types::String
    attribute :ead_id, Types::String
  end
end
