class Math::Discrete::Graph::Edge
  attr_reader :from, :to
  attr_accessor :weight

  private_class_method :new
  def initialize(from: , to:, weight: 1)
    raise TypeError, 'from must be of type Math::Discrete::Graph::Vertex' unless from.is_a? Vertex
    raise TypeError, 'to must be of type Math::Discrete::Graph::Vertex' unless to.is_a? Vertex
    raise TypeError, 'weight must be of a Numeric type' unless weight.is_a? Numeric

    @from = from
    @to = to
    @weight = weight

    @from.send :add_adjacent_vertex, @to, weight
  end

  def self.[](from, to, weight = 1)
    new from: from, to: to, weight: weight
  end

  module Set
    def self.[](*edges)
      edges.map { |edge| Edge[*edge] }.to_set
    end
  end

  def labels
    [from.label, to.label].to_set
  end

  def vertices
    [from, to].to_set
  end

  def ==(other_edge)
    from == other_edge.from && to == other_edge.to
  end
  alias_method :eql?, :==

  def hash
    labels.hash
  end

  def weighted?
    @weight != 1
  end

  def reverse(weight: @weight)
    Edge[to, from, weight]
  end
end
