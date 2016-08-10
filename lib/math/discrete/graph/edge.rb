class Math::Discrete::Graph::Edge
  attr_reader :from, :to
  attr_accessor :weight

  module Undirected
    def self.build_between(from, to, weight: 1)
      Graph::Edge.new directed: false, from: from, to: to, weight: weight
    end
  end

  module Directed
    def self.build(from:, to:, weight: 1)
      Graph::Edge.new directed: true, from: from, to: to, weight: weight
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
    return true if from == other_edge.from && to == other_edge.to
    return true if from == other_edge.to && to == other_edge.from

    false
  end

  def directed?
    @directed
  end

  def weighted?
    @weight != 1
  end

  private

  def initialize(from: , to:, directed: true, weight: 1)
    raise Math::Discrete::TypeError, 'from must be of type Math::Discrete::Graph::Vertex' unless from.is_a? Vertex
    raise Math::Discrete::TypeError, 'to must be of type Math::Discrete::Graph::Vertex' unless to.is_a? Vertex
    raise Math::Discrete::TypeError, 'directed must be of a Boolean type' unless !!directed == directed
    raise Math::Discrete::TypeError, 'weight must be of a Numeric type' unless weight.is_a? Numeric

    @from = from
    @to = to
    @directed = directed
    @weight = weight

    @from.send :add_adjacent_vertex, @to
    @to.send :add_adjacent_vertex, @from unless directed
  end
end
