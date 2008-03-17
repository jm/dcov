require 'rdoc/rdoc'
require File.dirname(__FILE__) + '/analyzed_token.rb'
require File.dirname(__FILE__) + '/stats'

# Makes +stats+ accessible to us so we can inject our own.
# We also add a +classifier+ attribute to the code object classes.
module RDoc
  class RDoc
    attr_accessor :stats
  end
  
  module DcovHelpers
    attr_accessor :reporting_data
    
    def initialize(*args)
      super(*args)
      @reporting_data = {}
      initialize_reporting_data
    end
    
    def full_name
      hierarchy = self.name
      inspect = self
      while (hier_piece = inspect.parent)
        hierarchy = hier_piece.name + "::" + hierarchy unless hier_piece.name == 'TopLevel'
        inspect = hier_piece
      end
      
      hierarchy
    end
  end
  
  class AnyMethod
    include DcovHelpers
    
    def classifier
      :method
    end
    
    def initialize_reporting_data
      @reporting_data[:parameters_without_coverage] = []
      @reporting_data[:default_values_without_coverage] = []
    end
  end
  
  class NormalClass
    include DcovHelpers
    
    def classifier
      :class
    end
    
    def initialize_reporting_data
    end
  end
  
  class NormalModule
    include DcovHelpers
    
    def classifier
      :module
    end
    
    def initialize_reporting_data
    end
  end
end

module Dcov
  class AnalysisContext
    attr_accessor :token, :comment, :classifier, :stats
    
    def initialize(token, comment, classifier, stats)
      @token = token
      @comment = comment || ''
      @classifier = classifier
      @stats = stats
    end
    
    def must(description)
      yield description      
    end
  end
  
  # Mocked options object to feed to RDoc
  class RDocOptionsMock
    attr_accessor :files

    def initialize(file_list)
      @files = file_list
    end

    def method_missing(*args)
      false
    end
  end
  
  # Main class
  class Analyzer    
    attr_accessor :classes, :methods, :modules, :hierarchy, :stats
    
    # Grab the arguments from the DCov init script or
    # another calling script and feed them to RDoc for
    # parsing.
    def initialize(options)
      @options = options
      raise "No files to analyze!" if @options[:files] == [] || @options[:files] == nil
      
      # Setup the analyzed tokens array so we can keep track of which methods we've already
      # taken a look at...
      @analyzed_tokens = []
      
      r = RDoc::RDoc.new
      
      # Instantiate our little hacked Stats class...
      @stats = Dcov::Stats.new
      r.stats = @stats
      
      # Get our analyzers together...
      @analyzers = []
      find_analyzers
      
      # Setup any options we need here...
      Options.instance.parse(["--tab-width", 2], {})
            
      # We have to use #send because #parse_files is private
      parsed_structure = r.send(:parse_files, RDocOptionsMock.new(options[:files]))
      
      # Analyze it, Spiderman!
      analyze parsed_structure
      
      # Generate the report!
      generate
    end
    
    # Method to initialize analysis of the code; passes
    # structure off to the process method which actually
    # processes the tokens.
    def analyze(hierarchy)
      @hierarchy = hierarchy
      process

      @stats.print   
    end
    
    # Method to start walking the hierarchy of tokens,
    # separating them into covered/not covered (and 
    # eventually lexing their comments for quality).
    def process
      @hierarchy.each do |hier| 
        hier.classes.each do |cls| 
          process_token cls
        end
        
        hier.modules.each do |mod|
          process_token mod
        end
      end
    end
    
    # Method to process all the tokens for a token...recursion FTW! :)
    def process_token(token)
      analyzed_token = AnalyzedToken.new(token.name, token.parent)
      unless @analyzed_tokens.include?(analyzed_token)
        token = expose_to_analyzers(token)
        @analyzed_tokens << analyzed_token
                 
        [:method_list, :classes, :modules].each do |meth, type|
          token.send(meth).each do |item|
            process_token item
          end if token.respond_to?(meth)
        end
      end
    end
    
    # Generate the output based on the format specified
    # TODO: Have an argument sanity check at startup to make sure we actually have a generator for the format
    def generate
      print "Generating report..."
      require File.dirname(__FILE__) + "/generators/#{@options[:output_format]}/generator.rb"

      generator = Dcov::Generator.new @stats.renderable_data
      report = generator.to_s
      print "done.\n"
      
      print "Writing report..."
      if (!File.exists?("#{@options[:path]}/coverage.html")) || (File.writable?("#{@options[:path]}/coverage.html"))
        output_file = File.open("#{@options[:path]}/coverage.html", "w")
        output_file.write report
        output_file.close
        print "done.\n"
      else
        raise "Can't write to [#{@options[:path]}/coverage.html]."
      end
    end
    
    # Grok the analyzers directory and find all analyzers
    def find_analyzers
      Dir::entries(File.dirname(__FILE__) + "/analyzers").each do |analyzer|
        next unless /(\w+)_analyzer.rb$/ =~ analyzer
        @analyzers << File.dirname(__FILE__) + "/analyzers/#{analyzer}"
      end
    end
    
    # Fire off the token to each analyzer, letting it have its way with
    # the token and the Stats instance.
    def expose_to_analyzers(token)
      @analyzers.each do |analyzer|
        classifier = token.classifier
        eval(File.read(analyzer))
        
        token = analyze_token(token, classifier, @stats)
        @method_analysis, @module_analysis, @class_analysis, @all_analysis = nil
      end
      
      token
    end
    
    def documentation_for_methods(&block)
      @method_analysis = block
    end
    
    def documentation_for_classes(&block)
      @class_analysis = block
    end
    
    def documentation_for_modules(&block)
      @module_analysis = block
    end
    
    def documentation_for_all(&block)
      @all_analysis = block
    end
    
    def analyze_token(token, classifier, stats)
      context = AnalysisContext.new(token, (token.comment || ''), classifier, stats)
      
      @all_analysis.call(context) if @all_analysis
  
      case classifier
        when :method
          @method_analysis.call(context) if @method_analysis
        when :class
          @class_analysis.call(context) if @class_analysis
        when :module
          @module_analysis.call(context) if @module_analysis
      end
      
      context.token
    end
    
    def param_names_for(token)
      if token.params
        params = token.params.dup
        params.gsub!(/\(/, '')
        params.gsub!(/\)/, '')

        if params.include?(",")
          params = params.split(",")
        else
          params = [params]
        end

        processed_params = []

        params.each do |param|
          param_value = nil

          # We have a default value...
          if param.include?('=')
            param_pieces = param.scan(/(.*)=(.*)/)[0]
            param = param_pieces[0].strip 
            param_value = param_pieces[1].strip
          end

          processed_params << [param, param_value]
        end

        if processed_params == [["", nil]]
          []
        else
          processed_params  
        end
      else
        []
      end
    end
  end
end   
