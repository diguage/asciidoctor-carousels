begin
  require_relative 'lib/asciidoctor/carousels/version'
rescue LoadError
  require 'asciidoctor/carousels/version'
end

Gem::Specification.new do |s|
  s.name = 'asciidoctor-carousels'
  s.version = Asciidoctor::Carousels::VERSION
  s.summary = 'An Asciidoctor extension that adds a carousel block to the AsciiDoc syntax.'
  s.description = 'An Asciidoctor extension that adds a carousel block to the AsciiDoc syntax. The carousel is constructed from visual blocks, such as image macros and Asciidoctor Diagram blocks, enclosed in an example block marked with the carousel style.'
  s.authors = ['Asciidoctor Carousels contributors']
  s.email = 'noreply@asciidoctor.org'
  s.homepage = 'https://asciidoctor.org'
  s.license = 'MIT'
  # NOTE required ruby version is informational only; it's not enforced since it can't be overridden and can cause builds to break
  #s.required_ruby_version = '>= 2.3.0'
  s.metadata = {
    'bug_tracker_uri' => 'https://github.com/asciidoctor/asciidoctor-carousels/issues',
    'changelog_uri' => 'https://github.com/asciidoctor/asciidoctor-carousels/blob/main/CHANGELOG.adoc',
    'mailing_list_uri' => 'https://chat.asciidoctor.org',
    'source_code_uri' => 'https://github.com/asciidoctor/asciidoctor-carousels'
  }

  # NOTE the logic to build the list of files is designed to produce a usable package even when the git command is not available.
  # The directory listing is merged in so the gem can also be built from an uncommitted working tree.
  begin
    files = `git ls-files -z`.split ?\0
    files = files.empty? ? Dir['**/*'] : (files + Dir['**/*']).uniq
  rescue
    files = Dir['**/*']
  end
  s.files = files.grep %r/^(?:(?:data|lib)\/.+|LICENSE|(?:CHANGELOG|README|design)\.adoc|#{s.name}\.gemspec)$/
  s.executables = (files.grep %r/^bin\//).map {|f| File.basename f }
  s.require_paths = ['lib']

  s.add_runtime_dependency 'asciidoctor', ['>= 2.0.0', '< 3.0.0']

  s.add_development_dependency 'rake', '~> 13.0.0'
  s.add_development_dependency 'rspec', '~> 3.13.0'
end
