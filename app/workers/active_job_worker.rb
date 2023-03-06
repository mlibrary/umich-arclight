# Adapter between Sneakers and ActiveJob
#
# The ActiveJob::QueueAdapters::SneakersAdapter has implementation to both
# enqueue and work jobs. The difficulty is that enqueuing can target different
# named queues, and the worker, as implemented by JobWrapper only listens to
# the "default" queue. The Sneakers design is that a Worker listens to a given
# queue (by calling `from_queue`) and the Runner that is invoked by the rake
# task `sneakers:run` can be given a list of named worker classes, or use the
# default set of all classes that include the Worker module.
#
# We could extend JobWrapper, but its name is unwieldy and doing so defeats the
# autoregistration of the workers. Its implementation is simple, so we
# duplicate it here: decode the JSON message, dispatch the ActiveJob, and
# acknowledge the receipt to the queue. This module separates the ActiveJob
# piece from the Sneakers piece, allowing a Worker to include it and get the
# default behavior. The `work` method can be overridden in case other steps
# should be taken around the ActiveJob piece, or acknowledgement should be done
# differently.
module ActiveJobWorker
  def self.included(worker)
    worker.include InstanceMethods
  end

  module InstanceMethods
    def execute_active_job(msg)
      ActiveJob::Base.execute job_data(msg)
    end

    def work(msg)
      execute_active_job msg
      ack!
    end

    def job_data(msg)
      ActiveSupport::JSON.decode(msg)
    end
  end
end
