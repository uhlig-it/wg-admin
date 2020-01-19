# frozen_string_literal: true

guard :bundler do
  require 'guard/bundler'
  require 'guard/bundler/verify'
  helper = Guard::Bundler::Verify.new
  files = ['Gemfile']
  files += Dir['*.gemspec'] if files.any? { |f| helper.uses_gemspec?(f) }
  files.each { |file| watch(helper.real_path(file)) }
end

guard :rspec, cmd: 'bundle exec rspec' do
  watch('spec/spec_helper.rb') { 'spec' }
  watch(%r{^spec/unit/.+_spec\.rb$})
  watch(%r{^spec/system/.+_spec\.rb$})
  watch(%r{^lib/(?<module>.*/)*(?<file>.+)\.rb$}) do |m|
    "spec/unit/#{m[:module]}#{m[:file]}_spec.rb"
  end
  watch(%r{^lib/(?<module>.*/)*(?<file>.+)\.rb$}) do |m|
    "spec/system/#{m[:module]}#{m[:file]}_spec.rb"
  end
  watch('lib/wireguard/admin/cli.rb') { 'spec/system' }
end
