class Math::Discrete::Graph
  class VertexNotFound < StandardError; end
  class VertexNotUnique < StandardError; end
  class EdgeNotFound < StandardError; end
  class EdgeNotUnique < StandardError; end
  class BadEdgeType < StandardError; end

  include Algorithms
  include Predicates

  attr_reader :edge_set, :properties


  private_class_method :new
  def initialize(directed: true, vertex_set: Set[], edge_set: Set[])
    @vertex_map = vertex_set.map { |v| [v.label, v] }.to_h
    @edge_set = edge_set
    @directed = directed
    @properties = {}
  end

  def self.[](vertices_or_labels = Set[], edges_or_labels = Set[])
    unless vertices_or_labels.is_a?(Set) || vertices_or_labels.is_a?(Array)
      raise TypeError, 'vertices must be of type Set or Array'
    end

    unless edges_or_labels.is_a?(Set) || edges_or_labels.is_a?(Array)
      raise TypeError, 'edges must be of type Set or Array'
    end

    vertex_types = vertices_or_labels.map(&:class).uniq
    edge_types = edges_or_labels.map(&:class).uniq

    if (vertex_types == [Vertex] || vertex_types.empty?) && (edge_types == [Edge] || edge_types.empty?)
      build_from_sets(
        vertex_set: vertices_or_labels.to_set,
        edge_set: edges_or_labels.to_set
      )
    else
      build_from_labels(
        vertex_labels: vertices_or_labels.to_set,
        edge_labels: edges_or_labels.to_set
      )
    end
  end

  def self.build(directed: true)
    new directed: directed
  end

  class << self
    private

    def build_from_sets(vertex_set: Set[], edge_set: Set[])
      raise TypeError, 'vertex_set must be of type Set' unless vertex_set.is_a? Set
      raise TypeError, 'edge_set must be of type Set' unless edge_set.is_a? Set

      graph = edge_set.empty? ? new : new(directed: edge_set.first.directed?)

      graph.add_vertices! vertex_set
      graph.add_edges! edge_set

      graph
    end

    def build_from_labels(vertex_labels: Set[], edge_labels: Set[])
      raise TypeError, 'vertex_labels must be of type Set' unless vertex_labels.is_a? Set
      raise TypeError, 'edge_labels must be of type Set' unless edge_labels.is_a? Set

      vertices = Vertex::Set[*vertex_labels]

      edges = edge_labels.map do |label_set|
        from = vertices.find { |vertex| vertex.label == label_set.first }
        to = vertices.find { |vertex| vertex.label == label_set.to_a[1] }
        weight = label_set.to_a[2] || 1

        raise VertexNotFound, "could not find a vertex with label=#{ label_set.first }" if from.nil?
        raise VertexNotFound, "could not find a vertex with label=#{ label_set.to_a.last }" if to.nil?
        raise TypeError, 'edge weight must be of a Numeric type' unless weight.is_a? Numeric

        Edge::Directed[from, to, weight]
      end

      build_from_sets vertex_set: Set[*vertices], edge_set: Set[*edges]
    end
  end

  def add_vertex!(vertex)
    raise TypeError, 'vertex must be of the type Math::Discrete::Graph::Vertex' unless vertex.is_a? Vertex
    raise VertexNotUnique, 'vertex labels must be unique' unless unique_vertex? vertex

    clear_properties!

    @vertex_map[vertex.label] = vertex
  end
  alias_method :add_node!, :add_vertex!

  def add_vertices!(vertices)
    vertices.each { |vertex| add_vertex! vertex }
  end
  alias_method :add_nodes!, :add_vertices!

  def add_edge!(edge)
    raise TypeError, 'edge must be of the type Math::Discrete::Graph::Edge' unless edge.is_a? Edge
    raise EdgeNotUnique, 'edge already exists in graph' unless unique_edge? edge
    raise BadEdgeType, 'edge is undirected but graph is directed' if directed? && !edge.directed?
    raise BadEdgeType, 'edge is directed but graph is undirected' if !directed? && edge.directed?

    clear_properties!

    @edge_set.add edge
  end

  def add_edges!(edges)
    edges.each { |edge| add_edge! edge }
  end

  def remove_vertex!(vertex)
    raise TypeError, 'vertex must be of the type Math::Discrete::Graph::Vertex' unless vertex.is_a? Vertex

    find_vertex_by_label! vertex.label
    clear_properties!

    @edge_set.delete_if { |edge| edge.labels.include? vertex.label }
    @vertex_map.delete vertex.label
  end
  alias_method :remove_node!, :remove_vertex!

  def remove_vertices!(vertices)
    vertices.each { |vertex| remove_vertex! vertex }
  end
  alias_method :remove_nodes!, :remove_vertices!

  def remove_edge!(edge)
    raise TypeError, 'edge must be of the type Math::Discrete::Graph::Edge' unless edge.is_a? Edge
    raise EdgeNotFound, "could not find a edge with labels=(#{ edge.from.label },#{ edge.to.label })" unless @edge_set.include? edge

    clear_properties!

    @edge_set.delete edge
  end

  def remove_edges!(edges)
    edges.each { |edge| remove_edge! edge }
  end

  def find_vertex_by_label!(label)
    result = @vertex_map[label]

    raise VertexNotFound, "could not find a vertex with label=#{ label }" if result.nil?

    result
  end
  alias_method :find_node_by_label!, :find_vertex_by_label!

  def find_vertices_by_labels!(*labels)
    [*labels].map { |label| find_vertex_by_label! label }.to_set
  end
  alias_method :find_nodes_by_labels!, :find_vertices_by_labels!

  def find_edge_by_labels!(from_label, to_label)
    begin
      result = @edge_set.find do |edge|
        from = find_vertex_by_label! from_label
        to = find_vertex_by_label! to_label

        other_edge = if directed?
          Edge::Directed[from, to]
        else
          Edge::Undirected[from, to]
        end

        edge == other_edge
      end
    rescue VertexNotFound
      raise EdgeNotFound, "could not find a edge with labels=(#{ from_label },#{ to_label })"
    end

    raise EdgeNotFound, "could not find a edge with labels=(#{ from_label },#{ to_label })" if result.nil?

    result
  end

  def vertex_set
    @vertex_map.values.to_set
  end
  alias_method :node_set, :vertex_set

  def vertex_labels
    @vertex_map.keys.to_set
  end
  alias_method :node_labels, :vertex_labels

  def edge_labels
    @edge_set.map(&:labels).to_set
  end

  def directed?
    @directed
  end

  def weighted?
    @edge_set.any? &:weighted?
  end

  def satisfies?(property)
    property_name = property.name.to_sym

    return @properties[property_name] unless @properties[property_name].nil?

    @properties[property_name] = property.satisfied? self
    @properties.fetch property_name
  end

  def determine_properties!(properties = Properties::all)
    properties.map { |property| satisfies? property }

    @properties
  end

  private

  def unique_vertex?(vertex)
    @vertex_map[vertex.label].nil?
  end

  def unique_edge?(edge)
    @edge_set.find { |other_edge| edge == other_edge }.nil?
  end

  def clear_properties!
    @properties = {}
  end
end
