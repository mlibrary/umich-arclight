class SearchService < Blacklight::SearchService
  def search_results
    scope = @search_state.params.delete(:scope)
    if @search_state.params["f"].present?
      _level = @search_state.params["f"].delete(:level_sim) if scope.present?
      case scope
      when "all"
        @search_state.params["f"].delete(:repository_sim)
        @search_state.params["f"].delete(:collection_sim)
      when "repository"
        @search_state.params["f"].delete(:collection_sim)
      end
    end
    super
  end
end
