class IndexWorker < ActiveJobWorker
  from_queue :index
end
