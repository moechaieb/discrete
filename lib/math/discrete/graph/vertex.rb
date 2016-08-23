class Math::Discrete::Graph::Vertex
  attr_accessor :label
  attr_reader :adjacent_vertices

  private_class_method :new
  def initialize(label: nil)
    @label = label
    @adjacent_vertices = Set[]
    @edge_weights = {}
  end

  def self.[](label)
    new label: label
  end

  module Set
    def self.[](*labels)
      [*labels].map { |label| Vertex[label] }.to_set
    end
  end

  def adjacent_to?(other_vertex)
    raise TypeError, 'other_vertex must be of type Math::Discrete::Vertex' unless other_vertex.is_a? Vertex

    @adjacent_vertices.include? other_vertex
  end

  def distance_to(other_vertex)
    raise Math::Discrete::Graph::VertexNotFound, 'vertex must be adjacent' unless adjacent_to? other_vertex

    @edge_weights[other_vertex.label]
  end

  def ==(other_vertex)
    raise TypeError, 'other_vertex must be of type Math::Discrete::Vertex' unless other_vertex.is_a? Vertex

    label == other_vertex.label
  end
  alias_method :eql?, :==

  def hash
    label.hash
  end

  private

  def add_adjacent_vertex(vertex, weight = 1)
    @adjacent_vertices.add vertex
    @edge_weights[vertex.label] = weight
  end

  def remove_adjacent_vertex(vertex)
    @adjacent_vertices.delete vertex
    @edge_weights.delete vertex.label
  end
end
