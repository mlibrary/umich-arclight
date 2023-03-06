module LikelyCause
  def self.with_header(ex, message = "")
    "#{message} (#{ex.class}): #{ex.message}\n\t#{self.for(ex)}"
  end

  def self.for(ex)
    "Likely caused by: " + without_formatting(ex)
  end

  def self.without_formatting(ex)
    ex.backtrace
      .reject { |line| line =~ /\/gems\/ruby\// }
      .first
  end
end
