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

  # qt4-x11 AArch64 support patch
  patch do
    url "https://salsa.debian.org/qt-kde-team/qt/qt4-x11/-/raw/b720da7b9bab7b5331b112dbbe7a51297e12faf7/debian/patches/aarch64_arm64_qatomic_support.patch"
    sha256 "e459e0890b2b7e5f75e5e3e35a4ac44c57bc335b8663f21e39457a3c85a4769a"
  end

  patch :DATA

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

    #inreplace 'src/3rdparty/javascriptcore/JavaScriptCore/runtime/Identifier.cpp', 'UCharBuffer buf = {s, length}', 'UCharBuffer buf = {s, static_cast<unsigned int>(length)}'

    ENV.permit_arch_flags
    if build.with?("universal")
      args << "-universal"
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

__END__
diff --git a/configure b/configure
index 2407211..a0166f6 100644
--- a/configure
+++ b/configure
@@ -1592,7 +1592,7 @@ while [ "$#" -gt 0 ]; do
         ;;
     universal)
         if [ "$PLATFORM_MAC" = "yes" ] && [ "$VAL" = "yes" ]; then
-            CFG_MAC_ARCHS="$CFG_MAC_ARCHS x86 ppc"
+            CFG_MAC_ARCHS="$CFG_MAC_ARCHS x86_64 arm64"
         else
             UNKNOWN_OPT=yes
         fi
@@ -3370,7 +3370,7 @@ fi
 # process CFG_MAC_ARCHS
 if [ "$PLATFORM_MAC" = "yes" ]; then
 #   check -arch arguments for validity.
-    ALLOWED="x86 ppc x86_64 ppc64 i386 arm armv6 armv7"
+    ALLOWED="x86 ppc x86_64 ppc64 i386 arm armv6 armv7 arm64"
     # Save the list so we can re-write it using only valid values
     CFG_MAC_ARCHS_IN="$CFG_MAC_ARCHS"
     CFG_MAC_ARCHS=
@@ -4407,10 +4407,10 @@ Qt/Mac only:
  *  -dwarf2 ............ Enable dwarf2 debugging symbols.
     -no-dwarf2 ......... Disable dwarf2 debugging symbols.

-    -universal ......... Equivalent to -arch "ppc x86"
+    -universal ......... Equivalent to -arch "x86_64 arm64"

     -arch <arch> ....... Build Qt for <arch>
-                         Example values for <arch>: x86 ppc x86_64 ppc64
+                         Example values for <arch>: x86 ppc x86_64 ppc64 arm64
                          Multiple -arch arguments can be specified.

     -sdk <sdk> ......... Build Qt using Apple provided SDK <sdk>. This option requires gcc 4.
@@ -5025,20 +5025,11 @@ if true; then ###[ '!' -f "$outpath/bin/qmake" ];
             EXTRA_CXXFLAGS="$EXTRA_CXXFLAGS \$(CARBON_CFLAGS)"
             EXTRA_OBJS="qsettings_mac.o qcore_mac.o"
             EXTRA_SRCS="\"$relpath/src/corelib/io/qsettings_mac.cpp\" \"$relpath/src/corelib/kernel/qcore_mac.cpp\""
