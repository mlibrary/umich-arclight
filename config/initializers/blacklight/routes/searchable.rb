# frozen_string_literal: true

module Blacklight
  module Routes
    class Searchable
      def initialize(defaults = {}, constraints = {})
        @defaults = defaults
        @constraints = constraints
      end

      def call(mapper, _options = {})
        mapper.match '/', action: 'index', as: 'search', via: [:get, :post]
        mapper.get '/advanced', action: 'advanced_search', as: 'advanced_search'

        mapper.post ":id/track", action: 'track', as: 'track', constraints: @constraints
        mapper.get ":id/raw", action: 'raw', as: 'raw', defaults: {format: 'json'}, constraints: @constraints

        mapper.get "opensearch"
        mapper.get 'suggest', as: 'suggest_index', defaults: {format: 'json'}
        mapper.get "facet/:id", action: 'facet', as: 'facet', constraints: @constraints
      end
    end
  end
end
