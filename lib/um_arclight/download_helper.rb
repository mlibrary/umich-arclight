module UmArclight
  class DownloadHelper
    attr_accessor :document

    def initialize(document)
      @document = document
    end

    def ead_available?
      File.exist?(ead_file_path)
    end

    def ead_file_path
      File.join(DulArclight.finding_aid_data, 'xml', repo_slug, "#{ead_slug}.xml")
    end

    def html_available?
      File.exist?(html_file_path)
    end

    def html_file_path
      File.join(DulArclight.finding_aid_data, 'pdf', repo_slug, "#{ead_slug}.html")
    end

    def pdf_available?
      File.exist?(pdf_file_path)
    end

    def pdf_file_path
      File.join(DulArclight.finding_aid_data, 'pdf', repo_slug, "#{ead_slug}.pdf")
    end

    def xml_available?
      ead_available?
    end

    def xml_file_path
      ead_file_path
    end

    private

    def repo_slug
      document&.repository_config&.slug || "repo_slug"
    end

    def ead_slug
      document&.eadid&.tr(".", "-") || "ead_slug"
    end
  end
end
