# frozen_string_literal: true

require 'um_arclight/errors'
require 'um_arclight/package/generator'

class PackageFindingAidJob < ApplicationJob
  queue_as :index

  def perform(identifier)
    artifact = UmArclight::Package::Generator.new identifier: identifier
    artifact.generate_pdf
  rescue StandardError
    raise UmArclight::GenerateError, identifier
  end
end