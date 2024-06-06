class WpProjectScaffold < Formula
  desc "Scaffolds a WordPress project using Docker and optionally a starter theme"
  homepage "https://github.com/somoscuatro/homebrew-wp-project-scaffold"
  url "https://github.com/somoscuatro/homebrew-wp-project-scaffold/archive/refs/tags/v0.7.0.tar.gz"
  sha256 "c8094f59fcbca24ee2c77a4381352999131e9b1ec6b5233587b06055ca1b4a4e"
  license "MIT"

  def install
    bin.install "wp-project-scaffold.sh" => "wp-project-scaffold"
  end

  test do
    system "false"
  end
end
