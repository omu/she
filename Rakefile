#!/usr/bin/env ruby
# frozen_string_literal: true

# Compile shell files, that is, include (selected) code snippets and do substitutions via simple directives.
# Note that, this is not a full-fledged implementation (i.e. no nested inclusions).
#
# See src/she for an example.

module Fmt
  DEFAULT_FMT_OPTIONS = {
    space: "\t", indent: 0, prefix: nil, suffix: nil, trim: true
  }.freeze

  refine String do
    def fmt(**options) # rubocop:disable Metrics/AbcSize
      options = DEFAULT_FMT_OPTIONS.merge options

      out = dup
      out.gsub!(/^/m, options[:space] * options[:indent]) if options[:indent].positive?
      out.gsub!(/^/m, options[:prefix]) if options[:prefix]
      out.gsub!(/$/m, options[:suffix]) if options[:suffix]
      out.gsub!(/^\s+$/m, '') if options[:trim]
      out
    end
  end

  refine Array do
    def fmt(**options)
      map { |line| line.fmt(**options) }
    end

    def fmt!(**options)
      map! { |line| line.fmt(**options) }
    end
  end
end

class Source
  attr_reader :path, :blocks, :rawlines

  def initialize(path)
    @path   = path
    @blocks = Block.parse((@rawlines = File.readlines(path).map(&:chomp)).each)
  end

  class Block
    using Fmt

    attr_reader :lines, :doc, :label

    def initialize(lines)
      @lines = parse(lines)
    end

    def documented_lines
      [*doc, *lines]
    end

    def outlines(documented: true, **options)
      (documented ? documented_lines : lines).fmt(**options)
    end

    def undocumented?
      !doc || doc.empty?
    end

    protected

    def parse(lines)
      lines
    end

    class Fun < self
      PATTERN = /
        ^
        (?<fun>[^(]+)
        [(]
      /x.freeze

      attr_reader :fun, :pub, :label

      def convey_from_doc_block(doc_block)
        %i[doc label pub].each { |attribute| send("#{attribute}=", doc_block.send(attribute)) }
      end

      def private?
        fun.match?(/(_$|\b_)/)
      end

      protected

      attr_writer :doc, :fun, :pub, :label

      def parse(lines)
        if (m = lines.first.match(PATTERN))
          self.fun = m[:fun] if m
        end

        lines
      end
    end

    class Doc < self
      PATTERN = /
        ^
        (?<pre>
          [#]
          \s+
        )
        (?:
          (?<pub>[\w.:-]+)
          (
            :\s*
            |
            \s+[-]{1,}\s+
          )
        )?
        (?<label>.*)
      /x.freeze

      attr_reader :pub, :label

      def doc
        lines.join("\n").strip
      end

      def documented_lines
        doc
      end

      protected

      attr_writer :pub, :label

      def parse(lines)
        if (m = lines.first.match(PATTERN))
          self.pub   = m[:pub]
          self.label = m[:label]
        end

        pub ? [m[:pre] + label, *lines[1..-1]] : lines
      end
    end

    Other  = Class.new self
    Blank  = Class.new self

    class << self
      def parse(reader)
        blocks = []

        loop do
          blocks << case reader.peek
                    when /^#/     then Doc.new   read(reader, /^([^#]|$)/)
                    when /\{\s*$/ then Fun.new   read(reader, /\}\s*$/, inclusive: true) # TODO: one line functions
                    when /^\s*$/  then Blank.new read(reader, /\S/)
                    else               Other.new [reader.next]
                    end
        end

        normalize blocks
      end

      private

      def read(reader, end_pattern, inclusive: false)
        lines = [reader.next]

        loop do
          break if reader.peek.match? end_pattern

          lines << reader.next
        end
        lines << reader.next if inclusive

        lines
      end

      def normalize(blocks)
        result, it = [], blocks.each

        loop do
          next if (current = it.next).is_a? Blank

          if current.is_a?(Doc) && (trailing = it.peek).is_a?(Fun)
            trailing.convey_from_doc_block(current) # TODO: Other?
            next
          end

          result << current
        end

        result
      end
    end
  end
end

class Compiler
  using Fmt

  Error = Class.new StandardError

  attr_reader :inlines, :sources, :exports

  def initialize(inlines, substitutions: nil)
    @inlines       = inlines.map(&:chomp)
    @substitutions = substitutions || {}
    @sources       = {}
  end

  def compile
    first_pass = []
    inlines.each { |line| first_pass += process(line, :include) }

    self.exports = export

    second_pass = []
    first_pass.each { |line| second_pass += process(line, :substitute) }

    second_pass.join "\n"
  end

  def export
    symbols = []

    sources.values.map(&:blocks).each do |blocks|
      blocks.each do |block|
        next unless block.is_a?(Source::Block::Fun) && block.pub
        next if block.undocumented? || block.private?

        symbols << { pub: block.pub, fun: block.fun, label: block.label }
      end
    end

    symbols
  end

  private

  attr_reader :substitutions
  attr_writer :exports

  DIRECTIVE = {
    include:    /
                  ^
                    (?<lead>\s*)
                    \#:
                    (?<arg>.*)
                /x,

    substitute: %r{
                    ^
                    (?<lead>\s*)
                    \#/
                    (?<substitution>\w+)
                    /
                    (?<arg>.*)
                }x
  }.freeze

  def process(line, directive)
    return [line] unless (m = line.match(DIRECTIVE[directive]))

    send("do_#{directive}", m).fmt! prefix: m[:lead]
  end

  def do_include(match)
    return src(match[:arg]).rawlines unless (field = parse_include(match[:arg]))

    query_blocks_for(src(field[:path]).blocks, field[:key], by: field[:by]).tap do |result|
      raise Error, "No match for line: #{match}" if result.empty?
    end
  end

  def parse_include(arg)
    case (fields = arg.split ':').size
    when 1 then nil
    when 2 then { path: fields[0], by: fields[1], key: :label    }
    when 3 then { path: fields[0], by: fields[1], key: fields[2] }
    else        raise Error, "Malformed include directive: #{arg}"
    end
  end

  def do_substitute(match)
    unless (substituter = substitutions[substitution = match[:substitution]])
      warn "No substituter found for: #{substitution}"
      return [line]
    end

    [*substituter.call(self, match[:arg])]
  end

  def query_blocks_for(blocks, *strings, **args)
    result = []

    by = :label if !(by = args[:by]) || by.empty?

    strings.each do |string|
      founds = blocks.select do |block|
        next unless (attribute = block.send(by))

        attribute.casecmp(string.squeeze(' ')).zero?
      end
      founds.each { |found| result += found.outlines(**args) }
    end

    result
  end

  def src(path)
    unless sources.key?(path)
      raise Error, "File not found: #{path}" unless File.exist?(path)

      sources[path] = Source.new path
    end

    sources[path]
  end

  class << self
    def compile(*args, **options)
      new(*args, **options).compile
    end
  end
end

module Main
  using Fmt

  class << self
    private

    def public_name_to_command_name(pub)
      pub.split('.').join(' ')
    end

    def bash_array_lines(exports, variable, key)
      pairs = exports.map { |h| "['#{public_name_to_command_name(h[:pub])}']='#{h[key]}'" }

      ["declare -Ag #{variable}=(", *pairs.fmt(indent: 1), ')']
    end
  end

  SUBSTITUTIONS = {
    '_command' => proc { |compiler| bash_array_lines(compiler.exports, '_command', :fun)   },
    '_help'    => proc { |compiler| bash_array_lines(compiler.exports, '_help',    :label) }
  }.freeze

  def self.call(src, dst)
    File.write(dst, Compiler.compile(File.readlines(src), substitutions: SUBSTITUTIONS))
  rescue Compiler::Error => e
    abort 'E: ' + e.message
  end
end

BIN = %w[bin/underscore bin/_ bin/she bin/i].freeze

file 'bin/underscore' => ['src/underscore', *Dir['lib/*.sh'], __FILE__] do |task|
  src, dst = task.prerequisites.first, task.name

  mkdir_p File.dirname(dst)
  Main.(src, dst)
  chmod '+x', dst

  sh 'bash', '-n', dst
  sh 'shellcheck', dst
end

desc 'Generate programs'
task generate: 'bin/underscore' do |task|
  src = task.prerequisites.first

  BIN.each { |bin| ln(src, bin, force: true) unless File.exist?(bin) || src == bin }
end

desc 'Clean'
task :clean do
  rm_f BIN
end

task default: :generate
