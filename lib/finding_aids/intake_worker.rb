module FindingAids
  # TODO: Build out a Result API so the listener knows what to do with the
  # original message (ack! in all normal cases where the task published a
  # processing event).
  class IntakeWorker
    include Sneakers::Worker
    from_queue "jobs.intake.*"

    def work(msg)
      command = Events.deserialize!(msg)
      result = ValidateAndSave.call(file_path: command.file_path)
      publish(result.to_h, routing_key: result.event_key, content_type: 'application/json')
      ack!
    end
  end
end
