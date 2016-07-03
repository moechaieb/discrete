class Math::Discrete::Graph::Vertex
  attr_accessor :label
  attr_reader :graph, :adjacent_vertices

  def self.build_from_label(label)
    new label: label
  end

  def add_adjacent_vertex(vertex)
    @adjacent_vertices.add vertex
  end

  def set_graph!(graph)
    raise Math::Discrete::TypeError, 'graph must be of type Math::Discrete::Graph' unless graph.is_a? Graph

    @graph = graph
  end

  def ==(other_vertex)
    raise Math::Discrete::TypeError, 'other_vertex must be of type Math::Discrete::Vertex' unless other_vertex.is_a? Vertex

    label == other_vertex.label
  end

  private

  def initialize(label: nil)
    @graph = nil
    @label = label
    @adjacent_vertices = [].to_set
  end
end
