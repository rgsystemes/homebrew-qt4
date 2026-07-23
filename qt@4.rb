class QtAT4 < Formula
  desc "Cross-platform application and UI framework"
  homepage "https://www.qt.io/"
  url "https://download.qt.io/archive/qt/4.8/4.8.7/qt-everywhere-opensource-src-4.8.7.tar.gz"
  mirror "https://mirrors.ocf.berkeley.edu/qt/archive/qt/4.8/4.8.7/qt-everywhere-opensource-src-4.8.7.tar.gz"
  sha256 "e2882295097e47fe089f8ac741a95fef47e0a73a3f3cdf21b56990638f626ea0"
  revision 6

  head "https://code.qt.io/qt/qt.git", branch: "4.8"

  # Backport of Qt5 commit to fix the fatal build error with Xcode 7, SDK 10.11.
  # https://code.qt.io/cgit/qt/qtbase.git/commit/?id=b06304e164ba47351fa292662c1e6383c081b5ca
  bottle do
    root_url "https://github.com/cartr/homebrew-qt4-bottles/releases/download/autobottle-qt4"
    sha256 mojave:      "6c66adaf110ce3534d7ced855b51ae744e0a4750f4daaff635928e7476183c35"
    sha256 high_sierra: "2049444b31e01a2690f3d19663a6ec8b9c28e19741af24f936796431450767fb"
  end

  option "with-docs", "Build documentation"
  option "with-universal", "Build a universal binary (x86_64 + arm64)"

  deprecated_option "qtdbus" => "with-dbus"
  deprecated_option "with-d-bus" => "with-dbus"

  depends_on "openssl@1.0"
  depends_on "freetds"
  depends_on "unixodbc"
  depends_on "dbus" => :optional
  depends_on "mysql" => :optional
  depends_on "postgresql" => :optional

  resource "test-project" do
    url "https://gist.github.com/tdsmith/f55e7e69ae174b5b5a03.git",
        revision: "6f565390395a0259fa85fdd3a4f1968ebcd1cc7d"
  end

  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/480b7142c4e2ae07de6028f672695eb927a34875/qt/el-capitan.patch"
    sha256 "c8a0fa819c8012a7cb70e902abb7133fc05235881ce230235d93719c47650c4e"
  end

  # Backport of Qt5 patch to fix an issue with null bytes in QSetting strings.
  patch do
    url "https://raw.githubusercontent.com/cartr/homebrew-qt4/41669527a2aac6aeb8a5eeb58f440d3f3498910a/patches/qsetting-nulls.patch"
    sha256 "0deb4cd107853b1cc0800e48bb36b3d5682dc4a2a29eb34a6d032ac4ffe32ec3"
  end

  # Patch to fix build on macOS High Sierra
  patch :p0 do
    url "https://raw.githubusercontent.com/cartr/homebrew-qt4/c957b2d755c762b77142e35f68cddd7f0986bc7b/patches/qt4-versions-without-underscores.patch"
    sha256 "69713c9bcedace4c167273822da14247760c6dcff4949251af6a7b5f93bca9aa"
  end

  # Patch for stricter compiler restrictions on High Sierra
  patch :p0 do
    url "https://raw.githubusercontent.com/cartr/homebrew-qt4/c957b2d755c762b77142e35f68cddd7f0986bc7b/patches/linguist-findmessage-null-check.patch"
    sha256 "db68bf8397eb404c9620c6bb1ada5e98369420b1ea44f2da8c43c718814b5b3b"
  end

  # Patch for QFixed compiler issue in QCoreTextFontEngine
  patch :p1 do
    url "https://raw.githubusercontent.com/cartr/homebrew-qt4/22a6e328b6d911b3c1cedcaadb2882dda728f8a7/patches/qfixed.patch"
    sha256 "4ca3df71470f755917bc903dfee0b6a6e1d2788322b9d71d810b3bb80b3f8c8a"
  end

  # Patch for spurious QObject warnings
  patch :p1 do
    url "https://raw.githubusercontent.com/cartr/homebrew-qt4/b7bc7818aa11c809209032554a990b1cef7edacc/patches/qobject-spurious-warnings.patch"
    sha256 "5e81df9a1c35a5aec21241a82707ad6ac198b2e44928389722b64da341260c5d"
  end

  # Patch to fix build on macOS Big Sur
  patch do
    url "https://raw.githubusercontent.com/cartr/homebrew-qt4/98a906e1ad47106c65021150938de61138799ea8/patches/qt4-bigsur.patch"
    sha256 "f2012863e13914dbb62ccc9d99d6c9e662c37491c7b93e9df6347a75e8137dbb"
  end

  # Patch to fix build on macOS Sequoia
  patch do
    url "https://raw.githubusercontent.com/cartr/homebrew-qt4/a346c6d4a398f0bd11a4418db3713bd87a7ef0f2/patches/qt4-sequoia.patch"
    sha256 "3464175f05acfa0d77fa46df43454d94fe238a9f2d7088393a866d01fea9889a"
  end

  # AArch64 support patch (based on https://salsa.debian.org/qt-kde-team/qt/qt4-x11/-/raw/b720da7b9bab7b5331b112dbbe7a51297e12faf7/debian/patches/aarch64_arm64_qatomic_support.patch)
  patch do
    url "https://raw.githubusercontent.com/cartr/homebrew-qt4/a346c6d4a398f0bd11a4418db3713bd87a7ef0f2/patches/aarch64_arm64_qatomic_support.patch"
    sha256 "1aba5c1c7417f975208d22a2de55fc8fc760c4a17353b3d4ca452b8c23c3ab12"
  end

  # QPointer assigned to QWeakPointer EXEC_BAD_ACCESS fix
  patch do
    url "https://raw.githubusercontent.com/cartr/homebrew-qt4/a346c6d4a398f0bd11a4418db3713bd87a7ef0f2/patches/qwidget_setStyle_helper_exc_bad_access.patch"
    sha256 "0e05bbd22f0b0539b4edaf21f6cb26a47f0a9589188058a6be6984dafe2ba629"
  end

  # Integer weight/italic fonts
  patch do
    url "https://raw.githubusercontent.com/cartr/homebrew-qt4/a346c6d4a398f0bd11a4418db3713bd87a7ef0f2/patches/qfontdatabase_assert.patch"
    sha256 "32371147969d47d0231aa1817eab18fbfa52364102c5666cd214932d434f004b"
  end

  def install
    if MacOS.sdk_path_if_needed
      # Qt attempts to build with a 10.4 deployment target, even though
      # we use libc++ which is only available in 10.9+. This used to not fail
      # (although I'm unsure if the resulting binary would've worked on 10.4)
      # but it's now completely broken because Xcode10/Mojave moved all the
      # headers around.
      inreplace "configure", "MACOSX_DEPLOYMENT_TARGET 10.4", "MACOSX_DEPLOYMENT_TARGET 10.9"
      inreplace "src/tools/bootstrap/bootstrap.pro", "MACOSX_DEPLOYMENT_TARGET = 10.4",
