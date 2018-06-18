class Hub < Formula
  desc "Add GitHub support to git on the command-line"
  homepage "https://hub.github.com/"
  url "https://github.com/github/hub/archive/v2.4.0.tar.gz"
  sha256 "894eb112be9aa0464fa2c63f48ae8e573ef9e32a00bad700e27fd09a0cb3be4b"

  head "https://github.com/github/hub.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "c495ef4d9f89c7e16b8a0be01abf18c257167a58d1a5609675d261222cc8b0f6" => :high_sierra
    sha256 "3f4d0c1b72dfd9074e245815f11e286d1d5a22b03c283d5af85df46387690d64" => :sierra
    sha256 "cb2cfec3e962d3427e8fd49c1cd6ceb3d68314347f7f23b74abffa5c439343ed" => :el_capitan
  end

  option "without-completions", "Disable bash/zsh completions"
  option "without-docs", "Don't install man pages"

  depends_on "go" => :build

  # The build needs Ruby 1.9 or higher.
  depends_on "ruby" => :build if MacOS.version <= :mountain_lion

  def install
    if build.with? "docs"
      begin
        deleted = ENV.delete "SDKROOT"
        ENV["GEM_HOME"] = buildpath/"gem_home"
        system "gem", "install", "bundler"
        ENV.prepend_path "PATH", buildpath/"gem_home/bin"
        system "make", "man-pages"
      ensure
        ENV["SDKROOT"] = deleted
      end
      system "make", "install", "prefix=#{prefix}"
    else
      system "script/build", "-o", "hub"
      bin.install "hub"
    end

    if build.with? "completions"
      bash_completion.install "etc/hub.bash_completion.sh"
      zsh_completion.install "etc/hub.zsh_completion" => "_hub"
      fish_completion.install "etc/hub.fish_completion" => "hub.fish"
    end
  end

  test do
    system "git", "init"
    %w[haunted house].each { |f| touch testpath/f }
    system "git", "add", "haunted", "house"
    system "git", "commit", "-a", "-m", "Initial Commit"
    assert_equal "haunted\nhouse", shell_output("#{bin}/hub ls-files").strip
  end
end
