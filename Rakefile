#!/usr/bin/env ruby
# frozen_string_literal: true

# Compile shell files, that is, include (selected) code snippets and do substitutions via simple directives.
# Note that, this is not a full-fledged implementation (i.e. no nested inclusions).
#
# See src/* for examples.

# rubocop:disable Style/TrailingCommaInHashLiteral,Layout/AlignHash
COMMANDS = {
  '_' => {
    '_.available'   => 'available',
    'bin.install'   => 'bin install',
    'bin.run'       => 'bin run',
    'bin.use'       => 'bin use',
    'deb.add'       => 'deb add',
    'deb.install'   => 'deb install',
    'deb.installed' => 'deb installed',
    'deb.missings'  => 'deb missings',
    'deb.uninstall' => 'deb uninstall',
    'deb.update'    => 'deb update',
    'deb.using'     => 'deb using',
    '_.expired'     => 'expired',
    'file.install'  => 'file install',
    'filetype.any'  => 'filetype any',
    'filetype.is'   => 'filetype is',
    'filetype.mime' => 'filetype mime',
    'http.any'      => 'http any',
    'http.get'      => 'http get',
    'http.is'       => 'http is',
    '_.must'        => 'must',
    'os.any'        => 'os any',
    'os.codename'   => 'os codename',
    'os.dist'       => 'os dist',
    'os.is'         => 'os is',
    '_.run'         => 'run',
    'self.install'  => 'self install',
    'self.name'     => 'self name',
    'self.path'     => 'self path',
    'self.src'      => 'self src',
    'self.version'  => 'self version',
    '_.should'      => 'should',
    'src.enter'     => 'enter',
    'src.install'   => 'src install',
    'src.use'       => 'src use',
    'temp.inside'   => 'temp inside',
    'text.fix'      => 'text fix',
    'text.unfix'    => 'text unfix',
    'ui.bug'        => 'bug',
    'ui.calling'    => 'ui calling',
    'ui.cry'        => 'cry',
    'ui.die'        => 'die',
    'ui.getting'    => 'ui getting',
    'ui.hmm'        => 'ui info',
    'ui.notok'      => 'ui notok',
    'ui.ok'         => 'ui ok',
    'ui.running'    => 'ui running',
    'ui.say'        => 'say',
    'url.any'       => 'url any',
    'url.is'        => 'url is',
    'virt.any'      => 'virt any',
    'virt.is'       => 'virt is',
    'virt.which'    => 'virt which',
    'zip.unpack'    => 'unzip',
  },
  't' => {
    'tap.err'       => 'tap err',
    'tap.failure'   => 'tap failure',
    'tap.plan'      => 'tap plan',
    'tap.skip'      => 'tap skip',
    'tap.success'   => 'tap success',
    'tap.todo'      => 'tap todo',
    'tap.version'   => 'tap version',
    'test.is'       => 'is',
    'test.isnt'     => 'isnt',
    'test.notok'    => 'notok',
    'test.ok'       => 'ok',
  }
}.freeze
# rubocop:enable Style/TrailingCommaInHashLiteral,Layout/AlignHash

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

      attr_reader :fun, :label

      def convey_from_doc_block(doc_block)
        %i[doc label].each { |attribute| send("#{attribute}=", doc_block.send(attribute)) }
      end

      def private?
        fun.match?(/(^[._]|[._]$|\b_)/)
      end

      protected

      attr_writer :doc, :fun, :label

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
        (?<label>.*)
      /x.freeze

      attr_reader :label

      def doc
        lines.join("\n").strip
      end

      def documented_lines
        doc
      end

      protected

      attr_writer :label

      def parse(lines)
        if (m = lines.first.match(PATTERN))
          self.label = m[:label]
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

