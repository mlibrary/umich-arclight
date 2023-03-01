class DeleteWorker < ActiveJobWorker
  from_queue :delete
end
