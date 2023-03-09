require 'arclight'
require 'arclight/repository'

namespace :arclight do
  # FIXME: SHAMELESS copy of dul_arclight:reindex_everything for now
  desc 'Reingest all finding aids in the data directory via background jobs'
  task ingest_everything: :environment do
    puts "Looking in #{DulArclight.finding_aid_data} ..."

    # Find our configured repositories, get their IDs
    repo_config.keys.each do |repo_id|
      Dir.glob(File.join(DulArclight.finding_aid_data, 'ead', repo_id, '*.xml')) do |path|
        IngestAutomationJob.perform_later('ingest.file', repo_id: repo_id, file_path: path)
      end
    end

    puts 'All collections queued for Ingest.'
  end
end
