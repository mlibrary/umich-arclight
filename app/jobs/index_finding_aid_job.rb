require 'dul_arclight/errors'
require 'um_arclight/errors'

require_dependency "um_arclight/package/generator"

class IndexFindingAidJob < ApplicationJob
  queue_as :index

  def perform(src_path, repo_id)
    ead_id = nil
    dest_path = nil

    File.open(src_path, "r:UTF-8:UTF-8") do |file|
      # A Traject reader which reads XML, and yields zero to many Nokogiri::XML::Document
      # objects as source records in the traject pipeline.
      #
      # It does process the entire input document with Nokogiri::XML.parse, DOM-parsing,
      # so will take RAM for the entire input document, until iteration completes.
      #
      # You can have it yield the _entire_ input XML as a single traject source record
      # (default), or you can use setting `nokogiri.each_record_xpath` to split
      # the source up into separate records to yield into traject pipeline -- each one
      # will be it's own Nokogiri::XML::Document.
      DulArclight::Traject::DulCompressedReader.new(file, {}).each do |doc|
        # Initializing an indexer
        #
        # The first arg to indexer constructor is an optional hash of settings,
        # same settings you could set in configuration. Under programmatic use,
        # it may be more convenient or more legible to set in constructor.
        # Keys can be Strings or Symbols.
        #
        #     indexer = Traject::Indexer.new("solr_writer.commit_on_close" => true)
        #
        # Note that keys passed in as an initializer arg will "override"
        # any settings set with provide in config.
        indexer = Traject::Indexer::NokogiriIndexer.new(
          # Keep things simple and not interfering with Rails
          "processing_thread_pool" => 0, # disable Indexer processing thread pool
          "solr_writer.thread_pool" => 0, # writing to solr is done inline, no threads
          "solr_writer.batch_size" => 1, # send to solr for each record, no batching
          "solr.url" => ENV.fetch("SOLR_URL", Blacklight.default_index.connection.base_uri).to_s.chomp("/"),
          "repository" => repo_id
        ) do
          # Configuring an indexer
          #
          # Under standard use, a traject indexer is configured with mapping rules and
          # other settings in a standalone configuration file. You can do this programmatically
          # with load_config_file:
          #
          #     indexer.load_config_file(path_to_config)
          #
          # This can be convenient for config files you can use either from the command line,
          # or programmatically. Or for allowing other staff roles to write config files separately.
          # You can call load_config_file multiple times, and order may matter --
          # exactly the same as command line configuration files.
          load_config_file(Rails.root.join("lib/dul_arclight/traject/ead2_config.rb"))
        end
        # process_record: send a single record to instance writer
        #
        # #process_record takes a single source record, sends it thorough transformation,
        # and sends the output the instance-configured writer. No logging, threading,
        # or error handling is done for you. Skipped records will not be sent to writer.
        # A Traject::Indexer::Context is returned from every call.
        #
        #     context = indexer.process_record(source_record)
        #
        # This method can be thought of as sending a single record through the indexer's pipeline and writer.
        # For convenience, this is also aliased as #<<.
        #
        #     indexer << source_record
        #
        # process_record should be safe to call concurrently on an indexer shared between threads --
        # so long as the configured writer is thread-safe, which all built-in writers are.
        #
        # You can (and may want/need to) manually call indexer.complete to run after_processing steps,
        # and close/flush the writer. After calling complete, the indexer can not be re-used for more process_record calls,
        # as the writer has been closed.
        context = indexer.process_record(doc)
        indexer.complete

        # Make an archive copy of source file available for downloading.
        ead_id = context.output_hash['id']&.first
        dest_dir = File.join(DulArclight.finding_aid_data, "xml", repo_id)
        dest_path = File.join(dest_dir, "#{ead_id}.xml")
        FileUtils.mkdir_p(dest_dir)
        FileUtils.copy_file(src_path, dest_path, preserve: true, dereference: true, remove_destination: true)

        ::IngestAutomationJob.perform_later('index.success', src_path: src_path, archive_path: dest_path, ead_id: ead_id)
      end
    end
  rescue => e
    ::IngestAutomationJob.perform_later('index.failure', src_path: src_path, archive_path: dest_path, ead_id: ead_id, err_msg: e.message)
    raise DulArclight::IndexError, e.message
  end
end
