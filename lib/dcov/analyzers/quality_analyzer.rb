documentation_for_all do |the_documentation|
  
  the_documentation.must "contain examples." do
    if the_documentation.token.visibility == :public
      if (the_documentation.token.comment.include?("= Example")) || (the_documentation.token.comment.include?("Here are some examples")) || (the_documentation.token.comment.include?("For example"))
        the_documentation.token.reporting_data[:no_examples] = true
      end
    end
  end
  
end

documentation_for_methods do |the_documentation|
  
  the_documentation.must "document all options hashes." do
    if (the_documentation.token.params.include?("options")) || (the_documentation.token.params.include?("opts"))
      the_documentation.token.reporting_data[:no_options_documentation] = true unless the_documentation.token.comment.include?("+options+") || the_documentation.token.comment.include?("+opts+") || the_documentation.token.comment.downcase.include?("= options") 
    end
  end
  
  the_documentation.must "document all parameters." do
    param_names_for(the_documentation.token).each do |param|
      the_documentation.token.reporting_data[:parameters_without_coverage] << param[0] unless the_documentation.token.comment.include?("+#{param[0]}+")
    end if the_documentation.token.params
  end
  
  the_documentation.must "document all default values for parameters." do
    param_names_for(the_documentation.token).each do |param|
      unless param[1].nil?
        bare_comment = the_documentation.token.comment.downcase.gsub(/'/, '')
        bare_comment.gsub!(/\"/, '')
        the_documentation.token.reporting_data[:default_values_without_coverage] << param[0] unless bare_comment.include?("defaults to #{param[1]}") || bare_comment.include?("default: #{param[1]}")
      end
    end
  end

end
