# frozen_string_literal: true

# Compile shell files, i.e. include (selected) code snippets and do substitutions via simple directives.
# Note that, this is not a full-fledged implementation (i.e. no nested inclusions).
#
# See src/* for examples.

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

    attr_reader :lines, :doc, :desc

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

      attr_reader :fun, :desc

      def convey_from_doc_block(doc_block)
        %i[doc desc].each { |attribute| send("#{attribute}=", doc_block.send(attribute)) }
      end

      def private?
        fun.match?(/(^[._]|[._]$|\b_)/)
      end

      def cmd?
        fun.match?(':') && !fun.match?('_')
      end

      def cmd
        fun.split(':').reject(&:empty?).join(' ')
      end

      protected

      attr_writer :doc, :fun, :desc

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
        (?<desc>.*)
      /x.freeze

      attr_reader :desc

      def doc
        lines.join("\n").strip
      end

      def documented_lines
        doc
      end

      protected

      attr_writer :desc

      def parse(lines)
        if (m = lines.first.match(PATTERN))
          self.desc = m[:desc]
        end

        lines
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
                    when /\{\s*$/ then Fun.new   read(reader, /^\s*\}\s*$/, inclusive: true) # TODO: one line functions
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

class Library
  Error = Class.new StandardError

  def initialize(paths = nil)
    @sources = {}

    scan(paths) if paths
  end

  def src(path)
    unless sources.key?(path)
      raise Error, "File not found: #{path}" unless File.exist?(path)

      sources[path] = Source.new path
    end

    sources[path]
  end

  def export
    symbols = []

    sources.values.map(&:blocks).each do |blocks|
      blocks.each do |block|
        next unless block.is_a?(Source::Block::Fun) && block.cmd?

        symbols << { fun: block.fun, desc: block.desc, cmd: block.cmd }
      end
    end

    symbols
  end

  private

  attr_reader :sources

  def scan(paths)
    paths.each { |path| src(path) }
  end
end

class Compiler
  using Fmt

  Error = Class.new StandardError

  attr_reader :inlines, :library

  def initialize(inlines, substitutions: nil)
    @inlines       = inlines.map(&:chomp)
    @substitutions = substitutions || {}
    @library       = Library.new
  end

  def compile # rubocop:disable Metrics/MethodLength
    outlines = nil

    first_pass = []
    inlines.each do |line|
      outlines = process(line, :include, previous: outlines)
      first_pass.append(*outlines || line)
    end

    second_pass = []
    first_pass.each do |line|
      outlines = process(line, :substitute, previous: outlines)
      second_pass.append(*outlines || line)
    end

    second_pass.join "\n"
  end

  def export
    library.export
  end

  private

  attr_reader :substitutions

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

  def process(line, directive, previous: nil)
    return nil unless (m = line.match(DIRECTIVE[directive]))

    out = send("do_#{directive}", m).fmt(prefix: m[:lead])
    previous ? ['', *out] : out
  end

  def do_include(match) # rubocop:disable Metrics/AbcSize
    parsed = parse_include(match[:arg])
    src    = library.src parsed[:path]

    return src.rawlines if parsed[:funs].empty?

    result = query_blocks_for_funs src.blocks, *parsed[:funs]
    raise Error, "No match for line: #{match}" if result.empty?

    parsed[:calls].empty? ? result : [*result, parsed[:calls].join("\n")]
  end

  def parse_include(arg)
    path, remaining = arg.split(':', 2)

    raise Error, "Malformed include directive: #{arg}" unless path

    funs, calls = [], []

    (remaining ? remaining.split : []).each do |fun|
      next funs << fun unless fun.end_with? '+'

      fun.delete_suffix! '+'

      calls << fun
      funs << fun
    end

    { path: path, funs: funs, calls: calls }
  end

  def do_substitute(match)
    return [] if substitutions.empty?

    unless (substituter = substitutions[substitution = match[:substitution]])
      warn "No substituter found for: #{substitution}"
      return [line]
    end

    [*substituter.call(self, match[:arg])]
  end

  def query_blocks_for_funs(blocks, *funs, **args)
    result = []

    funs.each do |fun|
      founds = blocks.select do |block|
        next unless block.respond_to? :fun
        next unless (attribute = block.fun)

        attribute.casecmp(fun.squeeze(' ')).zero?
      end
      founds.each { |found| result += [*found.outlines(**args), "\n"] }
    end

    result
  end
