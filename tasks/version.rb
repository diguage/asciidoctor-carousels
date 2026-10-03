# frozen_string_literal: true

require 'open3'
require 'time'

release_version = ENV['RELEASE_VERSION']
release_gem_version = ENV['RELEASE_GEM_VERSION']
release_date = Time.now.strftime '%Y-%m-%d'
release_user = ENV['RELEASE_USER']

version_file = 'lib/asciidoctor/carousels/version.rb'
changelog_file = 'CHANGELOG.adoc'

def git_output(*args)
  out, status = Open3.capture2(*args)
  status.success? ? out : ''
end

def previous_tag
  tag = git_output('git', 'describe', '--tags', '--abbrev=0', 'HEAD').strip
  tag.empty? ? nil : tag
end

def changelog_entries(previous)
  range = previous ? "#{previous}..HEAD" : 'HEAD'
  subjects = git_output('git', 'log', '--no-merges', '--pretty=format:%s', range).lines.map(&:strip)
  subjects = subjects.reject(&:empty?)
  subjects = subjects.reject { |subject| subject.match?(/\A(?:release |update changelog|fix changelog)/i) }
  subjects.map { |subject| "* #{subject}" }.join("\n")
end

version_contents = File.readlines(version_file, mode: 'r:UTF-8').map do |line|
  line.include?('VERSION =') ? line.sub(%r/'[^']+'/, %('#{release_gem_version}')) : line
end

changelog_contents = File.readlines changelog_file, mode: 'r:UTF-8'
first_release = changelog_contents.index {|line| line.start_with? '== ' }
entries = changelog_entries previous_tag
release_body = entries.empty? ? '_No changes since previous release._' : entries
release_heading = %(== #{release_version} (#{release_date}) - @#{release_user}\n\n#{release_body}\n\n)
changelog_contents.insert first_release || changelog_contents.length, release_heading

File.write version_file, version_contents.join, mode: 'w:UTF-8'
File.write changelog_file, changelog_contents.join, mode: 'w:UTF-8'
