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

    # Enable IngestAutomationJob
    config.x.arclight.enable_automation = true

    # Turn off Blacklight search history tracking
    config.blacklight.enable_search_history = false
  end
end
