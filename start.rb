#!/usr/bin/ruby

##==================  FIle Extension Need to Install gem pristine byebug --version 9.0.6 and gem pristine debug_inspector --version 0.0.2 ============
##=================  Required Packegs gem install highline, gem install cli-console  ======================
require 'active_support'
require 'active_support/core_ext'
require 'highline'
require 'cli-console'

class Start
  private
  extend CLI::Task
  public
  usage 'Usage: start'
  desc 'Start Ranking process..'

  def start(params)
    @base_dir = File.expand_path(File.dirname(File.dirname(__FILE__)))
    @input_data_file = File.join(@base_dir, "sample-input.txt")
    @input_data = []
    @sport_team = {}

    unless File.exists?(@input_data_file)
      puts("Sorry ! Input data file (sample-input.txt) not found.")
    else
      canculate_rank
    end
  end

  def canculate_rank

    File.open(@input_data_file, "r").each_line do |line|
      team_array = []
      data = line.split(',')
      data.map{|d| team_array << {'team': get_name(d.strip.split(/(\D+)/)), 'point': d.strip.split(/(\D+)/).last } }
      @input_data << team_array
    end
      @input_data.each do |item|
        get_worth(item[0][:team], item[1][:team], item[0][:point], item[1][:point])
      end

      @output_data_file =  File.new(@base_dir+"/#{Time.now.to_i}-out.txt", "w")
      @sport_team = @sport_team.each {|k, v| @sport_team[k] = v.sum}.sort_by {|key, value| -value}.to_h
      i =1
      @sport_team.each do |team, worth|
        @output_data_file.puts("#{i}. #{team.to_s}, #{worth} pts")
        i +=1
      end
      puts("---------------------Start-------------------")
      puts("\nRanking file generated.")
      puts("\n----------------------End------------------")
      @output_data_file .close
  end

  def get_name(string)
    string.pop
    begin
     string = string.join.strip
    rescue
      nil
    end
    @sport_team.update({"#{string}": []})
    string
  end

  def get_worth(team1, team2, point1, point2)
    if point1 == point2
      @sport_team[team1.to_sym] << 1
      @sport_team[team2.to_sym] << 1
    elsif point1 > point2
      @sport_team[team1.to_sym] << 3
      @sport_team[team2.to_sym] << 0
    elsif point1 < point2
      @sport_team[team1.to_sym] << 0
      @sport_team[team2.to_sym] << 3
    end
  end

  usage 'Usage: ls'
  desc 'List file information about current directory'
  def ls(params)
      Dir.foreach(Dir.pwd) do |file|
          puts file
      end
  end

  usage 'Usage: pwd'
  desc 'Display current directory'

  def pwd(params)
      puts "Current directory: #{Dir.pwd}"
  end

  usage 'Usage: cd <Directory>'
  desc 'Change current directory'

  def cd(params)
      Dir.chdir(params[0]) unless params.empty?
  end

end


io = HighLine.new
shell = Start.new
console = CLI::Console.new(io)

console.addCommand('ls', shell.method(:ls), 'List files')
console.addCommand('pwd', shell.method(:pwd), 'Current directory')
console.addCommand('cd', shell.method(:cd), 'Change directory')
console.addCommand('start', shell.method(:start), 'Calculate Rank')
console.addHelpCommand('help', 'Help')
console.addExitCommand('exit', 'Exit from program')
console.addAlias('quit', 'exit')

console.start("%s> ",[Dir.method(:pwd)])
