require "json"
require "dotenv/tasks"

task :push do
  tag = ENV["RUBY_VERSION"]
  node = ENV["NODE_VERSION"]
  abort "please set RUBY_VERSION" unless tag
  abort "please set NODE_VERSION" unless node
  base = "mcr.microsoft.com/devcontainers/ruby:1-#{tag}-bullseye"
  sh "docker build -t ghcr.io/nerdgeschoss/nerdgeschoss/development-environment:#{tag}-#{node} --build-arg BASE_IMAGE=#{base} --build-arg NODE_VERSION=#{node} ."
  sh "docker push ghcr.io/nerdgeschoss/nerdgeschoss/development-environment:#{tag}-#{node}"
end

Label = Struct.new(:id, :name, :color, :description, :alternative_names)

task update_labels: :dotenv do
  repos = ENV["REPOS"]&.split(",")
  puts "checking repos: #{repos}"
  next unless repos

  labels = [
    Label.new(name: "backend", color: "34495e", description: "Requires a backend developer.", alternative_names: []),
    Label.new(name: "blocked", color: "e74c3c", description: "This issue cannot be worked on currently due to an external dependency.", alternative_names: []),
    Label.new(name: "design", color: "3498db", description: "Requires a designer.", alternative_names: []),
    Label.new(name: "documentation", color: "c5def5", description: "This issue is about documentation on how the project works.", alternative_names: []),
    Label.new(name: "frontend", color: "1abc9c", description: "Requires a frontend developer.", alternative_names: []),
    Label.new(name: "needs assistance", color: "fbca04", description: "Assigned person on the issue needs help from another team member.", alternative_names: []),
    Label.new(name: "unplanned", color: "f39c12", description: "This task was not planned in a regular sprint and therefore is billed at a higher rate.", alternative_names: []),
    Label.new(name: "exploration", color: "eaf296", description: "This task is about exploring future features.", alternative_names: []),
    Label.new(name: "support", color: "8e44ad", description: "This task tracks supporting the customer in using the software.", alternative_names: []),
  ]
  repos.each do |repo|
    existing = JSON.parse(`gh api repos/#{repo}/labels`).map { Label.new(**_1.slice("id", "name", "color", "description")) }

    create = []
    delete = []
    update = []

    existing.each do |label|
      new_label = labels.find { _1.name == label.name }
      if new_label
        update << new_label if new_label.color != label.color || new_label.description != label.description
      else
        delete << label
      end
    end
    create = labels.select { !existing.map(&:name).include?(_1.name) }
    next unless create.any? || delete.any? || update.any?

    puts "Repo: #{repo}"
    puts "Create: #{create.map(&:name).join(", ")}" if create.any?
    puts "Delete: #{delete.map(&:name).join(", ")}" if delete.any?
    puts "Update: #{update.map(&:name).join(", ")}" if update.any?

    puts "Continue? [y/n]"
    next unless STDIN.gets.chomp == "y"

    create.each do |label|
      sh "gh label create \"#{label.name}\" --color=#{label.color} --description=\"#{label.description}\" --repo=#{repo}"
    end
    update.each do |label|
      sh "gh label edit \"#{label.name}\" --color=#{label.color} --description=\"#{label.description}\" --repo=#{repo}"
    end
    delete.each do |label|
      sh "gh label delete \"#{label.name}\" --repo=#{repo} --yes"
    end
  end
end
