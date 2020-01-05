# frozen_string_literal: true

BIN = %w[_ t tap].freeze

desc 'Build'
task :build do
  BIN.each do |bin|
    sh "scedilla --program #{bin} --doc README.md cmd/#{bin}/main.sh bin/#{bin}"
  end
end

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
  rm_f BIN.map { |prg| "bin/#{prg}" }
end

task all: %i[build lint]

task default: :build
