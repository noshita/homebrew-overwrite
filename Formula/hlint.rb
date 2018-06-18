require "language/haskell"

class Hlint < Formula
  include Language::Haskell::Cabal

  desc "Haskell source code suggestions"
  homepage "https://github.com/ndmitchell/hlint"
  url "https://hackage.haskell.org/package/hlint-2.1.6/hlint-2.1.6.tar.gz"
  sha256 "7b08ebe2ccc6b7f1957e7eb19dfc5b58f99087275a894dc0e8cd43fcd35aadeb"
  head "https://github.com/ndmitchell/hlint.git"

  bottle do
    sha256 "7740223bcc408e0e47a1d4bf94daa0f980fefcf38af6f978d28fee09e0b23ae2" => :high_sierra
    sha256 "225fe5cb3687bf7583fe4bfefa4cfb71d8569de857bdbd3dfd28e158faae5eaa" => :sierra
    sha256 "db7689f52ce7a09eb974005ad18650b1b3e13d60ca59972ca19739662d83a1c9" => :el_capitan
  end

  depends_on "cabal-install" => :build
  depends_on "ghc" => :build

  def install
    install_cabal_package :using => "happy"
    man1.install "data/hlint.1"
  end

  test do
    (testpath/"test.hs").write <<~EOS
      main = do putStrLn "Hello World"
    EOS
    assert_match "Redundant do", shell_output("#{bin}/hlint test.hs", 1)
  end
end
