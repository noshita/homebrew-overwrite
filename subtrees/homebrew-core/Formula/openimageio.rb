class Openimageio < Formula
  desc "Library for reading, processing and writing images"
  homepage "http://openimageio.org/"
  url "https://github.com/OpenImageIO/oiio/archive/Release-1.8.12.tar.gz"
  sha256 "93e807d7c77a5c4c12598cc7932aa08239bc4198e3e31dca0998a3e0ab163386"
  head "https://github.com/OpenImageIO/oiio.git"

  bottle do
    sha256 "7dd214409304e3b6c49c17834c8bd58b80a77a1a8cbddb0809cd5a8c93e51e1c" => :high_sierra
    sha256 "5db9b2f16b2300fbb1becddaafa407479ef15da5c5ca1507cf1b56c35e9ffbde" => :sierra
    sha256 "5d18509f6c763ae704c65977cbc238d421c569b5caaa19378aac7d64eee57adf" => :el_capitan
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "boost"
  depends_on "boost-python"
  depends_on "boost-python3"
  depends_on "ffmpeg"
  depends_on "freetype"
  depends_on "giflib"
  depends_on "ilmbase"
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "libraw"
  depends_on "libtiff"
  depends_on "opencolorio"
  depends_on "openexr"
  depends_on "python"
  depends_on "webp"

  def install
    # -DUSE_OPENSSL=OFF can be removed in 1.9, see
    # https://github.com/Homebrew/homebrew-core/pull/22522#issuecomment-364831533
    args = std_cmake_args + %w[
      -DEMBEDPLUGINS=ON
      -DUSE_FIELD3D=OFF
      -DUSE_JPEGTURBO=OFF
      -DUSE_NUKE=OFF
      -DUSE_OPENCV=OFF
      -DUSE_OPENGL=OFF
      -DUSE_OPENJPEG=OFF
      -DUSE_OPENSSL=OFF
      -DUSE_PTEX=OFF
      -DUSE_QT=OFF
    ]

    mkdir "build-with-python2" do
      system "cmake", "..", "-DBoost_PYTHON_LIBRARIES=#{Formula["boost-python"].opt_lib}/libboost_python27-mt.dylib",
                            *args
      system "make", "install"
    end

    # CMake picks up the system's python dylib, even if we have a brewed one.
    py3ver = Language::Python.major_minor_version "python3"
    py3prefix = Formula["python3"].opt_frameworks/"Python.framework/Versions/#{py3ver}"

    ENV["PYTHONPATH"] = lib/"python#{py3ver}/site-packages"

    args << "-DPYTHON_EXECUTABLE=#{py3prefix}/bin/python3"
    args << "-DPYTHON_LIBRARY=#{py3prefix}/lib/libpython#{py3ver}.dylib"
    args << "-DPYTHON_INCLUDE_DIR=#{py3prefix}/include/python#{py3ver}m"

    # CMake picks up boost-python instead of boost-python3
    args << "-DBOOST_ROOT=#{Formula["boost"].opt_prefix}"
    args << "-DBoost_PYTHON_LIBRARIES=#{Formula["boost-python3"].opt_lib}/libboost_python36-mt.dylib"

    # This is strange, but must be set to make the hack above work
    args << "-DBoost_PYTHON_LIBRARY_DEBUG=''"
    args << "-DBoost_PYTHON_LIBRARY_RELEASE=''"

    # Need to make a second build dir, otherwise cmake picks up cached files
    # and builds against `boost-python`
    mkdir "build-with-python3" do
      system "cmake", "..", *args
      system "make", "install"
    end
  end

  test do
    test_image = test_fixtures("test.jpg")
    assert_match "#{test_image} :    1 x    1, 3 channel, uint8 jpeg",
                 shell_output("#{bin}/oiiotool --info #{test_image} 2>&1")

    ["python", "python3"].each do |python|
      output = <<~EOS
        from __future__ import print_function
        import OpenImageIO
        print(OpenImageIO.VERSION_STRING)
      EOS
      assert_match version.to_s, pipe_output(python, output, 0)
    end
  end
end