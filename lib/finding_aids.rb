# Top-level module for dealing with the domain of finding aids
#
# We are not using the Arclight module to avoid implicit collisions. If
# something here really belongs "in Arclight", it should be moved upstream.
#
# For now, we're relying on Bundler and Rails autoloading. This module may move
# toward explicit requires or Zeitwerk, but for now, we assuming everything may
# depend on anything, so execute with rake (depending on 'environment') or use
# rails runner for anything in this tree.
module FindingAids
  # Convenience include of Dry::Types
  module Types
    include Dry.Types()
  end
end

require_relative 'finding_aids/event'
require_relative 'finding_aids/events'

require_relative 'finding_aids/ead_indexed'
require_relative 'finding_aids/ead_invalid'
require_relative 'finding_aids/ead_validated'
require_relative 'finding_aids/html_failed'
require_relative 'finding_aids/html_generated'
require_relative 'finding_aids/ingest_mediator'
require_relative 'finding_aids/ingest_ead'
require_relative 'finding_aids/ingest_started'
require_relative 'finding_aids/ingest_finished'
require_relative 'finding_aids/intake_ead'
require_relative 'finding_aids/intake_worker'
require_relative 'finding_aids/pdf_failed'
require_relative 'finding_aids/pdf_generated'
require_relative 'finding_aids/validate_and_save'
