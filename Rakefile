task :push do
  tag = ENV["RUBY_VERSION"]
  abort "please set RUBY_VERSION" unless tag
  base = "mcr.microsoft.com/devcontainers/ruby:1-#{tag}-bullseye"
  sh "docker build -t ghcr.io/nerdgeschoss/nerdgeschoss/development-environment:#{tag} --build-arg BASE_IMAGE=#{base} ."
  sh "docker push ghcr.io/nerdgeschoss/nerdgeschoss/development-environment:#{tag}"
end
