class ImagemagickAT6 < Formula
  desc "Tools and libraries to manipulate images in many formats"
  homepage "https://legacy.imagemagick.org/"
  url "https://www.imagemagick.org/download/releases/ImageMagick-6.9.12-44.tar.xz"
  sha256 "2fa4a31d239cb5e37c544469570bfa17f99af6fc7322765a4d8e992ec97d2d8d"
  license "ImageMagick"
  revision 1
  head "https://github.com/imagemagick/imagemagick6.git", branch: "main"

  livecheck do
    url "https://download.imagemagick.org/ImageMagick/download/"
    regex(/href=.*?ImageMagick[._-]v?(6(?:\.\d+)+(?:-\d+)?)\.t/i)
  end

  bottle do
    sha256 arm64_monterey: "2338f1a8b008b798769c0e89d29c959b7fd37c99caca5f7e0eadf239b9d4f697"
    sha256 arm64_big_sur:  "610a9733b9f9cd45e84a15fd7805a1c0e18d5cf9238ec27559c2e4df0a8c7204"
    sha256 monterey:       "9de86ab3e6e9865b8e5602124246e035cd4c3778b4a3d975037595b996a8ea58"
    sha256 big_sur:        "64052b36bb7dd11ac69f27356fce777b09cfa69899a46eb8822f3a571b07019e"
    sha256 catalina:       "28d14173e9b90fa87d24553642cec8916ba0597952cdfe759cf1e515004510a8"
    sha256 x86_64_linux:   "c6dfd7f2a7fc975ac54d4d82df0d29604e11d74d2ca49c0f5e8621805200c77b"
  end

  keg_only :versioned_formula

  depends_on "pkg-config" => :build

  depends_on "freetype"
  depends_on "ghostscript"
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "libtool"
  depends_on "little-cms2"
  depends_on "openjpeg"
  depends_on "webp"
  depends_on "xz"

  skip_clean :la

  def install
    # Avoid references to shim
    inreplace Dir["**/*-config.in"], "@PKG_CONFIG@", Formula["pkg-config"].opt_bin/"pkg-config"

    args = %W[
      --enable-osx-universal-binary=no
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
      --disable-opencl
      --disable-openmp
      --enable-shared
      --enable-static
      --with-freetype=yes
      --with-modules
      --with-webp=yes
      --with-openjp2
      --with-gslib
      --with-gs-font-dir=#{HOMEBREW_PREFIX}/share/ghostscript/fonts
      --without-fftw
      --without-pango
      --without-x
      --without-wmf
    ]

    # versioned stuff in main tree is pointless for us
    inreplace "configure", "${PACKAGE_NAME}-${PACKAGE_BASE_VERSION}", "${PACKAGE_NAME}"
    system "./configure", *args
    system "make", "install"
  end

  test do
    assert_match "PNG", shell_output("#{bin}/identify #{test_fixtures("test.png")}")
    # Check support for recommended features and delegates.
    features = shell_output("#{bin}/convert -version")
    %w[Modules freetype jpeg png tiff].each do |feature|
      assert_match feature, features
    end
  end
end
