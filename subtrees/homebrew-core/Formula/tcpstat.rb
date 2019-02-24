class Tcpstat < Formula
  desc "Active TCP connections monitoring tool"
  homepage "https://github.com/jtt/tcpstat"
  url "https://github.com/jtt/tcpstat/archive/rel-0-1.tar.gz"
  version "0.1"
  sha256 "366a221950759015378775862a7499aaf727a3a9de67b15463b0991c2362fdaf"
  head "https://github.com/jtt/tcpstat.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "805b8444d7bcf36e2da7285474b20f5193f8e104fd990e9f87fa922bdb13801d" => :mojave
    sha256 "164e0b5ef61bb28432b7a3d5aa23ca78d291130aa9473b9019dce643ac93bc03" => :high_sierra
    sha256 "378e42522ee14d64c0f5bf9bceeb0100c9193210eea2ee2ff80433b2b3da0166" => :sierra
    sha256 "e483bf39d0e42a8124c3e2e50f117e66b285bada33df94c1b070460c6df622ea" => :el_capitan
    sha256 "313fe3a9402b65b6f44b583c49ba83d301b63708b2e0a554100a5e83c03559d8" => :yosemite
    sha256 "d090af2c66892bd831257dcd3ea109ab8c85cfdd7be6d2c7c2295e13b1c0b7b8" => :mavericks
  end

  def install
    system "make"
    bin.install "tcpstat"
  end

  test do
    (testpath/"script.exp").write <<~EOS
      set timeout 30
      spawn "#{bin}/tcpstat"
      send -- "q"
      expect eof
    EOS

    system "expect", "-f", "script.exp"
  end
end
