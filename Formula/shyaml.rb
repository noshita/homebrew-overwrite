class Shyaml < Formula
  include Language::Python::Virtualenv

  desc "Command-line YAML parser"
  homepage "https://github.com/0k/shyaml"
  url "https://files.pythonhosted.org/packages/33/34/7ad4b645bdd5c6cd100748fc2429924b553439221aa9b9386f658e5a05f2/shyaml-0.5.2.tar.gz"
  sha256 "80650ebfe6fa2e16083451d515207472d60990c1c15fc0fd607c27077790ac23"
  head "https://github.com/0k/shyaml.git"

  bottle do
    cellar :any
    sha256 "581c62b943b03b8c7693cb960428a1bf900d28bcdd7b10e068e3768b31c30410" => :high_sierra
    sha256 "34028bbdca3b61d682520c3821e232bf897cf143c9a5b5946c1952c6da0d56e8" => :sierra
    sha256 "c0e1cc1710c31f0ec1b9a0cc50c99572743726eeada76493438bbb99e671d22d" => :el_capitan
  end

  depends_on "python"
  depends_on "libyaml"

  resource "PyYAML" do
    url "https://files.pythonhosted.org/packages/4a/85/db5a2df477072b2902b0eb892feb37d88ac635d36245a72a6a69b23b383a/PyYAML-3.12.tar.gz"
    sha256 "592766c6303207a20efc445587778322d7f73b161bd994f227adaa341ba212ab"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    yaml = <<~EOS
      key: val
      arr:
        - 1st
        - 2nd
    EOS
    assert_equal "val", pipe_output("#{bin}/shyaml get-value key", yaml, 0)
    assert_equal "1st", pipe_output("#{bin}/shyaml get-value arr.0", yaml, 0)
    assert_equal "2nd", pipe_output("#{bin}/shyaml get-value arr.-1", yaml, 0)
  end
end
