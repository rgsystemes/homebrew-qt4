class OpensslAT10 < Formula
  desc "SSL/TLS cryptography library"
  homepage "https://openssl.org/"
  url "https://www.openssl.org/source/openssl-1.0.2u.tar.gz"
  mirror "https://dl.bintray.com/homebrew/mirror/openssl-1.0.2u.tar.gz"
  mirror "https://www.mirrorservice.org/sites/ftp.openssl.org/source/openssl-1.0.2u.tar.gz"
  sha256 "ecd0c6ffb493dd06707d38b14bb4d8c2288bb7033735606569d8f90f89669d16"

  bottle do
    root_url "https://github.com/cartr/homebrew-qt4-bottles/releases/download/autobottle-qt4"
    sha256 mojave:      "faa8d3dc06601237a6f42a93ec6d8b0229426f01ea109e3fab691ac1cf9fd681"
    sha256 high_sierra: "6d2269e690b2ddc182fa1148bb44e25b1172b6516caefad709158e736da94b46"
  end

  option "with-universal", "Build a universal binary (x86_64 + arm64)"

  keg_only :provided_by_macos,
    "Apple has deprecated use of OpenSSL in favor of its own TLS and crypto libraries"

  # Add darwin64-arm64-cc & debug-darwin64-arm64-cc build targets.
  patch :DATA

  def install
    # OpenSSL will prefer the PERL environment variable if set over $PATH
    # which can cause some odd edge cases & isn't intended. Unset for safety,
    # along with perl modules in PERL5LIB.
    ENV.delete("PERL")
    ENV.delete("PERL5LIB")

    # -O2 or greater with clang > 13 causes elliptic curve miscompilation on arm64
    if OS.mac? and Hardware::CPU.arm? and MacOS.version >= :monterey
      ENV.O1 if ENV.compiler == :clang
    end

    ENV.deparallelize

    common_args = %W[
      --prefix=#{prefix}
      --openssldir=#{openssldir}
      no-ssl2
      no-ssl3
      no-zlib
      shared
      enable-cms
    ]

    if build.with? "universal"
      # Tell the Homebrew compiler shim to pass -arch flags through unchanged.
      ENV.permit_arch_flags

      # --- x86_64 pass (with optimised assembly) ---
      system "perl", "./Configure", *common_args, "darwin64-x86_64-cc", "enable-ec_nistp_64_gcc_128"
      system "make", "depend"
      system "make"
      (buildpath/"arch-x86_64").mkpath
      Dir["*.a", "*.dylib"].each do |f|
        cp f, buildpath/"arch-x86_64"/File.basename(f) unless File.symlink?(f)
      end

      # --- arm64 pass (C only — OpenSSL 1.0.2 has no arm64 asm target) ---
      system "make", "clean"
      system "perl", "./Configure", *common_args, "darwin64-arm64-cc", "no-asm"
      system "make", "depend"
      system "make"
      (buildpath/"arch-arm64").mkpath
      Dir["*.a", "*.dylib"].each do |f|
        cp f, buildpath/"arch-arm64"/File.basename(f) unless File.symlink?(f)
      end

      # Install (headers + directory structure come from the arm64 build).
      system "make", "install", "MANDIR=#{man}", "MANSUFFIX=ssl"

      # Replace every installed single-arch library with a fat binary.
      Dir["#{lib}/*.a", "#{lib}/*.dylib"].each do |installed|
        next if File.symlink?(installed)
        name  = File.basename(installed)
        x86   = buildpath/"arch-x86_64"/name
        arm   = buildpath/"arch-arm64"/name
        next unless x86.exist? && arm.exist?
        system "lipo", "-create", x86, arm, "-output", installed
      end
    else
      system "perl", "./Configure", *common_args, "darwin64-x86_64-cc", "enable-ec_nistp_64_gcc_128"
      system "make", "depend"
      system "make"
      system "make", "test"
      system "make", "install", "MANDIR=#{man}", "MANSUFFIX=ssl"
    end
  end

  def openssldir
    etc/"openssl"
  end

  def post_install
    keychains = %w[
      /System/Library/Keychains/SystemRootCertificates.keychain
    ]

    certs_list = `security find-certificate -a -p #{keychains.join(" ")}`
    certs = certs_list.scan(
      /-----BEGIN CERTIFICATE-----.*?-----END CERTIFICATE-----/m,
    )

    valid_certs = certs.select do |cert|
      IO.popen("#{bin}/openssl x509 -inform pem -checkend 0 -noout", "w") do |openssl_io|
        openssl_io.write(cert)
        openssl_io.close_write
      end

      $CHILD_STATUS.success?
    end

    openssldir.mkpath
    (openssldir/"cert.pem").atomic_write(valid_certs.join("\n") << "\n")
  end

  def caveats
    <<~EOS
      A CA file has been bootstrapped using certificates from the SystemRoots
      keychain. To add additional certificates (e.g. the certificates added in
      the System keychain), place .pem files in
        #{openssldir}/certs
      and run
        #{opt_bin}/c_rehash
    EOS
  end

  test do
    # Make sure the necessary .cnf file exists, otherwise OpenSSL gets moody.
    assert_predicate HOMEBREW_PREFIX/"etc/openssl/openssl.cnf", :exist?,
            "OpenSSL requires the .cnf file for some functionality"

    # Check OpenSSL itself functions as expected.
    (testpath/"testfile.txt").write("This is a test file")
    expected_checksum = "e2d0fe1585a63ec6009c8016ff8dda8b17719a637405a4e23c0ff81339148249"
    system "#{bin}/openssl", "dgst", "-sha256", "-out", "checksum.txt", "testfile.txt"
    open("checksum.txt") do |f|
      checksum = f.read(100).split("=").last.strip
      assert_equal checksum, expected_checksum
    end
  end
