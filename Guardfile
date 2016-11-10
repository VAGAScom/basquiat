# frozen_string_literal: true
guard :bundler do
  watch('Gemfile')
  watch('basquiat.gemspec')
end

group :bdd, halt_on_fail: true do
  guard :rspec, cmd:    'bundle exec rspec', keep: true, all_on_start: true,
        all_after_pass: true, run_all: { cmd: 'rspec -f progress' } do
    watch(%r{^spec/.+_spec.rb$})
    watch(%r{^spec/lib/.+_spec.rb$})
    watch(%r{^lib/basquiat/(.+)\.rb$}) { |matchdata| "spec/lib/#{matchdata[1]}_spec.rb" }
    watch('spec/spec_helper.rb') { 'spec' }
    watch(%r{spec/support/.+\.rb}) { 'spec' }
  end

  guard :rubocop, cmd: 'rubocop', cli: '-D -E -fs -c./.rubocop.yml' do
    watch(%r{.+\.rb$})
    watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
  end
end

group :docs do
  guard 'yard', cli: '-r' do
    watch(%r{lib/.+\.rb}) { 'lib' }
  end
end
