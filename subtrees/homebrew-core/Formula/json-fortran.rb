class JsonFortran < Formula
  desc "Fortran 2008 JSON API"
  homepage "https://github.com/jacobwilliams/json-fortran"
  url "https://github.com/jacobwilliams/json-fortran/archive/6.3.0.tar.gz"
  sha256 "dd989952c882e4eb9873f0b8d7610c0f623edce7f05d7903502d7cfa20766bbd"
  revision 1
  head "https://github.com/jacobwilliams/json-fortran.git"

  bottle do
    cellar :any
    sha256 "094f44b9dca36617aba14bbdcf743c36c0345b746f6725e4ec0105b6232dcc8b" => :high_sierra
    sha256 "5baae63c014cd84743d9a9fd0200984d52e445b1631c9004ccd79acd95997f3c" => :sierra
    sha256 "88c05bd9c92dc405160969cb2b2bda22a49e4cb5d18e1f5a32fa262adafadbab" => :el_capitan
  end

  option "with-unicode-support", "Build json-fortran to support unicode text in json objects and files"
  option "without-docs", "Do not build and install FORD generated documentation for json-fortran"

  deprecated_option "without-robodoc" => "without-docs"

  depends_on "cmake" => :build
  depends_on "ford" => :build if build.with? "docs"
  depends_on "gcc" # for gfortran

  def install
    mkdir "build" do
      args = std_cmake_args
      args << "-DUSE_GNU_INSTALL_CONVENTION:BOOL=TRUE" # Use more GNU/Homebrew-like install layout
      args << "-DENABLE_UNICODE:BOOL=TRUE" if build.with? "unicode-support"
      args << "-DSKIP_DOC_GEN:BOOL=TRUE" if build.without? "docs"
      system "cmake", "..", *args
      system "make", "install"
    end
  end

  test do
    (testpath/"json_test.f90").write <<~EOS
      program example
      use json_module, RK => json_RK
      use iso_fortran_env, only: stdout => output_unit
      implicit none
      type(json_core) :: json
      type(json_value),pointer :: p, inp
      call json%initialize()
      call json%create_object(p,'')
      call json%create_object(inp,'inputs')
      call json%add(p, inp)
      call json%add(inp, 't0', 0.1_RK)
      call json%print(p,stdout)
      call json%destroy(p)
      if (json%failed()) error stop 'error'
      end program example
    EOS
    system "gfortran", "-o", "test", "json_test.f90", "-I#{include}",
                       "-L#{lib}", "-ljsonfortran"
    system "./test"
  end
end
