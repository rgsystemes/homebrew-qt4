# https://github.com/Homebrew/homebrew-core/blob/74b89e5b9ca3bd773012e016e74fd23cdc4483f7/Formula/f/freetds.rb
class Freetds < Formula
  desc "Libraries to talk to Microsoft SQL Server and Sybase databases"
  homepage "https://www.freetds.org/"
  url "https://www.freetds.org/files/stable/freetds-1.5.18.tar.bz2"
  sha256 "6b2c8b93b9ee7c83855daf745de5878790032f14dbaee553d83a9d211b84dd4b"
  license "GPL-2.0-or-later"
  compatibility_version 1

  livecheck do
    url "https://www.freetds.org/files/stable/"
    regex(/href=.*?freetds[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    sha256 arm64_tahoe:   "04255031703dd87bc594f1bba35bd507eb75ab0a7df0b1fa85fc64d6a8798791"
    sha256 arm64_sequoia: "4227980af018668e860120a319066f8c701823156821d806de69d089198ed2c3"
    sha256 arm64_sonoma:  "955417a5ee2d8fc5259ae59549f78bf9bd7f81b2f188caf4545740137236ffee"
    sha256 sonoma:        "6fcee5bc09ff8ffec162a2d6ba547fa7f5930381303e6dfacd8b0f2534412796"
    sha256 arm64_linux:   "7296b8bd471f270f419e4ce39d713b2a7961bca5eba6df0777f56e4bbc869456"
    sha256 x86_64_linux:  "79349cab9e40ae1e20506398940d6765caa81602c9a57f7cb7874d9e55b288a8"
  end

  head do
    url "https://github.com/FreeTDS/freetds.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "gettext" => :build
    depends_on "libtool" => :build
  end

  option "with-universal", "Build a universal binary (x86_64 + arm64)"

  depends_on "pkgconf" => :build
  depends_on "openssl@1.0"
  depends_on "unixodbc"

  uses_from_macos "krb5"

  on_linux do
    depends_on "readline"
  end

  def install
    if build.with?("universal")
      arch_flags = "-arch x86_64 -arch arm64"
      ENV.append "CFLAGS",   arch_flags
      ENV.append "CXXFLAGS", arch_flags
      ENV.append "LDFLAGS",  arch_flags

      # Homebrew's compiler shim (first on PATH) injects its own -arch flags
      # *and* a host-arch -march=westmere flag directly into the clang
      # invocation, regardless of CFLAGS content — that -march flag is invalid
      # whenever -arch arm64 is also present. Bypass the shim entirely by
      # putting the real system clang first on PATH for this build.
      ENV["PATH"] = "/usr/bin:#{ENV["PATH"]}"
    end

    args = %W[
      --prefix=#{prefix}
      --with-tdsver=7.3
      --mandir=#{man}
      --sysconfdir=#{etc}
      --with-unixodbc=#{Formula["unixodbc"].opt_prefix}
      --with-openssl=#{Formula["openssl@1.0"].opt_prefix}
      --enable-sybase-compat
      --enable-krb5
      --enable-odbc-wide
    ]

    configure = build.head? ? "./autogen.sh" : "./configure"
    system configure, *args
    system "make"
    ENV.deparallelize # Or fails to install on multi-core machines
    system "make", "install"
  end

  test do
    system bin/"tsql", "-C"
  end
end
