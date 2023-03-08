module FindingAids
  # Validate and save the supplied file/blob as an EAD available for ingest.
  #
  # NOTE: This serves as an example process object, separating the actions
  # from the events, throughout an operation, "listening" directly by method
  # calls. This pattern is more applicable to longer lived operations that
  # need to persist state and receive direct event method calls from
  # collaborators. An example of that might be an entity (e.g., "model")
  # that is "woken up" from a database and notified of some change or user
  # action. A meaningful example in this application might be persisting the
  # ingest transactions in the database until they are complete. The ingest
  # mediator might listen for progress events on the message bus and raise
  # those events on the model instance to let it update its status. A
  # dashboard UI might also receive user input and raise an event that the
  # transaction was marked for cancellation or retry.
  #
  # This particular operation should probably be migrated to a railway-style
  # pipeline with result/either types. The "do-notation" of dry-monads has
  # matured considerably, and is built precisely for this kind of
  # straight-line writing style with error collection.
  #
  # See: https://dry-rb.org/gems/dry-monads/1.0/do-notation/
  #
  # TODO: Change to source URI rather than file_path
  # TODO: Separate the validation and save pieces, or rename toward intake
  class ValidateAndSave
    attr_reader :file_path

    def initialize(file_path:)
      @file_path = file_path
      @ead_id = nil
      @repo_id = nil
      @errors = []
    end

    def self.call(**args)
      new(**args).call
    end

    def call
      validate_and_save
    rescue => ex
      error! ex
    end

    private

    ## Main workflow methods

    def validate_and_save
      if File.exist?(file_path)
        file_exists
      else
        missing!
      end
    end

    def file_exists
      validate
    end

    def validate
      extract_ead_id
      extract_repo_id

      if errors.empty?
        file_is_valid
      else
        invalid!
      end
    end

    def file_is_valid
      save_as_incoming
    end

    def save_as_incoming
      # TODO: save the EAD according to ead_id, repo_id
      saved
    end

    def saved
      success!
    end

    def success!
      EadValidated.new(file_path: file_path, ead_id: ead_id, repo_id: repo_id)
    end

    def missing!
      EadInvalid.new(file_path: file_path, errors: ["File not found: #{file_path}"])
    end

    def invalid!
      EadInvalid.new(file_path: file_path, errors: errors)
    end

    def error!(ex)
      EadInvalid.new(
        file_path: file_path,
        errors: ["Unhandled error (#{ex.class}): #{ex.message}\n\t#{LikelyCause.for(ex)}"]
      )
    end

    ## support methods

    def extract_ead_id
      eadid_node = document.at_xpath('/ead/eadheader/eadid')
      if eadid_node && eadid_node.text.present?
        self.ead_id = eadid_node.text.strip.tr(".", "-").to_s
      else
        errors << "Could not parse EAD ID from file: #{file_path}"
      end
    end

    def extract_repo_id
      repo_dir = Pathname(file_path).dirname.basename.to_s
      repo = Arclight::Repository.find_by(slug: repo_dir)
      if repo
        self.repo_id = repo.slug
      else
        errors << "Could not resolve Repository for file #{file_path}, slug: #{repo}."
      end
    end

    def document
      @doc ||= Nokogiri::XML(File.open(file_path, "r:UTF-8:UTF-8"))
    end

    attr_accessor :ead_id, :repo_id, :doc, :errors
  end
end
