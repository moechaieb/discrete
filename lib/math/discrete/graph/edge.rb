class Edge
  attr_reader :first, :second
  attr_accessor :graph

  def initialize(first: , second:)
    raise Math::Discrete::TypeError, 'first must be of type Math::Discrete::Graph::Vertex' unless first.is_a? Vertex
    raise Math::Discrete::TypeError, 'second must be of type Math::Discrete::Graph::Vertex' unless second.is_a? Vertex

    @first = first
    @second = second
    @graph = nil
  end

  def set_graph!(graph)
    raise Math::Discrete::TypeError, 'first must be of type Math::Discrete::Graph' unless graph.is_a? Graph

    @graph = graph
  end

  def labels
    to_set.map &:label
  end

  def to_set
    [first, second].to_set
  end
end
