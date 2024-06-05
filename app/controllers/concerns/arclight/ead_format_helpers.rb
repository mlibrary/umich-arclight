# frozen_string_literal: true

# Complete overwrite of ArcLight module to override EAD -> HTML formatting
# rules. TBD: PR to arclight core. Last checked for updates
# ArcLight v0.3.0. See:
# https://github.com/projectblacklight/arclight/blob/master/app/controllers/concerns/arclight/ead_format_helpers.rb
#

module Arclight
  ##
  # A module to add EAD to HTML transformation rules for Arclight
  module EadFormatHelpers # rubocop:disable Metrics/ModuleLength
    extend ActiveSupport::Concern
    include ActionView::Helpers::OutputSafetyHelper

    COLLIDING_TAGS = %w[abbr address blockquote div label title].freeze

    def render_html_tags(args)
      values = args[:value] || []
      values.map! { |value| transform_ead_to_html(value) }
      values.map! { |value| wrap_in_paragraph(value) } if values.count > 1
      safe_join(values.map(&:html_safe))
    end

    private

    def wrap_in_paragraph(value)
      if value.start_with?('<')
        value
      else
        content_tag(:p, value)
      end
    end

    def transform_ead_to_html(value)
      Loofah.xml_fragment(condense_whitespace(value))
            .scrub!(ead_to_html_scrubber)
            .scrub!(:strip).to_html
    end

    def condense_whitespace(str)
      str.squish.strip.gsub(/>[\n\s]+</, '> <')
    end

    def ead_to_html_scrubber
      Loofah::Scrubber.new do |node|
        # Order of formatting is important!!!
        format_special_elements(node)
        format_render_attributes(node) if node.attr('render').present?
        format_href_attributes(node) if node.attr('href').present?
        format_url_content(node) if %r{https?://}i.match?(node.xpath('normalize-space(text())'))

        # Some elements are in common between EAD & HTML:
        # abbr address blockquote div head label p table tbody thead title
        # For any that we don't want to end up in our page HTML (e.g., we
        # want <p> but not <title>), just change it into a span.
        node.name = 'span' if COLLIDING_TAGS.include? node.name
        node
      end
    end

    def format_special_elements(node)
      format_archrefs(node) if %w[archref].include? node.name
      format_links(node) if %w[extptr extref extrefloc ptr ref].include? node.name
      format_lists(node) if %w[list chronlist].include? node.name
      format_indexes(node) if node.name == 'index'
      format_tables(node) if node.name == 'table'
      format_compound_elements(node) if %w[separatedmaterial relatedmaterial bibliography].include? node.name
      format_notes_elements(node) if %w[p note odd].include? node.name
    end

    def format_render_attributes(node) # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
      case node.attr('render')
      when 'altrender'
        node.name = 'span'
        node['class'] = node['altrender']
      when 'bold'
        node.name = 'strong'
      when 'bolddoublequote'
        node.name = 'strong'
        node.prepend_child '"'
        node.add_child '"'
      when 'bolditalic'
        node.name = 'strong'
        node.wrap('<em/>')
      when 'boldsinglequote'
        node.name = 'strong'
        node.prepend_child '\''
        node.add_child '\''
      when 'boldsmcaps'
        node.name = 'strong'
        node.wrap('<small/>')
        node['class'] = 'text-uppercase'
      when 'boldunderline'
        node.name = 'strong'
        node['class'] = 'text-underline'
      when 'doublequote'
        node.name = 'span'
        node.prepend_child '"'
        node.add_child '"'
      when 'italic'
        node.name = 'em'
      when 'nonproport'
        node.name = 'em'
      when 'singlequote'
        node.name = 'span'
        node.prepend_child '\''
        node.add_child '\''
      when 'smcaps'
        node.name = 'small'
        node['class'] = 'text-uppercase'
      when 'sub'
        node.name = 'sub'
      when 'super'
        node.name = 'sup'
      when 'underline'
        node.name = 'span'
        node['class'] = 'text-underline'
      end
    end

    def format_href_attributes(node)
      return if node.name == 'a'

      node['target'] = '_blank'
      node['class'] = 'external-link'
      node.wrap("<#{node.name}/>") unless COLLIDING_TAGS.include? node.name
      node.name = 'a'
    end

    def format_url_content(node)
      # This scrubber processes children after the parent node and
      # we only want to process the parent node
      # NOT its child text nodes!
      return if node.name == 'text'

      # The parsed html document fragment of the parent (see below)
      # will create anchor children which need to skipped to
      # avoid infinite recursion!
      return if node.name == 'a'

      html = String.new(node.content)
      URI.extract(node.content).each do |uri|
        # URI extract matches all URIs not just URLs
        # so skip over non-URL URIs
        next unless %r{https?://}i.match?(uri)

        # Wrap the URL in an anchor tag
        anchor = "<a class='external-link' href='#{uri}' target='_blank'>#{uri}</a>"
        html.sub!(uri, anchor)
      end

      # Parse the HTML to create the parent's new children
      node.children = Nokogiri::XML::DocumentFragment.parse(html).children
    end

    def format_lists(node)
      format_simple_lists(node) if node.name == 'list' && node['type'] != 'deflist'
      format_deflists(node) if node.name == 'list' && node['type'] == 'deflist'
      format_chronlists(node) if node.name == 'chronlist'
    end

    def format_simple_lists(node)
      node.name = 'ul' if (%w[simple marked].include? node['type']) || node['type'].blank?
      node.name = 'ol' if node['type'] == 'ordered'
      node.remove_attribute('type')
      head_node = node.at_css('head')
      format_list_head(head_node) if head_node.present?
      items = node.css('item')
      items.each { |item_node| item_node.name = 'li' }
    end

    def format_list_head(node)
      node['class'] = 'list-head'
      node.name = 'div'
      node.parent.previous = node # move it from within the list to above it
    end

    def format_deflists(node)
      listhead_node = node.at_css('listhead')
      labels = node.css('label')
      items = node.css('item')
      defitems = node.css('defitem')
      node.remove_attribute('type')

      if listhead_node.present?
        format_deflist_as_table(node, labels, items, defitems)
      else
        format_deflist_as_dl(node, labels, items, defitems)
      end
    end

    def format_deflist_as_table(node, labels, items, defitems)
      node.name = 'table'
      node['class'] = 'table deflist'
      listhead_node = node.at_css('listhead')
      format_deflist_table_head(listhead_node)
      node.at_css('thead').next = '<tbody/>'
      labels.each { |label_node| label_node.name = 'td' }
      items.each { |item_node| item_node.name = 'td' }
      defitems.each do |defitem_node|
        defitem_node.name = 'tr'
        defitem_node.parent = node.at_css('tbody')
      end
    end

    def format_deflist_table_head(listhead_node)
      listhead_node.at_css('head01').name = 'th'
      listhead_node.at_css('head02').name = 'th'
      listhead_node.name = 'tr'
      listhead_node.wrap('<thead/>')
    end

    def format_deflist_as_dl(node, labels, items, defitems)
      node.name = 'dl'
      node['class'] = 'deflist'
      labels.each { |label_node| label_node.name = 'dt' }
      items.each { |item_node| item_node.name = 'dd' }
      defitems.each { |defitem_node| defitem_node.swap(defitem_node.children) } # unwrap
    end

    def format_chronlists(node)
      node.name = 'table'
      node['class'] = 'table chronlist'
      eventgrps = node.css('eventgrp')
      single_events = node.css('chronitem > event')
      multi_events = node.css('eventgrp > event')
      format_chronlist_header(node)
      node.at_css('thead').next = '<tbody/>'
      format_chronlist_caption(node)
      format_chronlist_chronitems(node)
      format_chronlist_dates(node)
      format_chronlist_events(eventgrps, single_events, multi_events)
    end

    def format_chronlist_header(node)
      node.add_child('<thead><tr><th>Date</th><th>Event</th></tr></thead>')
      table_head = node.at_css('thead')
      node.children.first.add_previous_sibling(table_head)
      listhead_node = node.at_css('listhead')
      return unless listhead_node.present?

      node.at_css('thead tr th:nth-of-type(1)').content = node.at_css('listhead/head01').content
      node.at_css('thead tr th:nth-of-type(2)').content = node.at_css('listhead/head02').content
      listhead_node.remove
    end

    def format_chronlist_caption(node)
      head_node = node.at_css('head')
      return unless head_node.present?

      head_node.name = 'caption'
      head_node['class'] = 'chronlist-head'
      node.children.first.add_previous_sibling(head_node) # make the caption first
    end

    def format_chronlist_chronitems(node)
      chronitems = node.css('chronitem')
      chronitems.each do |chronitem_node|
        chronitem_node.name = 'tr'
        chronitem_node.parent = node.at_css('tbody')
      end
    end

    def format_chronlist_dates(node)
      dates = node.css('date')
      dates.each do |date_node|
        date_node.name = 'td'
        date_node['class'] = 'chronlist-item-date'
      end
    end

    def format_chronlist_events(eventgrps, single_events, multi_events)
      eventgrps.each do |eventgrp_node|
        eventgrp_node.name = 'td'
        eventgrp_node['class'] = 'chronlist-item-event'
      end
      single_events.each do |event_node|
        event_node.name = 'td'
        event_node['class'] = 'chronlist-item-event'
      end
      multi_events.each { |event_node| event_node.name = 'div' }
    end

    # Format references to other finding aids
    def format_archrefs(node)
      # If an archref has sibling archrefs, grab all of them as a nodeset, wrap
      # them in a <ul> & wrap each item in an <li>. Seems odd but common for such
      # encoding to imply a list. See https://www.loc.gov/ead/tglib/elements/archref.html
      archref_sibs = node.xpath('./self::archref | ./following-sibling::archref')
      if archref_sibs.count > 1
        archref_sibs.first.previous = '<ul/>'
        archref_sibs.map do |a|
          a.parent = a.previous_element
          a.wrap('<li/>')
        end
      end
      format_archref_repos(node)
    end

    # Format <repository> element within an archref (probably DUL-specific)
    def format_archref_repos(node)
      archref_repos = node.xpath('.//repository')
      archref_repos&.map do |r|
        r.name = 'em'
        r.prepend_child(' &mdash; ')
      end
    end

    def format_links(node)
      node.remove_attribute('target')
      if %w[extptr extref extrefloc].include? node.name
        node['target'] = '_blank'
        node['class'] = 'external-link'
      end
      node.content = node['title'] if (%w[extptr ptr].include? node.name) && node['title'].present?
      node.name = 'a' if node['href'].present?
    end

    def format_compound_elements(node)
      head = node.xpath("./head").first
      head&.name = 'h3'
      return if head.present?
      label = I18n.t("um_arclight.ead_element_labels.#{node.name}")
      node.add_previous_sibling("<h3>#{label}</h3>")
    end

    def format_notes_elements(node)
      head = node.xpath("./head").first
      head&.name = 'h3'
    end

    # Format EAD <index> elements
    def format_indexes(node)
      index_head = node.at_css('head')
      index_head&.name = 'h3'
      index_head&.add_class('index-head')
      index_head['id'] = ['index-', index_head.text].join.parameterize if index_head.present?
      format_indexentries(node)
      node.name = 'div'
    end

    # Grab all of the indexentry children as a nodeset, move them into
    # a <table>, wrap each entry in a <tr> & each value in a <td>.
    def format_indexentries(node)
      indexentries = node.css('indexentry')
      return unless indexentries.present?

      indexentries.first.previous = '<table class="table indexentries" />'
      indexentries.map do |i|
        i.parent = node.at_css('table.table.indexentries')
        i.wrap('<tr/>')
        i.element_children.map { |c| c.wrap('<td/>') }
        # Assuming two columns in an index, create a blank cell for entries
        # with a missing value.
        i.add_child('<td/>') if i.element_children.count == 1
      end
    end

    # Format EAD <table> elements, converting <tgroup> to HTML <table>.
    # Ignoring <colspec>, @colname, @colwidth complex rendering logic for now.
    def format_tables(node)
      node.name = 'div' if node.css('tgroup').present?
      format_table_head(node)
      tgroups = node.css('tgroup')
      tgroups&.map do |t|
        t.name = 'table'
        t.add_class('table')
        t.css('row').map { |r| r.name = 'tr' }
        t.css('thead entry').map { |e| e.name = 'th' }
        t.css('tbody entry').map { |e| e.name = 'td' }
      end
    end

    def format_table_head(node)
      table_head = node.at_css('head')
      return unless table_head.present?

      table_head.name = 'h3'
      table_head.add_class('table-head')
    end
  end
end
