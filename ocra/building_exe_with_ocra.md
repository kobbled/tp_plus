1. install ocra `gem install ocra`
2. Copy this repo to another location as you will have to delete and modify files
3. Replace the contents in `Gemfile` with `Genfile_ocra`
```
source "https://rubygems.org"

gem'benchmark-ips', '~> 2.1'
gem'rexical', '~> 1.0'
gem'racc', '~> 1.4.15'
gem'test-unit', '~> 3.0'
gem'rake', '~> 12.3.3'
gem'ruby-prof', '~> 0.15'
gem'rdoc'
gem'ruby_deep_clone'
gem'matrix', '~> 0.4.2'
gem'ppr'
```
4. Delete the following directories and files
  * .vscode
  * .git
  * .gitignore
  * .travis.yml
  * *.code-workspace
  * bin/*.bat
  * examples
5. Add .rb extension to `bin/tpp` -> `bin/tpp.rb`
6. Download `fiber.so` from https://github.com/larsch/ocra/files/8249797/fiber.zip. Copy `fiber.so` into `C:\Ruby<version>-x64\lib\ruby\3.1.0\x64-mingw-ucrt` where \<version\> is the current ruby version number.
7. Run ocra command in root directory to build
```
ocra bin/tpp.rb lib\tp_plus\karel\templates\karelenv.erb lib\tp_plus\karel\templates\rossumenv.erb lib\tp_plus\motion\templates\ls.erb --gemfile Gemfile --add-all-core --dll ruby_builtin_dlls/libgmp-10.dll --dll ruby_builtin_dlls/libffi-7.dll --dll ruby_builtin_dlls/libssp-0.dll --dll ruby_builtin_dlls/libssl-1_1-x64.dll --dll ruby_builtin_dlls/libcrypto-1_1-x64.dll --dll ruby_builtin_dlls/libgcc_s_seh-1.dll --dll ruby_builtin_dlls/libwinpthread-1.dll
```

