# Sneakers worker that listens to a given queue for ActiveJobs.
#
# The ActiveJob::QueueAdapters::SneakersAdapter has implementation to both
# enqueue and work jobs. The difficulty is that enqueuing can target different
# named queues, and the worker, as implemented by JobWrapper only listens to
# the "default" queue. Invoking Sneakers involves identifying which workers you
# want to run, so we need to have different class/worker names to listen to
# different queues.
#
# We could extend ActiveJob::QueueAdapters::SneakersAdapter::JobWrapper but
# that name is unwieldy and its implmentation is simple -- decode the JSON
# event, dispatch, and acknowledge. So, we reimplement it here and specify
# the queue in subclasses.
class ActiveJobWorker
  include Sneakers::Worker
  from_queue :default

  def work(msg)
    job_data = ActiveSupport::JSON.decode(msg)
    ActiveJob::Base.execute job_data
    ack!
  end
end
