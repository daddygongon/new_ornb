# -*- coding: utf-8 -*-
require "open3"
require "csv"
require 'colorize'

class NewCSV
  attr_reader :org, :csv, :status
  def initialize(org)
    @org = org
    @csv = File.basename(@org,'.org')+'_cl.csv'

    conts = mk_conts(@org)
    unless File.exist?(@csv)
      write_csv(@csv, conts)
    else
      puts "file exist, you can force to make new csv, but ...".red
      @status = false
    end
  end

  def mk_conts(org)
    conts = []
    File.open(org,"r") do |file|
      file.each do |line|
        if path = line.match(/\[\[(.+).pdf(.*)\]\]/)
          conts << [path[1]+'.pdf',false]
        end
      end
    end
    conts
  end

  def write_csv(csv, conts)
    CSV.open(csv,'w') do |csv|
      conts.each{|cont| csv << cont}
    end
  end
end

file = ARGV[0] || 'README.org'
list_csv = NewCSV.new(file)
p list_csv.status
exit
#p revised_array
# readme_cl.csv -> array[]

out, err, status= Open3.capture3("diff #{list_csv.tmp_csv} #{list_csv.csv}")
if out == ''
  puts "no revision on csv list".green
  exit
end
revised_array = []
revised = false
out.split("\n").each do |line|
  revised = true if line.chomp =='---'
  if revised
    p line
    revised_array << line[2..-1].split(',')
    p revised_array
  end
end


def rev_line(line, revised_array)
  revised_array[1..-1].each do |cont|
    base_name = File.basename(cont[0])
    tmp = base_name+":"+cont[1]
    line.gsub!(cont[0],tmp)
  end
  return line
end

conts = ""
File.readlines(list_csv.org).each do |line|
  revised = rev_line(line, revised_array)
  conts << revised
end

File.open('tmp.org','w'){|f| f.print conts}