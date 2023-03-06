module FindingAids
  # TODO: Convert to a Command message
  # TODO: Support Pathname or String
  class IntakeEad < FindingAids.Event('jobs.intake.file')
    auto_register

    attribute :file_path, Types::String
  end
end
