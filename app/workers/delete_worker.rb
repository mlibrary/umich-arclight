class DeleteWorker
  include Sneakers::Worker
  from_queue :delete

  include ActiveJobWorker
end
