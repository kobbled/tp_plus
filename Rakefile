file "lib/tp_plus/parser.rb" => ["generators/parser.y"] do |t|
  sh "racc -l -t -v -o lib/tp_plus/parser.rb generators/parser.y"
end

namespace :compile do
  task :parser do
    Rake::Task["lib/tp_plus/parser.rb"].invoke
  end
end

require 'rdoc/task'

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.main = "README.md"
  rdoc.rdoc_files.include("README.md", "examples.md")
  rdoc.rdoc_files.include("test/tp_plus/*.rb")
  rdoc.rdoc_files.include("lib/tp_plus/*.rb", "lib/tp_plus/nodes/*.rb")
  rdoc.rdoc_files.exclude("lib/tp_plus/parser.rb")
end

task compile: ["compile:parser"]

require 'rake/testtask'

Rake::TestTask.new do |t|
  # build the parser if necessary
  Rake::Task["lib/tp_plus/parser.rb"].invoke

  t.libs << "test"
  t.test_files = FileList['test/**/test_*.rb']
  t.verbose = true
end

task default: :test


desc "Run the TP+ benchmark"
task :benchmark do
  ruby "./performance/benchmark.rb"
end

desc "Run the TP+ profiler"
task :profile do
  ruby "./performance/profile.rb"
end
