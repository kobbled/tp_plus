namespace :compile do
  task :parser do
    sh "racc -l -t -o lib/tp_plus/parser.rb generators/parser.y"
  end

  task :scanner do
    sh "rex generators/scanner.rex -o lib/tp_plus/scanner.rb --stub"
  end
end

task compile: ["compile:parser","compile:scanner"]

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/test_*.rb']
  t.verbose = true
end

task default: :test