"MACOSX_DEPLOYMENT_TARGET = 10.9"
      inreplace "mkspecs/common/mac.conf", "MACOSX_DEPLOYMENT_TARGET = 10.4", "MACOSX_DEPLOYMENT_TARGET = 10.9"
      inreplace "qmake/qmake.pri", "MACOSX_DEPLOYMENT_TARGET = 10.4", "MACOSX_DEPLOYMENT_TARGET = 10.9"
      inreplace "mkspecs/unsupported/macx-clang-libc++/qmake.conf", "MACOSX_DEPLOYMENT_TARGET = 10.7",
"MACOSX_DEPLOYMENT_TARGET = 10.9"
    end

    args = %W[
      -prefix #{prefix}
      -plugindir #{prefix}/lib/qt4/plugins
      -importdir #{prefix}/lib/qt4/imports
      -datadir #{prefix}/etc/qt4
      -release
      -opensource
      -confirm-license
      -fast
      -system-zlib
      -qt-libtiff
      -qt-libpng
      -qt-libjpeg
      -nomake demos
      -nomake examples
      -cocoa
      -no-webkit
      -qt3support
    ]

    if ENV.compiler == :clang
      args << "-platform"

      args << if MacOS.version >= :mavericks
        "unsupported/macx-clang-libc++"
      else
        "unsupported/macx-clang"
      end

      args << "-no-opengl" if MacOS.version >= :tahoe
    end

    # Phonon is broken on macOS 10.12+ and Xcode 8+ due to QTKit.framework
    # being removed.
    args << "-no-phonon" if MacOS.version >= :sierra || MacOS::Xcode.version >= "8.0"

    args << "-openssl-linked"
    args << "-I" << Formula["openssl@1.0"].opt_include
    args << "-L" << Formula["openssl@1.0"].opt_lib

    args << "-plugin-sql-mysql" if build.with? "mysql"
    args << "-plugin-sql-psql" if build.with? "postgresql"

    if build.with? "dbus"
      dbus_opt = Formula["dbus"].opt_prefix
      args << "-I#{dbus_opt}/lib/dbus-1.0/include"
      args << "-I#{dbus_opt}/include/dbus-1.0"
      args << "-L#{dbus_opt}/lib"
      args << "-ldbus-1"
      args << "-dbus-linked"
    end

    args << "-nomake" << "docs" if build.without? "docs"
    args << "-debug-and-release" if ENV["HOMEBREW_CCCFG"]&.include?("D")

    ENV.permit_arch_flags
    if build.with?("universal")
      args << "-universal"

      # Homebrew's compiler shim (first on PATH) injects its own -march=westmere
      # flag into every clang/clang++ invocation regardless of the flags qmake's
      # build system passes. That flag is invalid whenever -arch arm64 is also
      # present, which breaks qt's own bootstrap build (qmake building itself)
      # as well as the main Qt build. Bypass the shim entirely for this build by
      # putting the real system clang/clang++ first on PATH.
      ENV["PATH"] = "/usr/bin:#{ENV["PATH"]}"
    end

    # Patch macdeployqt so it finds the plugin path
    inreplace "tools/macdeployqt/macdeployqt/main.cpp", '"/Developer/Applications/Qt/plugins"',
