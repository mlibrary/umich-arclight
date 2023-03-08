# frozen_string_literal: true

require 'um_arclight/errors'
require 'um_arclight/package/generator'

# Job to queue packaging
class PackageFindingAidJob < ApplicationJob
  queue_as :index

  def perform(identifier, format)
    artifact = UmArclight::Package::Generator.new identifier: identifier
    # TODO: Prefer polymorphism to conditionals; possibly do callback for event
    if format == 'html'
      convert_to_html(artifact)
    elsif format == 'pdf'
      convert_to_pdf(artifact)
    else
      raise UmArclight::GenerateError, identifier, "Unsupported target format: #{format}"
    end
  rescue => error
    raise UmArclight::GenerateError, identifier, error.to_s
  end

  def convert_to_html(artifact)
    artifact.generate_html
    broker.publish(FindingAids::HtmlGenerated.new(ead_id: artifact.identifier))
  rescue => ex
    broker.publish(FindingAids::HtmlFailed.new(
      ead_id: artifact.identifier,
      error: LikelyCause.with_header(ex, "HTML Conversion failed")
    ))
  end

  def convert_to_pdf(artifact)
    artifact.generate_pdf
    broker.publish(FindingAids::PdfGenerated.new(ead_id: artifact.identifier))
  rescue => ex
    broker.publish(FindingAids::PdfFailed.new(
      ead_id: artifact.identifier,
      error: LikelyCause.with_header(ex, "PDF Conversion failed")
    ))
  end

  private

  def broker
    @broker ||= FindingAids::Broker.new
  end
end
