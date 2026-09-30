# frozen_string_literal: true

$:.unshift File.expand_path('../lib', __dir__)

require 'asciidoctor'
require 'asciidoctor/carousels/version'
require 'asciidoctor/carousels/extensions'
require 'shellwords'
require 'tmpdir'

RSpec.configure do
  def ruby
    Shellwords.escape File.join RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name']
  end

  def with_memory_logger level = nil
    old_logger, logger = Asciidoctor::LoggerManager.logger, Asciidoctor::MemoryLogger.new
    logger.level = level if level
    Asciidoctor::LoggerManager.logger = logger
    yield logger
  ensure
    Asciidoctor::LoggerManager.logger = old_logger
  end
end
