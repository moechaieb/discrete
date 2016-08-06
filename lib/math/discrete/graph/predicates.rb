module Math::Discrete::Graph::Predicates
  Math::Discrete::Graph::Properties.each do |property|
    define_method("#{property.adjective}?") do
      self.satisfies? property
    end
  end
end
