class WpScaffold < Formula
  desc "Scaffolds a WordPress project using Docker and optionally a starter theme"
  homepage "https://github.com/somoscuatro/homebrew-wp-scaffold"
  url "https://github.com/somoscuatro/homebrew-wp-scaffold/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "99b0eb23407c473c71b384a33aed3bb3bacaccb23e4f3e0807a7646ae3def580"
  license "MIT"

  def install
    bin.install "wp-scaffold"
  end

  test do
    system "false"
  end
end
