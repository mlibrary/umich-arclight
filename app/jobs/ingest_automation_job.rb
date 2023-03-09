require_dependency "um_arclight/package/generator"

class IngestAutomationJob < ApplicationJob
  queue_as :automation

  def perform(event, details)
    unless Rails.configuration.x.arclight.enable_automation
      logger.debug <<~EOM
        Ingest automation attempted, but disabled...
        Set config.x.arclight.enable_automation = true if you want it to run.
        event: #{event}, details: #{details}
      EOM
      return
    end

    case event
    when 'ingest.file'
      logger.info "Beginning Finding Aid ingest to repository '#{details[:repo_id]}' of EAD file #{details[:file_path]}"
      ::IndexFindingAidJob.perform_later(details[:file_path], details[:repo_id])
    when 'index.success'
      logger.info "Finding Aid successfully indexed -- ID: #{details[:ead_id]}, source path: #{details[:src_path]}, archived path: #{details[:archive_path]}"
      ::PackageFindingAidJob.perform_later(details[:ead_id], 'html')
    when 'html.success'
      logger.info "HTML generated for Finding Aid -- ID: #{details[:ead_id]}"
      ::PackageFindingAidJob.perform_later(details[:ead_id], 'pdf')
    when 'pdf.success'
      logger.info "PDF generated for Finding Aid -- ID: #{details[:ead_id]}"
      ::IngestAutomationJob.perform_later('ingest.success', ead_id: details[:ead_id])
    when 'ingest.success'
      logger.info "Ingest completed for Finding Aid -- ID: #{details[:ead_id]}"
      # do some accounting
    when 'index.failure', 'html.failure', 'pdf.failure'
      logger.error "Ingest failed for Finding Aid -- event: #{event}, details: #{details.inspect}"
    end
  end
end
