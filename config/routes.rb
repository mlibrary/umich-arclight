Rails.application.routes.draw do # rubocop:disable Metrics/BlockLength
  # FYI: Routes declared at the top of the file will mask routes that have yet to be declared.
  # The engines are mounted last so you may override engine routes.

  # Note that component URLs have underscores; collections don't
  def collection_slug_constraint
    /[a-zA-Z0-9.-]+/
  end

  def dynamic_constraint
    /[^\/]+/
  end

  concern :exportable, Blacklight::Routes::Exportable.new
  concern :searchable, Blacklight::Routes::Searchable.new({}, {id: dynamic_constraint})
  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new

  if ENV['FINDING_AID_INGEST'] == 'true'
    resources :findingaids do
      member do
        put :reindex
      end
    end
    resources :slugmaps, only: %i[index destroy]
  end

  get 'help', to: 'help#help'

  resources :repositories, only: %i[index show], controller: 'arclight/repositories' do
    member do
      get :about
    end
  end

  # https://mlit.atlassian.net/browse/ARC-84
  # ARC-84: Remove ban on periods in eadid field.
  # Redirects for normalized URLs in the wild.
  get '/catalog/:id', to: redirect { |path_params, req| "/catalog/#{ARC_84_EADID_MAP[path_params[:id]]}" }, constraints: lambda { |request| ARC_84_EADID_MAP.has_key?(request.path_parameters[:id]) }

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
    concerns :range_searchable
  end

  get '/catalog/:id/xml', action: 'ead_download', controller: 'catalog', as: 'ead_download',
                          constraints: {id: collection_slug_constraint}

  get '/catalog/:id/html', action: 'html_download', controller: 'catalog', as: 'html_download',
                           constraints: {id: collection_slug_constraint}

  get '/catalog/:id/pdf', action: 'pdf_download', controller: 'catalog', as: 'pdf_download',
                          constraints: {id: collection_slug_constraint}

  root to: "catalog#index"

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog', constraints: {id: dynamic_constraint} do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  post '/index_finding_aids', to: 'index_finding_aids#create'

  devise_for :users

  resources :ua_record_groups, only: [:index], as: 'ua_record_groups', path: '/collections/ua-record-groups', controller: 'ua_record_groups'

  # Render a sitemap on-the-fly from a query (if configured)
  get '/custom_sitemaps/:id', controller: 'custom_sitemaps', action: 'index', defaults: {format: 'xml'},
                              constraints: ->(request) { CUSTOM_SITEMAP_CONFIG.key?(request.params[:id]) }

  ### Handle errors
  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all

  mount Arclight::Engine => '/'
  mount BlacklightDynamicSitemap::Engine => '/'
  mount Blacklight::Engine => '/'
end