end

module Main
  using Fmt

  class << self
    private

    def bash_array_lines(export, variable, lhs, rhs)
      pairs = export.sort_by { |h| h[lhs] }.map { |h| "['#{h[lhs]}']='#{h[rhs]}'" }

      ["declare -Ag #{variable}=(", *pairs.fmt(indent: 1), ')']
    end

    # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
    def collect_helps(commands)
      result = {}

      max_command_lengths = []
      max_desc_lengths    = []

      commands.each do |cmd, export|
        max_command_lengths << export.map { |h| h[:cmd].length  }.max
        max_desc_lengths    << export.map { |h| h[:desc].length }.max

        result[cmd] = export.sort_by { |h| h[:cmd] }.map do |h|
          { cmd: h[:cmd], desc: h[:desc] }
        end
      end

      [{ cmd: max_command_lengths.max, desc: max_desc_lengths.max }, result]
    end

    def markdown_table_lines(inlines:, section:, helps:, lengths:)
      stamp_begin = "<!-- #{section} begin -->"
      stamp_end   = "<!-- #{section} end -->"

      starting    = inlines.find_index stamp_begin
      ending      = inlines.find_index stamp_end

      return inlines if starting.nil? || ending.nil?

      lines = []

      cmd_length, desc_length = lengths[:cmd], lengths[:desc]

      lines << format("| %-#{cmd_length}s | %-#{desc_length}s |",
                      'Command', 'Description')
      lines << format("| %-#{cmd_length}s | %-#{desc_length}s |",
                      '-' * cmd_length, '-' * desc_length)

      helps[section].each do |h|
        desc, cmd = h[:desc], h[:cmd]

        lines << format("| %-#{cmd_length}s | %-#{desc_length}s |", cmd, desc)
      end

      [
        *inlines[0..starting],
        *lines,
        *inlines[ending..-1]
      ]
    end
    # rubocop:enable Metrics/MethodLength,Metrics/AbcSize
  end

  SUBSTITUTIONS = {
    'help'    => proc { |compiler| bash_array_lines(compiler.export, '_help',    :fun, :desc) },
    'command' => proc { |compiler| bash_array_lines(compiler.export, '_command', :cmd, :fun)  }
  }.freeze

  def self.call(src, dst)
    Compiler.new(File.readlines(src), substitutions: SUBSTITUTIONS).tap do |compiler|
      File.write dst, compiler.compile
    end
  rescue Compiler::Error => e
    abort 'E: ' + e.message
  end

  def self.doc(dst, commands)
    inlines = File.readlines(dst).map(&:chomp)

    lengths, helps = collect_helps(commands)

    commands.keys.each do |cmd|
      inlines = markdown_table_lines(inlines: inlines, section: cmd,
                                     helps: helps, lengths: lengths)
    end

    inlines.join("\n").chomp + "\n"
  end
end

PRG = %w[_ t tap].freeze
BIN = PRG.map { |prg| "bin/#{prg}" }.freeze
DEP = [*Dir['cmd/*', 'lib/*', 'src/*'], __FILE__].freeze

commands = {}

PRG.each do |prg|
  src, dst = "src/#{prg}", "bin/#{prg}"

  file "bin/#{prg}" => DEP do
    mkdir_p File.dirname(dst)
    commands[prg] = Main.(src, dst).export
    chmod '+x', dst
  end
end

doc = 'README.md'
file doc => DEP do
  File.write doc, Main.doc(doc, commands)
end

desc 'Build'
task build: [*BIN, 'README.md']

desc 'Lint'
task :lint do
  if ENV['lang'].nil? || ENV['lang'] == 'sh'
    sh %(shellcheck $(find -type f -and -not -path './.git/*' | xargs file --mime-type | grep text/x-shellscript$ | cut -f1 -d:)) # rubocop:disable Metrics/LineLength
  end
  sh 'rubocop'           if ENV['lang'].nil? || ENV['lang'] == 'rb'
  sh 'markdownlint *.md' if ENV['lang'].nil? || ENV['lang'] == 'md'
end

desc 'Clean'
task :clean do
  rm_f BIN
end

task all: %i[build lint]

task default: :build
