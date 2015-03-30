guard :bundler do
  watch('Gemfile')
  watch('basquiat.gemspec')
end

guard :rspec, { all_on_start: true, keep: true, all_after_pass: true, run_all: { cmd: 'rspec -f progress'} } do
  watch(%r{^spec/.+_spec.rb$})
  watch(%r{^spec/lib/.+_spec.rb$})
  watch(%r{^lib/basquiat/(.+)\.rb$}) { |matchdata| "spec/lib/#{matchdata[1]}_spec.rb" }
  watch('spec/spec_helper.rb')       { 'spec' }
  watch(%r{spec/support/.+\.rb})     { 'spec' }
end

guard :rubocop, { cli: '-fs -c./.rubocop.yml'} do
  #watch(%r{.+\.rb$})
  #watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
end
