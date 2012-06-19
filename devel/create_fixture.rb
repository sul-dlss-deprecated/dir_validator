#! /usr/bin/env ruby

abort "Usage:\n\n  #{$PROGRAM_NAME} DIR FILE_LIST" unless ARGV.size == 2

working_dir, file_list = ARGV

files = IO.readlines(file_list).map { |line| line.chomp! }

Dir.chdir(working_dir) do
  files.each do |f|
    next if File.exists?(f)
    system('mkdir', '-p', f) if f.end_with?('/')
    system('touch', f)
  end
end
