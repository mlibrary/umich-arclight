# Bridge to IndexFindingAidJob and PackageFindingAidJob (both queue_as :index)
#
# The jobs fire processing events when they reach some result, so there is no
# more work to do here.
class IndexWorker
  include Sneakers::Worker
  from_queue :index

  include ActiveJobWorker
end
