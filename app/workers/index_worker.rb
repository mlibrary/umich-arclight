class IndexWorker
  include Sneakers::Worker
  from_queue :index

  include ActiveJobWorker
end
