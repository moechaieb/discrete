class Math::Discrete::Graph::Path
  class InvalidPath < StandardError; end

  attr_reader :edges

  private_class_method :new
  def initialize(edges = Set[])
    @edges = edges
  end

  def self.[](*edges)
    raise InvalidPath, 'must be a valid continuous path' unless valid_path?(edges)

    new Set[*edges]
  end

  def cyclical?
    return false if @edges.empty?

    labels.first.first == labels.to_a.last.to_a.last
  end

  def labels
    Set[*@edges.map(&:labels)]
  end

  def vertices
    Set[*@edges.map(&:vertices).reduce(&:+)]
  end
  alias_method :nodes, :vertices

  def length
    @edges.size
  end

  private

  def self.valid_path?(edges)
    edges.each_cons(2).all? do |initial_edge, following_edge|
      initial_edge.to == following_edge.from
    end
  end
end
