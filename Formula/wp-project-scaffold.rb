class WpProjectScaffold < Formula
  desc "Scaffolds a WordPress project using Docker and optionally a starter theme"
  homepage "https://github.com/somoscuatro/homebrew-wp-project-scaffold"
  url "https://github.com/somoscuatro/homebrew-wp-project-scaffold/archive/refs/tags/v1.0.2.tar.gz"
  sha256 "cd2ac1c9d123726d3125dbf50042189d2a4dd2741233c387c2124a5320125914"
  license "MIT"

  def install
    bin.install "wp-project-scaffold.sh" => "wp-project-scaffold"
  end

  test do
    system "#{bin}/wp-project-scaffold", "--version"
  end
end
