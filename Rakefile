require 'foodcritic'
require 'kitchen'

desc 'Run Chef style checks'
FoodCritic::Rake::LintTask.new(:foodcritic) do |t|
  t.options = {
      fail_tags: ['any'],
      tags: []
  }
end

# Integration tests. Kitchen.ci
namespace :integration do
  desc 'Run Test Kitchen with Vagrant'
  task :vagrant do
    Kitchen.logger = Kitchen.default_file_logger
    Kitchen::Config.new.instances.each do |instance|
      instance.test(:always)
    end
  end
end

# Default
task default: ['foodcritic', 'integration:vagrant']