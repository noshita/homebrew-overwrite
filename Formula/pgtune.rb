class Pgtune < Formula
  desc "Tuning wizard for postgresql.conf"
  homepage "http://pgfoundry.org/projects/pgtune"
  url "http://pgfoundry.org/frs/download.php/2449/pgtune-0.9.3.tar.gz"
  mirror "https://mirrorservice.org/sites/ftp.debian.org/debian/pool/main/p/pgtune/pgtune_0.9.3.orig.tar.gz"
  mirror "https://mirrors.ocf.berkeley.edu/debian/pool/main/p/pgtune/pgtune_0.9.3.orig.tar.gz"
  sha256 "31ac5774766dd9793d8d2d3681d1edb45760897c8eda3afc48b8d59350dee0ea"

  # 0.9.3 does not have settings for PostgreSQL 9.x, but the trunk does
  head "https://github.com/gregs1104/pgtune.git"

  bottle :unneeded

  def install
    # By default, pgtune searches for settings in the directory
    # where the script is being run from.
    inreplace "pgtune" do |s|
      s.sub! /(parser\.add_option\('-S'.*default=).*,/, "\\1\"#{pkgshare}\","
    end
    bin.install "pgtune"
    pkgshare.install Dir["pg_settings*"]
  end

  test do
    system bin/"pgtune", "--help"
  end
end