class Compiler # rubocop:disable Metrics/ClassLength
  using Fmt

  Error = Class.new StandardError

  attr_reader :inlines, :sources, :exports

  def initialize(inlines, substitutions: nil, commands: nil)
    @inlines       = inlines.map(&:chomp)
    @substitutions = substitutions || {}
    @commands      = commands      || {}
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

  def export # rubocop:disable Metrtics/AbcSize
    symbols = []

    sources.values.map(&:blocks).each do |blocks|
      blocks.each do |block|
        next unless block.is_a?(Source::Block::Fun)
        next unless commands.key? block.fun

        symbols << { fun: block.fun, label: block.label, cmd: commands[block.fun] }
      end
    end

    symbols
  end

  private

  attr_reader :substitutions, :commands
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

    [*send("do_#{directive}", m).fmt(prefix: m[:lead]), '']
  end

  def do_include(match) # rubocop:disable Metrics/AbcSize
    parsed = parse_include(match[:arg])

    return src(parsed[:path]).rawlines if parsed[:funs].empty?

    result = query_blocks_for_funs(src(parsed[:path]).blocks, *parsed[:funs])
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

    def export(*args, **options)
      compiler = new(*args, **options)
      compiler.compile
      compiler.export
    end
  end
end

module Main
  using Fmt

  class << self
    private

    def bash_array_lines(exports, variable, lhs, rhs)
      pairs = exports.sort_by { |h| h[lhs] }.map { |h| "['#{h[lhs]}']='#{h[rhs]}'" }

      ["declare -Ag #{variable}=(", *pairs.fmt(indent: 1), ')']
    end

    def markdown_table_lines(inlines:, export:, name:) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
      stamp_begin = "<!-- #{name} begin -->"
      stamp_end   = "<!-- #{name} end -->"

      starting = inlines.find_index stamp_begin
      ending   = inlines.find_index stamp_end

      return inlines if starting.nil? || ending.nil?

      max_command_lenth = export.map { |h| h[:cmd].length   }.max
      max_label_lenth   = export.map { |h| h[:label].length }.max

      lines = []

      lines << format("| %-#{max_command_lenth}s | %-#{max_label_lenth}s |",
                      'Command', 'Description')
      lines << format("| %-#{max_command_lenth}s | %-#{max_label_lenth}s |",
                      '-' * max_command_lenth, '-' * max_label_lenth)

      export.sort_by { |h| h[:cmd] }.each do |h|
        label, cmd = h[:label], h[:cmd]

        lines << format("| %-#{max_command_lenth}s | %-#{max_label_lenth}s |",
                        cmd, label)
      end

      [
        *inlines[0..starting],
        *lines,
        *inlines[ending..-1]
      ]
    end
  end

  SUBSTITUTIONS = {
    'help'    => proc { |compiler| bash_array_lines(compiler.exports, '_help',    :fun, :label) },
    'command' => proc { |compiler| bash_array_lines(compiler.exports, '_command', :cmd, :fun)   }
  }.freeze

  def self.call(src, dst, commands:)
    File.write(dst, Compiler.compile(File.readlines(src), substitutions: SUBSTITUTIONS, commands: commands))
  rescue Compiler::Error => e
    abort 'E: ' + e.message
  end

  def self.export(src, **options)
    Compiler.export(File.readlines(src), **options)
  rescue Compiler::Error => e
    abort 'E: ' + e.message
  end

  require 'awesome_print'

  def self.doc(sources, dst)
    inlines = File.readlines(dst).map(&:chomp)

    sources.each do |src|
      name    = File.basename(src)
      export  = Main.export src, commands: COMMANDS[name]

      inlines = markdown_table_lines(inlines: inlines, export: export, name: name)
    end

    inlines.join("\n").chomp + "\n"
  end
end

PRG = %w[_ t].freeze

PRG.each do |prg|
  file "bin/#{prg}" => ["src/#{prg}", "src/#{prg}.sh", 'src/common.sh', *Dir['lib/*.sh'], __FILE__] do |task|
    src, dst = task.prerequisites.first, task.name

    mkdir_p File.dirname(dst)
    Main.(src, dst, commands: COMMANDS[prg])
    chmod '+x', dst

    sh 'bash', '-n', dst
    sh 'shellcheck', dst
  end

  desc "Generate #{prg}"
  task prg.to_sym => "bin/#{prg}"
end

desc 'Generate programs'
task generate: PRG

desc 'Update documentation'
task doc: [*PRG.map { |prg| "bin/#{prg}" }, __FILE__] do
  dst = 'README.md'
  File.write dst, Main.doc(PRG.map { |prg| "src/#{prg}" }, dst)
end

desc 'Clean'
task :clean do
  rm_f(PRG.map { |prg| "bin/#{prg}" })
end

task default: :generate
