task :push do
  tag = ENV["RUBY_VERSION"]
  node = ENV["NODE_VERSION"]
  abort "please set RUBY_VERSION" unless tag
  abort "please set NODE_VERSION" unless node
  base = "mcr.microsoft.com/devcontainers/ruby:1-#{tag}-bullseye"
  sh "docker build -t ghcr.io/nerdgeschoss/nerdgeschoss/development-environment:#{tag}-#{node} --build-arg BASE_IMAGE=#{base} --build-arg NODE_VERSION=#{node} ."
  sh "docker push ghcr.io/nerdgeschoss/nerdgeschoss/development-environment:#{tag}-#{node}"
end
