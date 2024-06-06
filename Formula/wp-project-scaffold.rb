class WpProjectScaffold < Formula
  desc "Scaffolds a WordPress project using Docker and optionally a starter theme"
  homepage "https://github.com/somoscuatro/homebrew-wp-project-scaffold"
  url "https://github.com/somoscuatro/homebrew-wp-project-scaffold/archive/refs/tags/v0.8.0.tar.gz"
  sha256 "d81757d7432b0cd13d63a91c02b124c7a01c0bbd99c08887228ace215137c2c7"
  license "MIT"

  def install
    bin.install "wp-project-scaffold.sh" => "wp-project-scaffold"
  end

  test do
    system "false"
  end
end
