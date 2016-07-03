class Math::Discrete::Graph::Edge
  attr_reader :from, :to
  attr_accessor :graph

  def self.build_from_vertices(from , to)
    new from: from, to: to
  end

  def set_graph!(graph)
    raise Math::Discrete::TypeError, 'graph must be of type Math::Discrete::Graph' unless graph.is_a? Graph

    @graph = graph
  end

  def labels
    [from.label, to.label].to_set
  end

  def to_set
    [from, to].to_set
  end

  private

  def initialize(from: , to:)
    raise Math::Discrete::TypeError, 'from must be of type Math::Discrete::Graph::Vertex' unless from.is_a? Vertex
    raise Math::Discrete::TypeError, 'to must be of type Math::Discrete::Graph::Vertex' unless to.is_a? Vertex

    @from = from
    @to = to
    @graph = nil

    @from.add_adjacent_vertex @to
  end
end