"\"#{HOMEBREW_PREFIX}/lib/qt4/plugins\""
    inreplace "tools/macdeployqt/macdeployqt/main.cpp", 'deploymentInfo.qtPath + "/plugins"',
"\"#{HOMEBREW_PREFIX}/lib/qt4/plugins\""

    # Patch to fix build on macOS Big Sur
    system "mv src/3rdparty/javascriptcore/VERSION src/3rdparty/javascriptcore/VERSION.md"

    system "./configure", *args
    system "cp src/corelib/arch/qatomic_aarch64.h include/QtCore" if Hardware::CPU.arm? || build.with?("universal")
    system "make"
    ENV.deparallelize
    system "make", "install"

    # what are these anyway?
    (bin+"pixeltool.app").rmtree
    (bin+"qhelpconverter.app").rmtree

    # Some config scripts will only find Qt in a "Frameworks" folder
    frameworks.install_symlink Dir["#{lib}/*.framework"]

    # The pkg-config files installed suggest that headers can be found in the
    # `include` directory. Make this so by creating symlinks from `include` to
    # the Frameworks' Headers folders.
    Pathname.glob("#{lib}/*.framework/Headers") do |path|
      include.install_symlink path => path.parent.basename(".framework")
    end

    # Make `HOMEBREW_PREFIX/lib/qt4/plugins` an additional plug-in search path
    # for Qt Designer to support formulae that provide Qt Designer plug-ins.
    system "/usr/libexec/PlistBuddy",
            "-c", "Add :LSEnvironment:QT_PLUGIN_PATH string \"#{HOMEBREW_PREFIX}/lib/qt4/plugins\"",
           "#{bin}/Designer.app/Contents/Info.plist"

    Pathname.glob("#{bin}/*.app") { |app| mv app, prefix }
  end

  def post_install
    system "cp $(brew --cache)/Sources/qtA4/qt-everywhere-opensource-src-4.8.7/src/corelib/arch/qatomic_aarch64.h #{HOMEBREW_PREFIX}/include/QtCore" if Hardware::CPU.arm? || build.with?("universal")
  end

  def caveats
    <<~EOS
                We agreed to the Qt opensource license for you.
                If this is unacceptable you should uninstall.
      #{"      "}
                Phonon is not supported on macOS Sierra or with Xcode 8.
            #{"    "}
                WebKit is no longer included for security reasons. If you absolutely
                need it, it can be installed with `brew install qt-webkit@2.3`.
    EOS
  end

  test do
    Encoding.default_external = "UTF-8" unless RUBY_VERSION.start_with? "1."
    resource("test-project").stage testpath
    system bin/"qmake"
    system "make"
    assert_match(/GitHub/, pipe_output(testpath/"qtnetwork-test 2>&1", nil, 0))
  end
end
