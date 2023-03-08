module FindingAids
  class IngestMediator
    include Sneakers::Worker
    from_queue 'ead.#'

    # AMQP is a language-indifferent specification that uses terms and concepts
    # that overlap somewhat with object-oriented programming languages. In
    # particular, the structure and behavior related to messages are defined as
    # the properties (aka fields) and methods of the "basic" class.
    #
    # The terminology and details like argument order used in various
    # documentation and client libraries is inconsistent.
    #
    # RabbitMQ is shaped primarily around AMQP semantics, but does some
    # translation and grouping of the concepts, for ease of use and protocol
    # independence. Specific to ("basic") messages, the properties are divided
    # into those used for delivery metadata, set by RabbitMQ itself, and
    # general message metadata, set by the producers.
    #
    # Bunny delivers messages to queue subscribers with an array of three
    # elements, informally named the "delivery info", "message properties", and
    # "payload". These correspond to the RabbitMQ notions. They are delivered
    # as positional block parameters.
    #
    # Sneakers offers a Worker module/base class where the consumer can
    # implement either `#work` or `#work_with_params`, which will serve as the
    # callback/handler for each message in its configured queue subscription.
    # Sneakers also offers some wrapping/filter functionality to handle content
    # encoding and content type (serialization), both as passthrough by
    # default. Once those layers are processed, the callback is called. The
    # work_with_params method is called with the "deserialized message",
    # "delivery info", and "metadata" as positional method parameters. These
    # are conceptually the same items as in Bunny, but reordered, and with the
    # payload potentially receiving some pre-processing as above.
    #
    # A quick survey of clients/libraries written in other languages all suffer
    # from similar inconsistencies throughout their layers.
    #
    # Because all of these conventions exposed by Sneakers, as the library we
    # use directly are by positional parameter, we are at the liberty to use
    # the best names we can come up with. As it stands, we follow the
    # conceptual model of a envelope containing a message and metadata being
    # delivered. The envelope carries everything required to route and deliver
    # the message. The metadata describes the content of the message. This is
    # vaguely similar to SMTP, with its envelope, headers, and body.  The
    # message content is typically referred to, informally, as "the message".
    # So, we follow these general interpretations and terminology.
    #
    # TODO: handle event deserialization as a content subtype e.g., application/arclight-event
    # TODO: distinguish between events and commands
    # TODO: design a reasonable dispatching/handler interface that accommodates orchestration (correlation ID, etc)
    def work_with_params(msg, envelope, metadata)
      dispatch Events.deserialize!(msg), envelope, metadata
      ack!
    end

    private

    def dispatch(event, _envelope, _metadata)
      case event
      # Normal workflow
      when IngestEad
        validate_and_save_incoming_ead event
      when EadValidated
        index_ead event
      when EadIndexed
        convert_to_html event
      when HtmlGenerated
        convert_to_pdf event
      when PdfGenerated
        ingest_finished event

      # Failures
      when EadInvalid
        stop_on_validation_error event
      when HtmlFailed, PdfFailed
        stop_on_conversion_error event
      end
    end

    # start the process, generate a correlation ID, begin log for "this ingest"
    def validate_and_save_incoming_ead(ingest_start)
      # Event for observation
      broker.publish IngestStarted.new(file_path: ingest_start.file_path)

      # Command to initiate workflow steps
      broker.publish IntakeEad.new(file_path: ingest_start.file_path)
    end

    def index_ead(ead)
      IndexFindingAidJob.perform_later(ead.file_path, ead.repo_id)
    end

    def convert_to_html(indexed_ead)
      PackageFindingAidJob.perform_later(indexed_ead.ead_id, 'html')
    end

    def convert_to_pdf(converted_ead)
      PackageFindingAidJob.perform_later(converted_ead.ead_id, 'pdf')
    end

    def ingest_finished(event)
      # TODO: add correlation ID and repo
      broker.publish IngestFinished.new(ead_id: event.ead_id)
    end

    def stop_on_validation_error(problem)
      # TODO: Record details for dashboard, retry.. include ingest correlation ID in log messages
      msg = "Validation failed for EAD file: #{problem.file_path}\n"
      problem.errors.each do |error|
        msg += "\t#{error}"
      end
      logger.info msg
    end

    def stop_on_conversion_error(problem)
      logger.info "Ingest (#ADD CORRELATION ID#) failed: #{problem.error}"
    end

    def broker
      @broker ||= Broker.new
    end
  end
end
