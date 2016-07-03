class Math::Discrete::Graph::Vertex
  attr_accessor :label
  attr_reader :adjacent_vertices

  def self.build_from_label(label)
    new label: label
  end

  def add_adjacent_vertex(vertex)
    @adjacent_vertices.add vertex
  end

  def remove_adjacent_vertex(vertex)
    @adjacent_vertices.delete vertex
  end

  def ==(other_vertex)
    raise Math::Discrete::TypeError, 'other_vertex must be of type Math::Discrete::Vertex' unless other_vertex.is_a? Vertex

    label == other_vertex.label
  end

  private

  def initialize(label: nil)
    @label = label
    @adjacent_vertices = [].to_set
  end
end
