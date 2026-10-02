# frozen_string_literal: true

require 'time'

release_version = ENV['RELEASE_VERSION']
release_gem_version = ENV['RELEASE_GEM_VERSION']
release_date = Time.now.strftime '%Y-%m-%d'
release_user = ENV['RELEASE_USER']

version_file = 'lib/asciidoctor/carousels/version.rb'
changelog_file = 'CHANGELOG.adoc'

version_contents = File.readlines(version_file, mode: 'r:UTF-8').map do |line|
  line.include?('VERSION =') ? line.sub(%r/'[^']+'/, %('#{release_gem_version}')) : line
end

changelog_contents = File.readlines changelog_file, mode: 'r:UTF-8'
first_release = changelog_contents.index {|line| line.start_with? '== ' }
release_heading = %(== #{release_version} (#{release_date}) - @#{release_user}\n\n_No changes since previous release._\n\n)
changelog_contents.insert first_release || changelog_contents.length, release_heading

File.write version_file, version_contents.join, mode: 'w:UTF-8'
File.write changelog_file, changelog_contents.join, mode: 'w:UTF-8'
