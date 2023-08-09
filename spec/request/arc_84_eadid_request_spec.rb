require 'rails_helper'

RSpec.describe 'ARC-84 eadid redirection', type: :request do
  it { expect { get "/catalog/an-eadid-not-in-the-list" }.to raise_exception(Blacklight::Exceptions::RecordNotFound) }

  context "when eadid in the fixtures list" do
    Rails.root.join('spec/fixtures/arc_84_eadids.txt').read.split("\n").each do |eadid|
      it eadid.to_s do
        get "/catalog/#{eadid.tr(".", "-")}"
        expect(response).to redirect_to("/catalog/#{eadid}")
      end
    end
  end

  context "when umich-scl-kramera" do
    it "umich-scl-ams0185" do
      get "/catalog/umich-scl-kramera"
      expect(response).to redirect_to("/catalog/umich-scl-ams0185")
    end
  end
end
