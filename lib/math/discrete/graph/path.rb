class Math::Discrete::Graph::Path
  class InvalidPath < StandardError; end

  private_class_method :new
  def initialize(edges = Set[])
    @edges = edges
  end

  def self.[](edges = [])
    raise Math::Discrete::TypeError, 'edges must be an Array' unless edges.is_a? Array
    raise Math::Discrete::Graph::EdgeNotUnique, 'edges must be unique' unless edges.uniq.size == edges.size
    raise InvalidPath, 'must be a valid continuous path' unless valid_path?(edges)

    new edges
  end

  def cycle?
    return false if @edges.empty?

    labels.first.first == labels.last.last
  end

  def labels
    Set[*@edges.map(&:labels)]
  end

  def vertices
    Set[*@edges.flat_map(&:vertices)]
  end

  def directed?
    @edges.any? &:directed?
  end

  def weighted?
    @edges.any? &:weighted?
  end

  def length
    @edges.size
  end

  private

  def self.valid_path?(edges)
    true
  end
end