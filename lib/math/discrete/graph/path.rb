class Math::Discrete::Graph::Path < Math::Discrete::Structure
  class InvalidPath < StandardError; end

  property :cyclicality, adjective: :cyclical do |path|
    next path.edges.empty?

    path.edges.first.from == path.edges.last.to
  end

  private_class_method :new
  def initialize(edges = Set[])
    @edge_map = edges.map { |e| [[e.from.label, e.to.label], e] }.to_h
    @vertex_map = vertices.map { |v| [v.label, v] }.to_h
  end

  def self.[](*edges)
    raise InvalidPath, 'must be a valid continuous path' unless valid_path?(edges)

    new Set[*edges]
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
