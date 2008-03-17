
module Dcov
  # Generates HTML output
  class Generator # < Ruport::Formatter::HTML
    # renders :html, :for => StatsRenderer

    include Dcov::StatsRenderer::Helpers

    attr_reader :data
    def initialize(data)
      @data = data
    end

    def to_s
      build_stats_header +  build_stats_body + build_stats_footer
    end
          
    def build_stats_header 
      # Little CSS, a little HTML...
      output = ""
      output << """<html><head><title>dcov results</title>
                <style> 
                  BODY { font-family: Helvetica, Arial, sans-serif; font-size: 10pt; background: #333; color: white; margin: 16px; }
                  H1 { text-shadow: 3pt 3pt 5pt black;}
                  .quality_problem { font-size: 8pt; color: #999; }
                  LI { margin: 8px; }
                </style>
                </head><body>\n<h1>dcov results</h1>\n\n"""
    end

    def build_stats_body
      output = ""
      output << "<p>\n"
      output << "Class coverage: <b>#{class_coverage}%</b><br>\n"
      output << "Module coverage: <b>#{module_coverage}%</b><br>\n"
      output << "Method coverage: <b>#{method_coverage}%</b><br>\n"
      output << "</p>\n\n"
      output << "<ol>\n" 

      data[:structured].each do |key,value|
        output << ((value[0].comment.nil? || value[0].comment == '') ? 
                "\t<li><font color='#f00;'><tt>#{key.is_a?(String) ? key : key.full_name  }</tt></font>\n\t\t<ol>\n" : 
                "\t<li><tt>#{key}</tt>\n\t\t<ol>") unless value[0].is_a?(Dcov::TopLevel)

        value[1].each do |itm|
          output << ((itm.comment.nil? || itm.comment == '') ? 
                "\t\t\t<li><font color='#f00;'><tt>#{itm.name}</tt></font>\n" : 
                 "\t\t\t<li><tt>#{itm.name}</tt>\n")
          
          # Quality information
          output << "#{"<br /><span class='quality_problem'>parameters without documentation: <tt>" + itm.reporting_data[:parameters_without_coverage].join(", ") + "</tt></span>" if itm.reporting_data[:parameters_without_coverage].length > 0}"
          output << "#{"<br /><span class='quality_problem'>default values without documentation: <tt>" + itm.reporting_data[:default_values_without_coverage].join(", ") + "</tt></span>" if itm.reporting_data[:default_values_without_coverage].length > 0}"
          output << "#{"<br /><span class='quality_problem'>options are not documented</span>" if itm.reporting_data[:no_options_documentation]}"
          output << "#{"<br /><span class='quality_problem'>there are no examples</span>" if itm.reporting_data[:no_examples]}"
                  
          output << "</li>\n"
        end

        output << "\t\t</ol>\n\t</li>\n\n" unless value[0].is_a?(Dcov::TopLevel)
      end  
      output
    end

    def build_stats_footer
      output = ""
      output << "</ol>\n\n</body></html>"   
    end

  end
end