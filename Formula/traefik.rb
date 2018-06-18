class Traefik < Formula
  desc "Modern reverse proxy"
  homepage "https://traefik.io/"
  url "https://github.com/containous/traefik/releases/download/v1.6.4/traefik-v1.6.4.src.tar.gz"
  version "1.6.4"
  sha256 "285d5e765f8caafcf0221ce07c8ca359f5b73ad4cb04a77e2b4479613d3e997a"
  head "https://github.com/containous/traefik.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "93805c42d4af7ca992319432fb1ce5371b09eeee7b61198e71a7d5980e564bac" => :high_sierra
    sha256 "1969a9b403257bed8a9229b44a0ba85cae2a323d9a05c55ea000ec72c3c85fab" => :sierra
    sha256 "4a1f845475e5c57c61535167353312722368d9da7b3106f5a907f7d75b9f21c4" => :el_capitan
  end

  depends_on "go" => :build
  depends_on "go-bindata" => :build
  depends_on "node" => :build
  depends_on "yarn" => :build

  def install
    ENV["GOPATH"] = buildpath
    (buildpath/"src/github.com/containous/traefik").install buildpath.children

    # Fix yarn + upath@1.0.4 incompatibility; remove once upath is upgraded to 1.0.5+
    Pathname.new("#{ENV["HOME"]}/.yarnrc").write("ignore-engines true\n")

    cd "src/github.com/containous/traefik" do
      cd "webui" do
        system "yarn", "install"
        system "yarn", "run", "build"
      end
      system "go", "generate"
      system "go", "build", "-o", bin/"traefik", "./cmd/traefik"
      prefix.install_metafiles
    end
  end

  test do
    require "socket"

    web_server = TCPServer.new(0)
    http_server = TCPServer.new(0)
    web_port = web_server.addr[1]
    http_port = http_server.addr[1]
    web_server.close
    http_server.close

    (testpath/"traefik.toml").write <<~EOS
      [web]
      address = ":#{web_port}"

      [entryPoints.http]
      address = ":#{http_port}"
    EOS

    begin
      pid = fork do
        exec bin/"traefik", "--configfile=#{testpath}/traefik.toml"
      end
      sleep 5
      cmd = "curl -sIm3 -XGET http://localhost:#{web_port}/dashboard/"
      assert_match /200 OK/m, shell_output(cmd)
    ensure
      Process.kill("HUP", pid)
    end
  end
end
