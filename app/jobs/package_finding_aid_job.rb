# frozen_string_literal: true

require 'um_arclight/errors'
require 'um_arclight/package/generator'

# Job to queue packaging
class PackageFindingAidJob < ApplicationJob
  queue_as :index

  def perform(identifier, format)
    unless %w[html pdf].include?(format)
      raise ::UmArclight::GenerateError, identifier, "Unsupported format requested: #{format}"
    end
    convert(identifier, format)
  end

  def convert(identifier, format)
    artifact = ::UmArclight::Package::Generator.new identifier: identifier
    (format == 'html') ? artifact.generate_html : artifact.generate_pdf
    ::IngestAutomationJob.perform_later "#{format}.success", ead_id: identifier
  rescue => error
    ::IngestAutomationJob.perform_later "#{format}.failure", ead_id: identifier
    raise ::UmArclight::GenerateError, identifier, error.to_s
  end
end
