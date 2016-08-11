module Math::Discrete::Graph::Predicates
  Math::Discrete::Graph::Properties.each do |property|
    define_method("#{property.adjective}?") { self.satisfies? property }
  end
end
