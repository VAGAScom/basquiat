# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :bundler do
  watch('Gemfile')
  watch('basquiat.gemspec')
end

guard :rspec, { all_on_start: true, keep_failed: true, all_after_pass: true } do
  watch(%r{^spec/.+_spec.rb$})
  watch(%r{^lib/(.+)\.rb$}) { |matchdata| "spec/lib/#{matchdata[1]}_spec.rb" }
  watch('spec/spec_helper.rb') { 'spec' }
  watch(%r{spec/support/.+\.rb}) { 'spec' }
end