-	    if echo "$CFG_MAC_ARCHS" | grep x86 > /dev/null 2>&1; then # matches both x86 and x86_64
-		X86_CFLAGS="-arch i386"
-		X86_LFLAGS="-arch i386"
-		EXTRA_CFLAGS="$X86_CFLAGS $EXTRA_CFLAGS"
-		EXTRA_CXXFLAGS="$X86_CFLAGS $EXTRA_CXXFLAGS"
-                EXTRA_LFLAGS="$EXTRA_LFLAGS $X86_LFLAGS"
-            fi
-	    if echo "$CFG_MAC_ARCHS" | grep ppc > /dev/null 2>&1; then # matches both ppc and ppc64
-		PPC_CFLAGS="-arch ppc"
-		PPC_LFLAGS="-arch ppc"
-		EXTRA_CFLAGS="$PPC_CFLAGS $EXTRA_CFLAGS"
-		EXTRA_CXXFLAGS="$PPC_CFLAGS $EXTRA_CXXFLAGS"
-                EXTRA_LFLAGS="$EXTRA_LFLAGS $PPC_LFLAGS"
-            fi
+        for arch in $CFG_MAC_ARCHS; do
+            EXTRA_CFLAGS="-arch $arch $EXTRA_CFLAGS"
+            EXTRA_CXXFLAGS="-arch $arch $EXTRA_CXXFLAGS"
+            EXTRA_LFLAGS="-arch $arch $EXTRA_LFLAGS"
+        done
 	    if [ '!' -z "$CFG_SDK" ]; then
 		echo "SDK_LFLAGS =-Wl,-syslibroot,$CFG_SDK" >>"$mkfile"
 		echo "SDK_CFLAGS =-isysroot $CFG_SDK" >>"$mkfile"
diff --git a/config.tests/mac/defaultarch.test b/config.tests/mac/defaultarch.test
index 80f244a..3bd7476 100644
--- a/config.tests/mac/defaultarch.test
+++ b/config.tests/mac/defaultarch.test
@@ -28,6 +28,9 @@ fi
 if echo "$FIlE_OUTPUT" | grep '\<ppc64\>' > /dev/null 2>&1; then
     QT_MAC_DEFAULT_ARCH=ppc64
 fi
+if echo "$FIlE_OUTPUT" | grep '\<arm64\>' > /dev/null 2>&1; then
+    QT_MAC_DEFAULT_ARCH=arm64
+fi

 [ "$VERBOSE" = "yes" ] && echo "setting QT_MAC_DEFAULT_ARCH to \"$QT_MAC_DEFAULT_ARCH\""
 export QT_MAC_DEFAULT_ARCH
diff --git a/mkspecs/common/gcc-base-macx.conf b/mkspecs/common/gcc-base-macx.conf
index 2894f86..641d015 100644
--- a/mkspecs/common/gcc-base-macx.conf
+++ b/mkspecs/common/gcc-base-macx.conf
@@ -16,12 +16,14 @@ QMAKE_CFLAGS_X86    += -arch i386
 QMAKE_CFLAGS_X86_64 += -arch x86_64
 QMAKE_CFLAGS_PPC    += -arch ppc
 QMAKE_CFLAGS_PPC_64 += -arch ppc64
+QMAKE_CFLAGS_ARM64  += -arch arm64
 QMAKE_CFLAGS_DWARF2 += -gdwarf-2

 QMAKE_CXXFLAGS_X86    += $$QMAKE_CFLAGS_X86
 QMAKE_CXXFLAGS_X86_64 += $$QMAKE_CFLAGS_X86_64
 QMAKE_CXXFLAGS_PPC    += $$QMAKE_CFLAGS_PPC
 QMAKE_CXXFLAGS_PPC_64 += $$QMAKE_CFLAGS_PPC_64
+QMAKE_CXXFLAGS_ARM64  += $$QMAKE_CFLAGS_ARM64
 QMAKE_CXXFLAGS_DWARF2 += $$QMAKE_CFLAGS_DWARF2

 QMAKE_OBJECTIVE_CFLAGS          = $$QMAKE_CFLAGS
@@ -34,11 +36,13 @@ QMAKE_OBJECTIVE_CFLAGS_X86      = $$QMAKE_CFLAGS_X86
 QMAKE_OBJECTIVE_CFLAGS_X86_64   = $$QMAKE_CFLAGS_X86_64
 QMAKE_OBJECTIVE_CFLAGS_PPC      = $$QMAKE_CFLAGS_PPC
 QMAKE_OBJECTIVE_CFLAGS_PPC_64   = $$QMAKE_CFLAGS_PPC_64
