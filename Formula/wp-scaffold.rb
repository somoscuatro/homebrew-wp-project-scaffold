class WpScaffold < Formula
  desc "Scaffolds a WordPress project using Docker and optionally a starter theme"
  homepage "https://github.com/somoscuatro/homebrew-wp-scaffold"
  url "https://github.com/somoscuatro/homebrew-wp-scaffold/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "abcfc0d0c66f4ab641a983db73f9093580f17a775827b77518589a8b1a42a938"
  license "MIT"

  def install
    bin.install "wp-scaffold"
  end

  test do
    system "false"
  end
end
