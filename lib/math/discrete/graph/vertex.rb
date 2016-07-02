class Math::Discrete::Graph::Vertex
  attr_accessor :label
  attr_reader :graph, :adjacent_vertices

  def self.build_from_label(label)
    new label: label
  end

  def initialize(label: nil)
    @graph = nil
    @label = label
    @adjacent_vertices = [].to_set
  end

  def add_adjacent_vertex(vertex)
    @adjacent_vertices.add vertex
  end

  def set_graph!(graph)
    raise Math::Discrete::TypeError, 'first must be of type Math::Discrete::Graph' unless graph.is_a? Graph

    @graph = graph
  end

  def ==(other_vertex)
    label == other_vertex.label
  end
end
