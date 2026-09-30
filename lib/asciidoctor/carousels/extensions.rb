# frozen_string_literal: true

unless RUBY_ENGINE == 'opal'
  require_relative 'block'
  require_relative 'docinfo'
end

module Asciidoctor
  module Carousels
    module Extensions
      const_set :Block, Block
      const_set :Docinfo, Docinfo

      module_function

      # Returns a Proc that registers the carousel block processor and the
      # supporting docinfo processors. The Proc is evaluated by Asciidoctor
      # when this extension group is enabled.
      def group
        proc do
          block Block, :carousel
          next if (doc = @document).embedded? || !(doc.attr? 'filetype', 'html')
          unless (doc.attribute_locked? 'carousel-stylesheet') ||
              ((doc.options[:attributes] || {}).transform_keys {|it| it.delete '@!' }.key? 'carousel-stylesheet')
            doc.set_attr 'carousel-stylesheet'
          end
          docinfo_processor Docinfo::Style
          docinfo_processor Docinfo::Behavior
          nil
        end
      end

      def key
        :carousel
      end

      def register registry = nil
        (registry || ::Asciidoctor::Extensions).groups[key] ||= group
      end

      def unregister registry = nil
        (registry || ::Asciidoctor::Extensions).groups.delete key
        nil
      end
    end
  end
end
