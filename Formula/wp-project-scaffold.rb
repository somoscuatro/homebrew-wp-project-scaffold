class WpProjectScaffold < Formula
  desc "Scaffolds a WordPress project using Docker and optionally a starter theme"
  homepage "https://github.com/somoscuatro/homebrew-wp-project-scaffold"
  url "https://github.com/somoscuatro/homebrew-wp-project-scaffold/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "4679d86981e12a8020ad0a2435a081252877bc816230245d13c01d510be76a6a"
  license "MIT"

  def install
    bin.install "wp-project-scaffold.sh" => "wp-project-scaffold"
  end

  test do
    system "#{bin}/wp-project-scaffold", "--version"
  end
end
