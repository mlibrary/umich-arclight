require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DulArclight
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2
    config.autoload_paths += %W[#{config.root}/lib]

    # Use custom error pages
    config.exceptions_app = routes

    # Not sure what this does
    config.x.arclight.enable_automation = true

    # Turn off Blacklight search history tracking
    config.blacklight.enable_search_history = false

    # Prepend all log lines with the following tags.
    config.log_tags = {
      request_id: :request_id,
      remote_ip: :remote_ip
    }

    # Use logfmt formatter
    config.rails_semantic_logger.format = :logfmt

    if ENV["RAILS_LOG_TO_STDOUT"].present?
      $stdout.sync = true
      config.rails_semantic_logger.add_file_appender = false
      config.semantic_logger.add_appender(
        io: $stdout, formatter: config.rails_semantic_logger.format
      )
    end
  end
end