end

__END__
--- openssl-1.0.2u/Configure	2019-12-20 14:02:41.000000000 +0100
+++ openssl-1.0.2u/Configure	2020-11-22 17:03:42.000000000 +0100
@@ -650,7 +650,9 @@
 "darwin-i386-cc","cc:-arch i386 -O3 -fomit-frame-pointer -DL_ENDIAN::-D_REENTRANT:MACOSX:-Wl,-search_paths_first%:BN_LLONG RC4_INT RC4_CHUNK DES_UNROLL BF_PTR:".eval{my $asm=$x86_asm;$asm=~s/cast\-586\.o//;$asm}.":macosx:dlfcn:darwin-shared:-fPIC -fno-common:-arch i386 -dynamiclib:.\$(SHLIB_MAJOR).\$(SHLIB_MINOR).dylib",
 "debug-darwin-i386-cc","cc:-arch i386 -g3 -DL_ENDIAN::-D_REENTRANT:MACOSX:-Wl,-search_paths_first%:BN_LLONG RC4_INT RC4_CHUNK DES_UNROLL BF_PTR:${x86_asm}:macosx:dlfcn:darwin-shared:-fPIC -fno-common:-arch i386 -dynamiclib:.\$(SHLIB_MAJOR).\$(SHLIB_MINOR).dylib",
 "darwin64-x86_64-cc","cc:-arch x86_64 -O3 -DL_ENDIAN -Wall::-D_REENTRANT:MACOSX:-Wl,-search_paths_first%:SIXTY_FOUR_BIT_LONG RC4_CHUNK DES_INT DES_UNROLL:".eval{my $asm=$x86_64_asm;$asm=~s/rc4\-[^:]+//;$asm}.":macosx:dlfcn:darwin-shared:-fPIC -fno-common:-arch x86_64 -dynamiclib:.\$(SHLIB_MAJOR).\$(SHLIB_MINOR).dylib",
+"darwin64-arm64-cc","cc:-arch arm64 -O3 -DL_ENDIAN -Wall::-D_REENTRANT:MACOSX:-Wl,-search_paths_first%:SIXTY_FOUR_BIT_LONG RC4_CHUNK DES_INT DES_UNROLL:${no_asm}:dlfcn:darwin-shared:-fPIC -fno-common:-arch arm64 -dynamiclib:.\$(SHLIB_MAJOR).\$(SHLIB_MINOR).dylib",
 "debug-darwin64-x86_64-cc","cc:-arch x86_64 -ggdb -g2 -O0 -DL_ENDIAN -Wall::-D_REENTRANT:MACOSX:-Wl,-search_paths_first%:SIXTY_FOUR_BIT_LONG RC4_CHUNK DES_INT DES_UNROLL:".eval{my $asm=$x86_64_asm;$asm=~s/rc4\-[^:]+//;$asm}.":macosx:dlfcn:darwin-shared:-fPIC -fno-common:-arch x86_64 -dynamiclib:.\$(SHLIB_MAJOR).\$(SHLIB_MINOR).dylib",
+"debug-darwin64-arm64-cc","cc:-arch arm64 -ggdb -g2 -O0 -DL_ENDIAN -Wall::-D_REENTRANT:MACOSX:-Wl,-search_paths_first%:SIXTY_FOUR_BIT_LONG RC4_CHUNK DES_INT DES_UNROLL:${no_asm}:dlfcn:darwin-shared:-fPIC -fno-common:-arch arm64 -dynamiclib:.\$(SHLIB_MAJOR).\$(SHLIB_MINOR).dylib",
 "debug-darwin-ppc-cc","cc:-DBN_DEBUG -DREF_CHECK -DCONF_DEBUG -DCRYPTO_MDEBUG -DB_ENDIAN -g -Wall -O::-D_REENTRANT:MACOSX::BN_LLONG RC4_CHAR RC4_CHUNK DES_UNROLL BF_PTR:${ppc32_asm}:osx32:dlfcn:darwin-shared:-fPIC:-dynamiclib:.\$(SHLIB_MAJOR).\$(SHLIB_MINOR).dylib",
 # iPhoneOS/iOS
 "iphoneos-cross","llvm-gcc:-O3 -isysroot \$(CROSS_TOP)/SDKs/\$(CROSS_SDK) -fomit-frame-pointer -fno-common::-D_REENTRANT:iOS:-Wl,-search_paths_first%:BN_LLONG RC4_CHAR RC4_CHUNK DES_UNROLL BF_PTR:${no_asm}:dlfcn:darwin-shared:-fPIC -fno-common:-dynamiclib:.\$(SHLIB_MAJOR).\$(SHLIB_MINOR).dylib",
