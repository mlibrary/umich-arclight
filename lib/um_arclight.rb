module UmArclight
  mattr_accessor :google_tag_manager_id do
    ENV['GOOGLE_TAG_MANAGER_ID']
  end
end
