# frozen_string_literal: true

describe Asciidoctor::Carousels do
  let :basic_carousel do
    <<~'END'
    [carousel]
    ====
    .First
    image::a.jpg[First,600,400]

    .Second
    image::b.jpg[Second,600,400]
    ====
    END
  end

  before { described_class::Extensions.register }

  after { described_class::Extensions.unregister }

  context 'require' do
    it 'should be able to require asciidoctor/carousels from a Ruby process' do
      script_file = File.join Dir.tmpdir, 'carousels-require.rb'
      begin
        File.write script_file, <<~'END'
        require 'asciidoctor'
        require 'asciidoctor/carousels'
        puts Asciidoctor::Extensions.groups.keys[0].to_s
        END
        lib_path = File.expand_path '../lib', __dir__
        ruby_command = %(#{ruby} -I#{Shellwords.escape lib_path} #{Shellwords.escape script_file})
        output = %x(#{ruby_command}).lines.map(&:chomp)
        (expect output).to eql ['carousel']
      ensure
        File.unlink script_file
      end
    end

    it 'should be able to require asciidoctor-carousels from a Ruby process' do
      script_file = File.join Dir.tmpdir, 'carousels-require.rb'
      begin
        File.write script_file, <<~'END'
        require 'asciidoctor'
        require 'asciidoctor-carousels'
        puts Asciidoctor::Extensions.groups.keys[0].to_s
        END
        lib_path = File.expand_path '../lib', __dir__
        ruby_command = %(#{ruby} -I#{Shellwords.escape lib_path} #{Shellwords.escape script_file})
        output = %x(#{ruby_command}).lines.map(&:chomp)
        (expect output).to eql ['carousel']
      ensure
        File.unlink script_file
      end
    end
  end

  context 'VERSION' do
    it 'should define a SemVer-compatible version constant' do
      (expect described_class::VERSION).to match %r/^\d+\.\d+\.\d+(\.[a-z]\S*)?$/
    end
  end

  context 'block' do
    it 'should leave an empty example block unprocessed' do
      input = <<~'END'
      [carousel]
      ====
      ====
      END

      actual = Asciidoctor.convert input
      (expect actual).to include 'class="exampleblock"'
      (expect actual).not_to include 'class="openblock carousel'
    end

    it 'should leave non-visual content unprocessed' do
      input = <<~'END'
      [carousel]
      ====
      Not an image.
      ====
      END

      actual = Asciidoctor.convert input
      (expect actual).to include '<p>Not an image.</p>'
      (expect actual).not_to include 'class="openblock carousel'
    end

    it 'should convert image blocks into a carousel' do
      actual = Asciidoctor.convert basic_carousel
      (expect actual).to include 'class="openblock carousel is-loading"'
      (expect actual).to include 'class="carousel-slide is-active"'
      (expect actual).to include 'class="imageblock"'
      (expect actual).to include 'class="carousel-slide-caption"'
      (expect actual).to include 'class="carousel-control carousel-control-prev"'
      (expect actual).to include 'class="carousel-indicator'
    end

    it 'should preserve id, role, and title on the carousel block' do
      input = <<~END
      .Brand tour
      [carousel#tour.hero]
      ====
      image::a.jpg[First]
      ====
      END

      actual = Asciidoctor.convert input
      (expect actual).to include 'id="tour"'
      (expect actual).to include 'class="openblock carousel hero is-loading"'
      (expect actual).to include '<div class="title">Brand tour</div>'
    end

    it 'should promote a paragraph containing a single inline image to a slide' do
      input = <<~'END'
      [carousel]
      ====
      .First
      image:a.jpg[First]
      ====
      END

      actual = Asciidoctor.convert input
      (expect actual).to include 'class="openblock carousel is-loading"'
      (expect actual).to include 'class="paragraph"'
      (expect actual).to include '<img src="a.jpg"'
      (expect actual).to include 'class="carousel-slide-caption"'
    end

    it 'should leave a carousel unprocessed for a non-HTML backend' do
      actual = Asciidoctor.convert basic_carousel, backend: 'docbook'
      (expect actual).to include '<informalexample>'
      (expect actual).not_to include 'class="openblock carousel'
    end

    it 'should not register docinfo processors for an embedded document' do
      (expect (Asciidoctor.load basic_carousel).extensions.docinfo_processors?).to be false
    end

    it 'should not register docinfo processors for non-HTML output' do
      doc = Asciidoctor.load basic_carousel, backend: 'docbook', standalone: true
      (expect doc.extensions.docinfo_processors?).to be false
    end

    it 'should register docinfo processors for standalone HTML output' do
      (expect (Asciidoctor.load basic_carousel, standalone: true).extensions.docinfo_processors?).to be true
    end
  end
end
