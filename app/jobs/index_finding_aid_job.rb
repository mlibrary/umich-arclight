require 'dul_arclight/errors'

class IndexFindingAidJob < ApplicationJob
  queue_as :index

  def perform(path, repo_id)
    traject_indexer = Traject::Indexer::NokogiriIndexer.new(
      # disable Indexer processing thread pool, to keep things simple and not interfering with Rails.
      "processing_thread_pool" => 0,
      "solr_writer.thread_pool" => 0, # writing to solr is done inline, no threads

      "solr.url" => ENV.fetch("SOLR_URL", Blacklight.default_index.connection.base_uri).to_s.chomp("/"),
      "writer_class" => "SolrJsonWriter",
      "solr_writer.batch_size" => 1, # send to solr for each record, no batching
      "repository" => repo_id
    ) do
      load_config_file(Rails.root.join("lib/dul_arclight/traject/ead2_config.rb"))
    end

    begin
      traject_indexer << Nokogiri::XML(File.open(path, 'r'))
      dest_path = File.join(DulArclight.finding_aid_data, "xml", repo_id)
      FileUtils.mkdir_p(dest_path)
      dest = File.join(dest_path, "#{eadid_slug(path)}.xml")
      FileUtils.copy_file(path, dest, preserve: true, dereference: true, remove_destination: true)
    rescue => e
      raise DulArclight::IndexError, e.message
    end
  end

  private

  def eadid_slug(path)
    basename = File.basename(path, ".*")
    eadid_slug = nil
    File.open(path, "r:UTF-8:UTF-8") do |f|
      doc = Nokogiri::XML(f)
      eadid_node = doc.at_xpath('/ead/eadheader/eadid')
      eadid_slug = eadid_node.text.strip.tr(".", "-").to_s if eadid_node && eadid_node.text.present?
    end
    eadid_slug || basename
  end
end
