class WpScaffold < Formula
  desc "Scaffolds a WordPress project using Docker and optionally a starter theme"
  homepage "https://github.com/somoscuatro/homebrew-wp-scaffold"
  url "https://github.com/somoscuatro/homebrew-wp-scaffold/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "d5988fd455696f8366fd2ff453049e485de3dd6dce2a1dab0cc14c48255525fb"
  license "MIT"

  def install
    system "./configure", "--disable-silent-rules", *std_configure_args
  end

  test do
    system "false"
  end
end
