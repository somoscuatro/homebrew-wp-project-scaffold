class WpProjectScaffold < Formula
  desc "Scaffolds a WordPress project using Docker and optionally a starter theme"
  homepage "https://github.com/somoscuatro/homebrew-wp-project-scaffold"
  url "https://github.com/somoscuatro/homebrew-wp-project-scaffold/archive/refs/tags/v0.8.0.tar.gz"
  sha256 "ad93965f1922f2b5e5a3d85d422cf8bcd815e87a92aadb3b6e66849520b48843"
  license "MIT"

  def install
    bin.install "wp-project-scaffold.sh" => "wp-project-scaffold"
  end

  test do
    system "false"
  end
end
