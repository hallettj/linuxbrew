class Jetty < Formula
  desc "Java servlet engine and webserver"
  homepage "https://www.eclipse.org/jetty/"
  url "http://download.eclipse.org/jetty/9.3.5.v20151012/dist/jetty-distribution-9.3.5.v20151012.tar.gz"
  version "9.3.5.v20151012"
  sha256 "24e80e350fcc9749aa4a29913c34917ad238a0fa3abdb7d7c9b42dc40bdf0f9b"

  bottle do
    cellar :any
    sha256 "c83bfa38c5a87e0f394d09be3b25ac9d0ec98eef4e4215cc7927965bcc3fe168" => :el_capitan
    sha256 "91f0318109ad2ddcc81ea2379177644f5b481bc2b195a0b28f026fd5770cd0c0" => :yosemite
    sha256 "90c4dfedf93efaabef6e169d9349248e95ca130a97761d6748880edd6dcde9c4" => :mavericks
  end

  depends_on :java => "1.8+"

  def install
    libexec.install Dir["*"]
    (libexec+"logs").mkpath

    bin.mkpath
    Dir.glob("#{libexec}/bin/*.sh") do |f|
      scriptname = File.basename(f, ".sh")
      (bin+scriptname).write <<-EOS.undent
        #!/bin/bash
        JETTY_HOME=#{libexec}
        #{f} "$@"
      EOS
      chmod 0755, bin+scriptname
    end
  end

  test do
    ENV["JETTY_BASE"] = testpath
    cp_r Dir[libexec/"*"], testpath
    pid = fork { exec bin/"jetty", "start" }
    sleep 5 # grace time for server start
    begin
      assert_match /Jetty running pid=\d+/, shell_output("#{bin}/jetty check")
      assert_equal "Stopping Jetty: OK\n", shell_output("#{bin}/jetty stop")
    ensure
      Process.kill 9, pid
      Process.wait pid
    end
  end
end
