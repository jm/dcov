documentation_for_all do |the_documentation|
  the_documentation.must " have coverage." do
    the_documentation.stats.coverage[:tokens][the_documentation.token] = []
    (the_documentation.token.comment.nil? || the_documentation.token.comment == '') ? the_documentation.stats.coverage[the_documentation.classifier][:not_covered] << the_documentation.token : the_documentation.stats.coverage[the_documentation.classifier][:covered] << the_documentation.token
    (the_documentation.token.comment.nil? || the_documentation.token.comment == '') ? the_documentation.stats.coverage[:tokens][the_documentation.token] << :not_covered : the_documentation.stats.coverage[:tokens][the_documentation.token] << :covered
  end
end
