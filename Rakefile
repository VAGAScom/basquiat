# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new(:spec)

task default: :spec

desc 'Loads IRB with the gem already required'
task :console do
  system 'irb -I./lib -rbasquiat'
end

namespace :docs do
  desc 'Generates the documentation'
  task :generate do
    sh 'yard doc'
  end

  desc 'Starts the auto-reloading documentation server'
  task :server do
    sh 'yard server -r'
  end
end
