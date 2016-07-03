class Math::Discrete::Graph::Edge
  attr_reader :from, :to

  def self.build_from_vertices(from , to)
    new from: from, to: to
  end

  def labels
    Set[from.label, to.label]
  end

  def to_set
    Set[from, to]
  end

  private

  def initialize(from: , to:)
    raise Math::Discrete::TypeError, 'from must be of type Math::Discrete::Graph::Vertex' unless from.is_a? Vertex
    raise Math::Discrete::TypeError, 'to must be of type Math::Discrete::Graph::Vertex' unless to.is_a? Vertex

    @from = from
    @to = to

    @from.send :add_adjacent_vertex, @to
  end
end
