class Math::Discrete::Graph::Path
  class InvalidPath < StandardError; end

  private_class_method :new
  def initialize(edges = Set[])
    @edge_map = edges.map { |e| [[e.from.label, e.to.label], e] }.to_h
    @vertex_map = vertices.map { |v| [v.label, v] }.to_h
  end

  def self.[](*edges)
    raise InvalidPath, 'must be a valid continuous path' unless valid_path?(edges)

    new Set[*edges]
  end

  def cyclical?
    return false if @edge_map.empty?

    @edge_map.values.first.from == @edge_map.values.last.to
  end

  def edges
    Set[*@edge_map.values]
  end

  def vertices
    Set[*@edge_map.values.map(&:vertices).reduce(&:+)]
  end
  alias_method :nodes, :vertices

  def self.valid_path?(edges)
    edges.each_cons(2).all? do |initial_edge, following_edge|
      initial_edge.to == following_edge.from
    end
  end
  private_class_method :valid_path?
end
