# frozen_string_literal: true

require 'rails_spec_helper'

RSpec.describe 'DUL Arclight Pages', type: :feature, js: true do
  it 'navigates to homepage' do
    visit '/'
    expect(page).to have_css 'h1', text: 'Find Archival Materials'
    expect(page).to have_css 'h2', text: 'About This Site'
    expect(page).to have_css 'h2', text: 'Find More in the Catalog'
    expect(page).to have_css 'h2', text: 'Ask a Librarian'
  end

  it 'displays UA record groups page, with links & titles' do
    visit '/collections/ua-record-groups'
    expect(page).to have_link('Student/Campus Life',
                              href: '/catalog?f%5Bua_record_group_ssim%5D%5B%5D=31')
  end

  it 'has focus on the search field on the homepage' do
    visit '/'
    expect(page.evaluate_script('document.activeElement.id')).to eq 'q'
  end
end
