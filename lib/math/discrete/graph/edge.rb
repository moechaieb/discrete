class Math::Discrete::Graph::Edge
  attr_reader :from, :to
  attr_accessor :weight

  private_class_method :new
  def initialize(from: , to:, directed: true, weight: 1)
    raise Math::Discrete::TypeError, 'from must be of type Math::Discrete::Graph::Vertex' unless from.is_a? Vertex
    raise Math::Discrete::TypeError, 'to must be of type Math::Discrete::Graph::Vertex' unless to.is_a? Vertex
    raise Math::Discrete::TypeError, 'directed must be of a Boolean type' unless !!directed == directed
    raise Math::Discrete::TypeError, 'weight must be of a Numeric type' unless weight.is_a? Numeric

    @from = from
    @to = to
    @directed = directed
    @weight = weight

    @from.send :add_adjacent_vertex, @to, weight
    @to.send :add_adjacent_vertex, @from, weight unless directed
  end

  module Undirected
    def self.[](from, to, weight = 1)
      Edge.send :new, directed: false, from: from, to: to, weight: weight
    end
  end

  module Directed
    def self.[](from, to, weight = 1)
      Edge.send :new, directed: true, from: from, to: to, weight: weight
    end
  end

  module Set
    module Undirected
      def self.[](*edges)
        edges.map { |edge| Edge::Undirected[*edge] }.to_set
      end
    end

    module Directed
      def self.[](*edges)
        edges.map { |edge| Edge::Directed[*edge] }.to_set
      end
    end
  end

  def labels
    [from.label, to.label].to_set
  end

  def vertices
    [from, to].to_set
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
end
