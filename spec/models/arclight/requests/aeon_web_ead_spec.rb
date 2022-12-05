# frozen_string_literal: true

require 'rails_spec_helper'

RSpec.describe Arclight::Requests::AeonWebEad do
  describe "simple request mappings" do
    subject(:valid_object) { described_class.new(document, 'http://example.com/sample.xml') }

    let(:config) do
      instance_double 'Arclight::Repository',
                      request_url_for_type: 'https://sample.request.com',
                      request_mappings_for_type: 'Action=10&Form=31&Value=ead_url'
    end
    let(:document) { instance_double 'Blacklight::SolrDocument', repository_config: config }

    describe '#request_url' do
      it 'returns from the repository config' do
        expect(valid_object.request_url).to eq 'https://sample.request.com'
      end
    end
    describe '#url' do
      it 'constructs a url with params' do
        expect(valid_object.url).to eq 'https://sample.request.com?Action=10&Form=31&Value=http%3A%2F%2Fexample.com%2Fsample.xml'
      end
    end

    describe '#form_mapping' do
      subject(:form_mapping) { valid_object.form_mapping }

      it 'converts string from config to hash' do
        expect(form_mapping).to be_an Hash
      end

      it 'has valid key/value pairs' do
        expect(form_mapping).to include('Action' => '10', 'Form' => '31', 'Value' => 'http://example.com/sample.xml')
      end
    end
  end

  describe "parsed ead url" do
    subject(:valid_object) { described_class.new(document, 'http://example.com/sample.xml') }

    config = Arclight::Repository.find_by(slug: 'scrc')

    let(:document) do
      instance_double 'Blacklight::SolrDocument',
                      repository_config: config,
                      request_field: '-//us::MiU//TEXT us::MiU::ams0099.xml//EN'
    end


    it 'responds to parsed_ead_url' do
      expect(valid_object.parsed_ead_url).to eq 'https://quod.lib.umich.edu/s/sclead/eads/ams0099.xml'
    end
  end
end