+QMAKE_OBJECTIVE_CFLAGS_ARM64    = $$QMAKE_CFLAGS_ARM64

 QMAKE_LFLAGS_X86    += $$QMAKE_CFLAGS_X86
 QMAKE_LFLAGS_X86_64 += $$QMAKE_CFLAGS_X86_64
 QMAKE_LFLAGS_PPC    += $$QMAKE_CFLAGS_PPC
 QMAKE_LFLAGS_PPC_64 += $$QMAKE_CFLAGS_PPC_64
+QMAKE_LFLAGS_ARM64  += $$QMAKE_CFLAGS_ARM64

 QMAKE_LFLAGS                += -headerpad_max_install_names
 QMAKE_LFLAGS_SHLIB          += -single_module -dynamiclib
diff --git a/mkspecs/features/mac/arm64.prf b/mkspecs/features/mac/arm64.prf
new file mode 100644
index 0000000..ad80e91
--- /dev/null
+++ b/mkspecs/features/mac/arm64.prf
@@ -0,0 +1,7 @@
+macx-xcode|macx-pbuilder {
+} else {
+   QMAKE_CFLAGS += $$QMAKE_CFLAGS_ARM64
+   QMAKE_OBJECTIVE_CFLAGS += $$QMAKE_OBJECTIVE_CFLAGS_ARM64
+   QMAKE_CXXFLAGS += $$QMAKE_CXXFLAGS_ARM64
+   QMAKE_LFLAGS += $$QMAKE_LFLAGS_ARM64
+}
diff --git a/mkspecs/features/mac/default_post.prf b/mkspecs/features/mac/default_post.prf
index 273094d..fff1479 100644
--- a/mkspecs/features/mac/default_post.prf
+++ b/mkspecs/features/mac/default_post.prf
@@ -14,4 +14,5 @@ qt:!isEmpty(QT_CONFIG) {
         !contains(QT_CONFIG, x86_64):contains(QT_CONFIG, x86):CONFIG += x86
         contains(QT_CONFIG, x86_64):!contains(QT_CONFIG, x86):CONFIG += x86_64
     }
+    contains(QT_CONFIG, arm64):CONFIG += arm64
 }
