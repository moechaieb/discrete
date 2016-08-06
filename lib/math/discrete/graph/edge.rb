class Math::Discrete::Graph::Edge
  attr_reader :from, :to

  module Undirected
    def self.build_between(from, to)
      Graph::Edge.new directed: false, from: from, to: to
    end
  end

  module Directed
    def self.build(from:, to:)
      Graph::Edge.new directed: true, from: from, to: to
    end
  end

  def labels
    Set[from.label, to.label]
  end

  def to_set
    Set[from, to]
  end

  def ==(other_edge)
    return false unless directed? == other_edge.directed?

    return from == other_edge.from && to == other_edge.to if directed?
    from == other_edge.from && to == other_edge.to || from == other_edge.to && to == other_edge.from
  end

  def directed?
    @directed
  end

  private

  def initialize(from: , to:, directed: true)
    raise Math::Discrete::TypeError, 'from must be of type Math::Discrete::Graph::Vertex' unless from.is_a? Vertex
    raise Math::Discrete::TypeError, 'to must be of type Math::Discrete::Graph::Vertex' unless to.is_a? Vertex
    raise Math::Discrete::TypeError, 'directed must be of a boolean type' unless !!directed == directed

    @from = from
    @to = to
    @directed = directed

    @from.send :add_adjacent_vertex, @to
    @to.send :add_adjacent_vertex, @from unless directed
  end
end
