module FindingAids
  class EadValidated < FindingAids.Event('ead.validated')
    auto_register

    attribute :file_path, Types::String
    attribute :repo_id, Types::String
    attribute :ead_id, Types::String
  end
end