diff --git a/src/gui/kernel/qwidget.cpp b/src/gui/kernel/qwidget.cpp
index 13339c0..2a9e47a 100644
--- a/src/gui/kernel/qwidget.cpp
+++ b/src/gui/kernel/qwidget.cpp
@@ -2758,7 +2758,7 @@ void QWidgetPrivate::setStyle_helper(QStyle *newStyle, bool propagate, bool
     Q_Q(QWidget);
     QStyle *oldStyle  = q->style();
 #ifndef QT_NO_STYLE_STYLESHEET
-    QWeakPointer<QStyle> origStyle;
+    QPointer<QStyle> origStyle;
 #endif

 #ifdef Q_WS_MAC
diff --git a/mkspecs/unsupported/macx-clang-libc++/qmake.conf b/mkspecs/unsupported/macx-clang-libc++/qmake.conf
index 870d3e6..2b86999 100644
--- a/mkspecs/unsupported/macx-clang-libc++/qmake.conf
+++ b/mkspecs/unsupported/macx-clang-libc++/qmake.conf
@@ -16,7 +16,8 @@ include(../../common/clang.conf)
 QMAKE_MACOSX_DEPLOYMENT_TARGET = 10.9 # Libc++ is available from 10.7 onwards

 QMAKE_CFLAGS += -mmacosx-version-min=$$QMAKE_MACOSX_DEPLOYMENT_TARGET
-QMAKE_CXXFLAGS += -stdlib=libc++ -mmacosx-version-min=$$QMAKE_MACOSX_DEPLOYMENT_TARGET
+QMAKE_CXXFLAGS += -stdlib=libc++ -mmacosx-version-min=$$QMAKE_MACOSX_DEPLOYMENT_TARGET -Wno-c++11-narrowing -std=c++11
+QMAKE_OBJECTIVE_CFLAGS += -Wno-c++11-narrowing
 QMAKE_LFLAGS += -stdlib=libc++ -mmacosx-version-min=$$QMAKE_MACOSX_DEPLOYMENT_TARGET

 QMAKE_OBJCFLAGS_PRECOMPILE       = -x objective-c-header -c ${QMAKE_PCH_INPUT} -o ${QMAKE_PCH_OUTPUT}
diff --git a/src/3rdparty/javascriptcore/JavaScriptCore/bytecompiler/BytecodeGenerator.cpp b/src/3rdparty/javascriptcore/JavaScriptCore/bytecompiler/BytecodeGenerator.cpp
index b0a0877..1e899c5 100644
--- a/src/3rdparty/javascriptcore/JavaScriptCore/bytecompiler/BytecodeGenerator.cpp
+++ b/src/3rdparty/javascriptcore/JavaScriptCore/bytecompiler/BytecodeGenerator.cpp
@@ -1837,7 +1837,7 @@ RegisterID* BytecodeGenerator::emitCatch(RegisterID* targetRegister, Label* star
 #if ENABLE(JIT)
     HandlerInfo info = { start->bind(0, 0), end->bind(0, 0), instructions().size(), m_dynamicScopeDepth + m_baseScopeDepth, CodeLocationLabel() };
 #else
-    HandlerInfo info = { start->bind(0, 0), end->bind(0, 0), instructions().size(), m_dynamicScopeDepth + m_baseScopeDepth };
+    HandlerInfo info = { static_cast<uint32_t>(start->bind(0, 0)), static_cast<uint32_t>(end->bind(0, 0)), static_cast<uint32_t>(instructions().size()), static_cast<uint32_t>(m_dynamicScopeDepth + m_baseScopeDepth) };
 #endif

     m_codeBlock->addExceptionHandler(info);
@@ -1889,7 +1889,7 @@ void BytecodeGenerator::emitPushNewScope(RegisterID* dst, const Identifier& prop

 void BytecodeGenerator::beginSwitch(RegisterID* scrutineeRegister, SwitchInfo::SwitchType type)
 {
-    SwitchInfo info = { instructions().size(), type };
+    SwitchInfo info = { static_cast<uint32_t>(instructions().size()), type };
     switch (type) {
         case SwitchInfo::SwitchImmediate:
             emitOpcode(op_switch_imm);
diff --git a/src/3rdparty/javascriptcore/JavaScriptCore/bytecompiler/BytecodeGenerator.h b/src/3rdparty/javascriptcore/JavaScriptCore/bytecompiler/BytecodeGenerator.h
index 8b6a425..af74e60 100644
--- a/src/3rdparty/javascriptcore/JavaScriptCore/bytecompiler/BytecodeGenerator.h
+++ b/src/3rdparty/javascriptcore/JavaScriptCore/bytecompiler/BytecodeGenerator.h
@@ -176,7 +176,7 @@ namespace JSC {
             // Node::emitCode assumes that dst, if provided, is either a local or a referenced temporary.
             ASSERT(!dst || dst == ignoredResult() || !dst->isTemporary() || dst->refCount());
             if (!m_codeBlock->numberOfLineInfos() || m_codeBlock->lastLineInfo().lineNumber != n->lineNo()) {
-                LineInfo info = { instructions().size(), n->lineNo() };
+                LineInfo info = { static_cast<uint32_t>(instructions().size()), n->lineNo() };
                 m_codeBlock->addLineInfo(info);
             }
             if (m_emitNodeDepth >= s_maxEmitNodeDepth)
@@ -195,7 +195,7 @@ namespace JSC {
         void emitNodeInConditionContext(ExpressionNode* n, Label* trueTarget, Label* falseTarget, bool fallThroughMeansTrue)
         {
             if (!m_codeBlock->numberOfLineInfos() || m_codeBlock->lastLineInfo().lineNumber != n->lineNo()) {
-                LineInfo info = { instructions().size(), n->lineNo() };
+                LineInfo info = { static_cast<uint32_t>(instructions().size()), n->lineNo() };
                 m_codeBlock->addLineInfo(info);
             }
             if (m_emitNodeDepth >= s_maxEmitNodeDepth)
diff --git a/src/3rdparty/javascriptcore/JavaScriptCore/runtime/Identifier.cpp b/src/3rdparty/javascriptcore/JavaScriptCore/runtime/Identifier.cpp
index 747c4ac..ec53620 100644
--- a/src/3rdparty/javascriptcore/JavaScriptCore/runtime/Identifier.cpp
+++ b/src/3rdparty/javascriptcore/JavaScriptCore/runtime/Identifier.cpp
@@ -195,7 +195,7 @@ PassRefPtr<UString::Rep> Identifier::add(JSGlobalData* globalData, const UChar*
         UString::Rep::empty().hash();
         return &UString::Rep::empty();
     }
-    UCharBuffer buf = {s, length}; 
+    UCharBuffer buf = {s, static_cast<unsigned int>(length)};
     pair<HashSet<UString::Rep*>::iterator, bool> addResult = globalData->identifierTable->add<UCharBuffer, UCharBufferTranslator>(buf);

     // If the string is newly-translated, then we need to adopt it.
diff --git a/src/3rdparty/javascriptcore/JavaScriptCore/runtime/JSONObject.cpp b/src/3rdparty/javascriptcore/JavaScriptCore/runtime/JSONObject.cpp
index b089584..fc57279 100644
--- a/src/3rdparty/javascriptcore/JavaScriptCore/runtime/JSONObject.cpp
+++ b/src/3rdparty/javascriptcore/JavaScriptCore/runtime/JSONObject.cpp
@@ -320,7 +320,7 @@ void Stringifier::appendQuotedString(StringBuilder& builder, const UString& valu
             default:
                 static const char hexDigits[] = "0123456789abcdef";
                 UChar ch = data[i];
-                UChar hex[] = { '\\', 'u', hexDigits[(ch >> 12) & 0xF], hexDigits[(ch >> 8) & 0xF], hexDigits[(ch >> 4) & 0xF], hexDigits[ch & 0xF] };
+                UChar hex[] = { '\\', 'u', static_cast<UChar>(hexDigits[(ch >> 12) & 0xF]), static_cast<UChar>(hexDigits[(ch >> 8) & 0xF]), static_cast<UChar>(hexDigits[(ch >> 4) & 0xF]), static_cast<UChar>(hexDigits[ch & 0xF]) };
                 builder.append(hex, sizeof(hex) / sizeof(UChar));
                 break;
         }
diff --git a/src/3rdparty/javascriptcore/JavaScriptCore/runtime/Structure.cpp b/src/3rdparty/javascriptcore/JavaScriptCore/runtime/Structure.cpp
index 499c53a..5cb7994 100644
--- a/src/3rdparty/javascriptcore/JavaScriptCore/runtime/Structure.cpp
+++ b/src/3rdparty/javascriptcore/JavaScriptCore/runtime/Structure.cpp
@@ -157,7 +157,7 @@ Structure::~Structure()
 {
     if (m_previous) {
         if (m_nameInPrevious)
-            m_previous->table.remove(StructureTransitionTableHash::Key(RefPtr<UString::Rep>(m_nameInPrevious.get()), m_attributesInPrevious), m_specificValueInPrevious);
+            m_previous->table.remove(StructureTransitionTableHash::Key(RefPtr<UString::Rep>(m_nameInPrevious.get()), static_cast<unsigned>(m_attributesInPrevious)), m_specificValueInPrevious);
         else
             m_previous->table.removeAnonymousSlotTransition(m_anonymousSlotsInPrevious);

diff --git a/src/3rdparty/javascriptcore/JavaScriptCore/runtime/Structure.h b/src/3rdparty/javascriptcore/JavaScriptCore/runtime/Structure.h
index 7571efc..6c8ed9c 100644
--- a/src/3rdparty/javascriptcore/JavaScriptCore/runtime/Structure.h
+++ b/src/3rdparty/javascriptcore/JavaScriptCore/runtime/Structure.h
@@ -317,7 +317,7 @@ namespace JSC {
         TransitionTable* transitionTable = new TransitionTable;
         setTransitionTable(transitionTable);
         if (existingTransition)
-            add(StructureTransitionTableHash::Key(RefPtr<UString::Rep>(existingTransition->m_nameInPrevious.get()), existingTransition->m_attributesInPrevious), existingTransition, existingTransition->m_specificValueInPrevious);
+            add(StructureTransitionTableHash::Key(RefPtr<UString::Rep>(existingTransition->m_nameInPrevious.get()), static_cast<unsigned>(existingTransition->m_attributesInPrevious)), existingTransition, existingTransition->m_specificValueInPrevious);
     }
 } // namespace JSC

diff --git a/src/3rdparty/javascriptcore/JavaScriptCore/wtf/MathExtras.h b/src/3rdparty/javascriptcore/JavaScriptCore/wtf/MathExtras.h
index 9e2e638..0b2d1d5 100644
--- a/src/3rdparty/javascriptcore/JavaScriptCore/wtf/MathExtras.h
+++ b/src/3rdparty/javascriptcore/JavaScriptCore/wtf/MathExtras.h
@@ -67,7 +67,7 @@ const float piOverFourFloat = static_cast<float>(M_PI_4);
 // Work around a bug in the Mac OS X libc where ceil(-0.1) return +0.
 inline double wtf_ceil(double x) { return copysign(ceil(x), x); }

-#define ceil(x) wtf_ceil(x)
+// #define ceil(x) wtf_ceil(x)

 #endif

diff --git a/src/3rdparty/libpng/pngpriv.h b/src/3rdparty/libpng/pngpriv.h
index 4031d73..7d692d7 100644
--- a/src/3rdparty/libpng/pngpriv.h
+++ b/src/3rdparty/libpng/pngpriv.h
@@ -415,7 +415,7 @@
       * <fp.h> if possible.
       */
 #    if !defined(__MATH_H__) && !defined(__MATH_H) && !defined(__cmath__)
-#      include <fp.h>
+#      include <math.h>
 #    endif
 #  else
 #    include <math.h>
diff --git a/src/corelib/arch/qatomic_macosx.h b/src/corelib/arch/qatomic_macosx.h
index c6a4481..094a0c9 100644
--- a/src/corelib/arch/qatomic_macosx.h
+++ b/src/corelib/arch/qatomic_macosx.h
@@ -48,6 +48,8 @@ QT_BEGIN_HEADER
 #  include <QtCore/qatomic_x86_64.h>
 #elif defined(__i386__)
 #  include <QtCore/qatomic_i386.h>
+#elif defined(__aarch64__)
+#  include <QtCore/qatomic_aarch64.h>
 #else // !__x86_64 && !__i386__
 #  include <QtCore/qatomic_powerpc.h>
 #endif // !__x86_64__ && !__i386__
diff --git a/src/corelib/io/qfilesystemwatcher_fsevents.cpp b/src/corelib/io/qfilesystemwatcher_fsevents.cpp
index 87868f7..53747e4 100644
--- a/src/corelib/io/qfilesystemwatcher_fsevents.cpp
+++ b/src/corelib/io/qfilesystemwatcher_fsevents.cpp
@@ -74,7 +74,7 @@ static bool operator==(const struct ::timespec &left, const struct ::timespec &r
             && left.tv_nsec == right.tv_nsec;
 }

-static bool operator==(const struct ::stat64 &left, const struct ::stat64 &right)
+static bool operator==(const struct ::stat &left, const struct ::stat &right)
 {
     return left.st_dev == right.st_dev
             && left.st_mode == right.st_mode
@@ -87,7 +87,7 @@ static bool operator==(const struct ::stat64 &left, const struct ::stat64 &right
             && left.st_flags == right.st_flags;
 }

-static bool operator!=(const struct ::stat64 &left, const struct ::stat64 &right)
+static bool operator!=(const struct ::stat &left, const struct ::stat &right)
 {
     return !(operator==(left, right));
 }
@@ -344,8 +344,8 @@ void QFSEventsFileSystemWatcherEngine::updateList(PathInfoList &list, bool direc
     PathInfoList::iterator End = list.end();
     PathInfoList::iterator it = list.begin();
     while (it != End) {
-        struct ::stat64 newInfo;
-        if (::stat64(it->absolutePath, &newInfo) == 0) {
+        struct ::stat newInfo;
+        if (::stat(it->absolutePath, &newInfo) == 0) {
             if (emitSignals) {
                 if (newInfo != it->savedInfo) {
                     it->savedInfo = newInfo;
diff --git a/src/corelib/io/qfilesystemwatcher_fsevents_p.h b/src/corelib/io/qfilesystemwatcher_fsevents_p.h
index 84f196f..0dcb413 100644
--- a/src/corelib/io/qfilesystemwatcher_fsevents_p.h
+++ b/src/corelib/io/qfilesystemwatcher_fsevents_p.h
@@ -83,7 +83,7 @@ struct PathInfo {
             : originalPath(path), absolutePath(absPath) {}
     QString originalPath; // The path we need to emit
     QByteArray absolutePath; // The path we need to stat.
-    struct ::stat64 savedInfo;  // All the info for the path so we can compare it.
+    struct ::stat savedInfo;  // All the info for the path so we can compare it.
 };
 typedef QLinkedList<PathInfo> PathInfoList;
 typedef QHash<QString, PathInfoList> PathHash;
diff --git a/src/gui/kernel/qcocoamenuloader_mac.mm b/src/gui/kernel/qcocoamenuloader_mac.mm
index ca2481f..06ba415 100644
--- a/src/gui/kernel/qcocoamenuloader_mac.mm
+++ b/src/gui/kernel/qcocoamenuloader_mac.mm
@@ -125,7 +125,7 @@ - (void)ensureAppMenuInMenu:(NSMenu *)menu
 - (void)removeActionsFromAppMenu
 {
     for (NSMenuItem *item in [appMenu itemArray])
-        [item setTag:nil];
+        [item setTag:NULL];
 }

 - (void)dealloc
diff --git a/src/gui/kernel/qcursor_mac.mm b/src/gui/kernel/qcursor_mac.mm
index c8ccf75..48aed2f 100644
--- a/src/gui/kernel/qcursor_mac.mm
+++ b/src/gui/kernel/qcursor_mac.mm
@@ -319,7 +319,7 @@ void qt_mac_update_cursor_at_global_pos(const QPoint &globalPos)
     pos.x = x;
     pos.y = y;

-    CGEventRef e = CGEventCreateMouseEvent(0, kCGEventMouseMoved, pos, 0);
+    CGEventRef e = CGEventCreateMouseEvent(0, kCGEventMouseMoved, pos, kCGMouseButtonLeft);
     CGEventPost(kCGHIDEventTap, e);
     CFRelease(e);
 #else
diff --git a/src/gui/kernel/qwidget_mac.mm b/src/gui/kernel/qwidget_mac.mm
index 5730020..57c8114 100644
--- a/src/gui/kernel/qwidget_mac.mm
+++ b/src/gui/kernel/qwidget_mac.mm
@@ -3620,7 +3620,7 @@ QPoint qt_mac_nativeMapFromParent(const QWidget *child, const QPoint &pt)
 #else
             // Only needed if it exists from 10.7 or later
             if ((q->windowType() == Qt::Tool) && [window respondsToSelector: @selector(setAnimationBehavior:)])
-                [window setAnimationBehavior: 2]; // NSWindowAnimationBehaviorNone == 2
+                [window setAnimationBehavior: NSWindowAnimationBehaviorNone]; // NSWindowAnimationBehaviorNone == 2

             [window orderOut:window];
             // Unfortunately it is not as easy as just hiding the window, we need
diff --git a/src/gui/text/qfontdatabase_mac.cpp b/src/gui/text/qfontdatabase_mac.cpp
index 816a7bd..3897b5b 100644
--- a/src/gui/text/qfontdatabase_mac.cpp
+++ b/src/gui/text/qfontdatabase_mac.cpp
@@ -165,7 +165,7 @@ if (QSysInfo::MacintoshVersion >= QSysInfo::MV_10_5) {
         QString styleName = style_name;
         if(QCFType<CFDictionaryRef> styles = (CFDictionaryRef)CTFontDescriptorCopyAttribute(font, kCTFontTraitsAttribute)) {
             if(CFNumberRef weight = (CFNumberRef)CFDictionaryGetValue(styles, kCTFontWeightTrait)) {
-                Q_ASSERT(CFNumberIsFloatType(weight));
+                // Q_ASSERT(CFNumberIsFloatType(weight));
                 double d;
                 if(CFNumberGetValue(weight, kCFNumberDoubleType, &d)) {
                     //qDebug() << "BOLD" << (QString)family_name << d;
@@ -173,7 +173,7 @@ if (QSysInfo::MacintoshVersion >= QSysInfo::MV_10_5) {
                 }
             }
             if(CFNumberRef italic = (CFNumberRef)CFDictionaryGetValue(styles, kCTFontSlantTrait)) {
-                Q_ASSERT(CFNumberIsFloatType(italic));
+                // Q_ASSERT(CFNumberIsFloatType(italic));
                 double d;
                 if(CFNumberGetValue(italic, kCFNumberDoubleType, &d)) {
                     //qDebug() << "ITALIC" << (QString)family_name << d;
diff --git a/src/gui/widgets/qmenu_mac.mm b/src/gui/widgets/qmenu_mac.mm
index 6a9cbc7..cfdb8a4 100644
--- a/src/gui/widgets/qmenu_mac.mm
+++ b/src/gui/widgets/qmenu_mac.mm
@@ -769,7 +769,7 @@ bool qt_mac_menubar_is_open()
                    && menuItem != [getMenuLoader() quitMenuItem]) {
             [menuItem setHidden:YES];
         }
-        [menuItem setTag:nil];
+        [menuItem setTag:NULL];
     }
     [menuItem release];
 #endif
diff --git a/src/plugins/accessible/widgets/itemviews.cpp b/src/plugins/accessible/widgets/itemviews.cpp
index 14c9279..516f2e2 100644
--- a/src/plugins/accessible/widgets/itemviews.cpp
+++ b/src/plugins/accessible/widgets/itemviews.cpp
@@ -393,7 +393,7 @@ bool QAccessibleTable2::unselectColumn(int column)
     QModelIndex index = view()->model()->index(0, column, view()->rootIndex());
     if (!index.isValid() || view()->selectionMode() & QAbstractItemView::NoSelection)
         return false;
-    view()->selectionModel()->select(index, QItemSelectionModel::Columns & QItemSelectionModel::Deselect);
+    view()->selectionModel()->select(index, QItemSelectionModel::Columns | QItemSelectionModel::Deselect);
     return true;
 }

diff --git a/src/xmlpatterns/api/qcoloroutput_p.h b/src/xmlpatterns/api/qcoloroutput_p.h
index 7911e89..eb249e1 100644
--- a/src/xmlpatterns/api/qcoloroutput_p.h
+++ b/src/xmlpatterns/api/qcoloroutput_p.h
@@ -71,7 +71,7 @@ namespace QPatternist
             BackgroundShift = 20,
             SpecialShift    = 20,
             ForegroundMask  = ((1 << ForegroundShift) - 1) << ForegroundShift,
-            BackgroundMask  = ((1 << BackgroundShift) - 1) << BackgroundShift
+            BackgroundMask  = ((1ull << BackgroundShift) - 1ull) << BackgroundShift
         };

     public:
