class WpProjectScaffold < Formula
  desc "Scaffolds a WordPress project using Docker and optionally a starter theme"
  homepage "https://github.com/somoscuatro/homebrew-wp-project-scaffold"
  url "https://github.com/somoscuatro/homebrew-wp-project-scaffold/archive/refs/tags/v1.0.1.tar.gz"
  sha256 "61cd8068e4b03317ad234c430ac99c1a9a927ecd95476896369603460872f903"
  license "MIT"

  def install
    bin.install "wp-project-scaffold.sh" => "wp-project-scaffold"
  end

  test do
    wp-project-scaffold --version
  end
end
