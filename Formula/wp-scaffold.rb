class WpScaffold < Formula
  desc "Scaffolds a WordPress project using Docker and optionally a starter theme"
  homepage "https://github.com/somoscuatro/homebrew-wp-scaffold"
  url "https://github.com/somoscuatro/homebrew-wp-scaffold/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "eff346ed4dae2bbbab9b538ff0c269afe76cae8d3f2ebe6d49ca0eb8b3983521"
  license "MIT"

  def install
    bin.install "wp-scaffold.sh"
  end

  test do
    system "false"
  end
end
