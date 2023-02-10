module UmichHelper
  def umich_generic_render_document_field_label(config_field, document, field: field_name)
    return if %w[bioghist_tesim arrangement_tesim scopecontent_tesim add_tesim].include?(field)

    generic_render_document_field_label(config_field, document, field: field)
  end
end
