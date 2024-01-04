task :push do
  sh "docker build -t development-environment ."
  sh "docker tag development-environment:latest ghcr.io/nerdgeschoss/nerdgeschoss/development-environment:latest"
  sh "docker push ghcr.io/nerdgeschoss/nerdgeschoss/development-environment:latest"
end
