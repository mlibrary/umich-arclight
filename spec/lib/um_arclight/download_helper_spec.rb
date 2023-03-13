require 'rails_helper'

RSpec.describe UmArclight::DownloadHelper do
  subject(:helper) { described_class.new(document) }

  let(:find_aid_data) { DulArclight.finding_aid_data }

  context "when nil document" do
    let(:document) { nil }

    it { expect(helper.send(:repo_slug)).to eq("repo_slug") }
    it { expect(helper.send(:ead_slug)).to eq("ead_slug") }

    it { expect(helper.ead_available?).to be false }
    it { expect(helper.ead_file_path).to eq("#{find_aid_data}/xml/repo_slug/ead_slug.xml") }

    it { expect(helper.html_available?).to be false }
    it { expect(helper.html_file_path).to eq("#{find_aid_data}/pdf/repo_slug/ead_slug.html") }

    it { expect(helper.pdf_available?).to be false }
    it { expect(helper.pdf_file_path).to eq("#{find_aid_data}/pdf/repo_slug/ead_slug.pdf") }

    it { expect(helper.xml_available?).to be false }
    it { expect(helper.xml_file_path).to eq("#{find_aid_data}/xml/repo_slug/ead_slug.xml") }
  end

  context "when solr document" do
    let(:document) { instance_double("SolrDocument", "document", repository_config: repository_config, eadid: eadid) }
    let(:repository_config) { instance_double("Arclight::Repository", "repository_config", slug: slug) }
    let(:slug) { "slug" }
    let(:eadid) { "eadid" }

    it { expect(helper.send(:repo_slug)).to eq("slug") }
    it { expect(helper.send(:ead_slug)).to eq("eadid") }

    it { expect(helper.ead_available?).to be false }
    it { expect(helper.ead_file_path).to eq("#{find_aid_data}/xml/#{slug}/#{eadid}.xml") }

    it { expect(helper.html_available?).to be false }
    it { expect(helper.html_file_path).to eq("#{find_aid_data}/pdf/#{slug}/#{eadid}.html") }

    it { expect(helper.pdf_available?).to be false }
    it { expect(helper.pdf_file_path).to eq("#{find_aid_data}/pdf/#{slug}/#{eadid}.pdf") }

    it { expect(helper.xml_available?).to be false }
    it { expect(helper.xml_file_path).to eq("#{find_aid_data}/xml/#{slug}/#{eadid}.xml") }

    context "when file exist" do
      before { allow(File).to receive(:exist?).with(file_path).and_return(true) }

      context "when ead file" do
        let(:file_path) { helper.ead_file_path }

        it { expect(helper.ead_available?).to be true }
      end

      context "when html file" do
        let(:file_path) { helper.html_file_path }

        it { expect(helper.html_available?).to be true }
      end

      context "when pdf file" do
        let(:file_path) { helper.pdf_file_path }

        it { expect(helper.pdf_available?).to be true }
      end

      context "when xml file" do
        let(:file_path) { helper.xml_file_path }

        it { expect(helper.xml_available?).to be true }
      end
    end

    context "when dot in eadid" do
      let(:eadid) { "ead.id" }

      it { expect(helper.send(:ead_slug)).to eq("ead-id") }
    end
  end
end
