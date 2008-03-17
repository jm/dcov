require 'rubygems'
# require 'ruport'

module Dcov
  class StatsRenderer # < Ruport::Renderer
  
    # stage :stats_header, :stats_body, :stats_footer
  
    module Helpers
     
      def class_coverage
        data[:coverage_rating][:class]
      end

      def module_coverage
        data[:coverage_rating][:module]
      end

      def method_coverage
        data[:coverage_rating][:method]
      end

    end
  end
  
  class TopLevel
    attr_accessor :comment
  end
  
  # RDoc's Stats class with our own stats thrown in and our own custom
  # print method.
  class Stats
    
    attr_accessor :num_files, :num_classes, :num_modules, :num_methods, :coverage
    
    # include Ruport::Renderer::Hooks
    # renders_with Dcov::StatsRenderer
    
    def initialize
      @num_files = @num_classes = @num_modules = @num_methods = 0
      @start = Time.now
    
      @coverage = { }

      [:class, :method, :module].each do |type|
        @coverage[type] = { :covered => [], :not_covered => [] }
      end
      
      @coverage[:tokens] = {}
    end
  
    # Print out the coverage rating
    def print
      # TODO: add a flag for textmate, the ugliest format ever:
      # txmt://open?url=file:///path/to/file.rb&line=86&column=3

      puts "Files:   #{@num_files}"
      puts "Total Classes: #{@num_classes}"
      puts "Total Modules: #{@num_modules}"
      puts "Total Methods: #{@num_methods}"

      puts
      puts "Module coverage: #{coverage_rating(:module)}%"
      puts "  Not covered:"
      @coverage[:module][:not_covered].sort_by {|o| o.name}.each do |itm|
        location = itm.in_files.first.file_absolute_name || "no known location"
        puts "    #{itm.name}:"
        puts "      #{location}"
      end

      puts
      
      puts
      puts "Class coverage: #{coverage_rating(:class)}%"
      puts "  Not covered:"
      @coverage[:class][:not_covered].sort_by {|o| o.name}.each do |itm|
        location = itm.in_files.first.file_absolute_name
        puts "    #{itm.name}"
        puts "      #{location}"
      end

      puts

      puts
      puts "Method coverage: #{coverage_rating(:method)}%\n"
      puts "  Not covered:"
      @coverage[:method][:not_covered].sort_by {|o| [o.parent.name, o.name]}.each do |itm|
        location = itm.token_stream.first.text.sub(/^# File /, '').sub(/, line (\d+)$/, ':\1')
        puts "    #{itm.parent.name}##{itm.name}:"
        puts "       #{location}"
      end
      
      puts
    end
  
    # Get the coverage rating (e.g., 34%) for the tokens of the type specified
    def coverage_rating(tokens)
      rating = ((@coverage[tokens][:covered].size.to_f / (@coverage[tokens][:covered].size.to_f + @coverage[tokens][:not_covered].size.to_f)) * 100)
      
      # If it's NaN (for whatever reason, be it an irrational or irrationally small number), return 0
      (rating.nan?) ? 0 : rating.to_i
    end
    
    def renderable_data
      data = {}
      data[:coverage_rating] = {}
      
      [:class, :method, :module].each do |token|
        data[:coverage_rating][token] = coverage_rating(token)
      end
      
      classes = @coverage[:class][:not_covered] + @coverage[:class][:covered]
      modules = @coverage[:module][:not_covered] + @coverage[:module][:covered]
      methods = @coverage[:method][:not_covered] + @coverage[:method][:covered]
      
      # Create a properly nested structure
      data[:structured] = {}
      classes.each {|cls| data[:structured][cls.full_name] = [cls, []]}
      modules.each {|mod| data[:structured][mod.full_name] = [mod, []]}
      data[:structured]['[Toplevel]'] = [TopLevel.new, []]
      
      methods.each do |method|
        if (data[:structured].has_key?(method.parent.full_name))
          data[:structured][method.parent.full_name][1] << method
        else
          data[:structured]['[Toplevel]'][1] << method
        end
      end
      
      data[:analyzed] = @coverage
      
      data
    end
  end
end