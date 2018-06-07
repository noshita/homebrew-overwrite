class Pcl < Formula
  desc "Library for 2D/3D image and point cloud processing"
  homepage "http://www.pointclouds.org/"
  revision 3
  head "https://github.com/PointCloudLibrary/pcl.git"

  stable do
    url "https://github.com/PointCloudLibrary/pcl/archive/pcl-1.8.1.tar.gz"
    sha256 "5a102a2fbe2ba77c775bf92c4a5d2e3d8170be53a68c3a76cfc72434ff7b9783"

    # VTK 8.1 compat
    # Upstream commit from 10 Nov 2017 "VTK function change since version 7.1 (#2063)"
    # See https://github.com/PointCloudLibrary/pcl/pull/2063
    patch do
      url "https://github.com/PointCloudLibrary/pcl/commit/6555b9a91f.patch?full_index=1"
      sha256 "860a7b8e7964725b2d11a4237d6a6b65a42f049bc855ecbfcdc406b8e505b478"
    end
  end

  bottle do
    sha256 "4ce797b0f374af5f48dc0973444a484758138ae4f266c3b05eaaa3fa397150de" => :high_sierra
    sha256 "19059cdc4d921fa94df4422db43bd08c92f3523c5c71d56232a30e52a930e103" => :sierra
    sha256 "d0b054af73d2d35b7de29e1382ba1232386ddd6e3f00467723eb6ce3c0150256" => :el_capitan
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "boost"
  depends_on "cminpack"
  depends_on "eigen"
  depends_on "flann"
  depends_on "glew"
  depends_on "libusb"
  depends_on "qhull"
  depends_on "vtk"

  def install
    # Fix "error: no matching constructor for initialization of
    # 'boost::uuids::random_generator' (aka 'boost::uuids::random_generator_pure')"
    # Upstream issue 18 Apr 2018 "Fails to build against Boost 1.67"
    # See https://github.com/PointCloudLibrary/pcl/issues/2284
    ENV.append "CXXFLAGS", "-DBOOST_UUID_RANDOM_GENERATOR_COMPAT"

    args = std_cmake_args + %w[
      -DBUILD_SHARED_LIBS:BOOL=ON
      -DBUILD_apps=AUTO_OFF
      -DBUILD_apps_3d_rec_framework=AUTO_OFF
      -DBUILD_apps_cloud_composer=AUTO_OFF
      -DBUILD_apps_in_hand_scanner=AUTO_OFF
      -DBUILD_apps_optronic_viewer=AUTO_OFF
      -DBUILD_apps_point_cloud_editor=AUTO_OFF
      -DBUILD_examples:BOOL=ON
      -DBUILD_global_tests:BOOL=OFF
      -DBUILD_outofcore:BOOL=AUTO_OFF
      -DBUILD_people:BOOL=AUTO_OFF
      -DBUILD_simulation:BOOL=AUTO_OFF
      -DWITH_CUDA:BOOL=OFF
      -DWITH_DOCS:BOOL=OFF
      -DWITH_QT:BOOL=FALSE
      -DWITH_TUTORIALS:BOOL=OFF
    ]

    if build.head?
      args << "-DBUILD_apps_modeler=AUTO_OFF"
    else
      args << "-DBUILD_apps_modeler:BOOL=OFF"
    end

    mkdir "build" do
      system "cmake", "..", *args
      system "make", "install"
      prefix.install Dir["#{bin}/*.app"]
    end
  end

  test do
    assert_match "tiff files", shell_output("#{bin}/pcl_tiff2pcd -h", 255)
  end
end
