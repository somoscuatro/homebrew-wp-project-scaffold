class WpProjectScaffold < Formula
  desc "Scaffolds a WordPress project using Docker and optionally a starter theme"
  homepage "https://github.com/somoscuatro/homebrew-wp-project-scaffold"
  url "https://github.com/somoscuatro/homebrew-wp-project-scaffold/archive/refs/tags/v1.0.1.tar.gz"
  sha256 "0672a15fd6a94ea9e77c66dceaba99cfaaf10ebde93fb5a3cb0ed1ebc14b7ada"
  license "MIT"

  def install
    bin.install "wp-project-scaffold.sh" => "wp-project-scaffold"
  end

  test do
    wp-project-scaffold --version
  end
end
