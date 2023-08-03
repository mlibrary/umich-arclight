module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  ##
  # Override the Kaminari page_entries_info helper with our own, blacklight-aware
  # implementation. Why do we have to do this?
  #  - We need custom counting information for grouped results
  #  - We need to provide number_with_delimiter strings to i18n keys
  # If we didn't have to do either one of these, we could get away with removing
  # this entirely.
  #
  # @param [RSolr::Resource] collection (or other Kaminari-compatible objects)
  # @return [String]
  def page_entries_info(collection, entry_name: nil)
    entry_name = if entry_name
      entry_name.pluralize(collection.size, I18n.locale)
    else
      collection.entry_name(count: collection.size).to_s
    end

    # grouped response objects need special handling
    end_num = if collection.respond_to?(:groups) && render_grouped_response?(collection)
      collection.groups.length
    else
      collection.limit_value
    end

    end_num = if collection.offset_value + end_num <= collection.total_count
      collection.offset_value + end_num
    else
      collection.total_count
    end

    case collection.total_count
    when 0
      t('blacklight.search.pagination_info.no_items_found', entry_name: entry_name).html_safe # rubocop:disable Rails/OutputSafety
    when 1
      t('blacklight.search.pagination_info.single_item_found', entry_name: entry_name).html_safe # rubocop:disable Rails/OutputSafety
    else
      t('blacklight.search.pagination_info.pages', entry_name: entry_name.pluralize(collection.size, I18n.locale),
                                                   current_page: collection.current_page,
                                                   num_pages: collection.total_pages,
                                                   start_num: number_with_delimiter(collection.offset_value + 1),
                                                   end_num: number_with_delimiter(end_num),
                                                   total_num: number_with_delimiter(collection.total_count),
                                                   count: collection.total_pages).html_safe # rubocop:disable Rails/OutputSafety
    end
  end
end
