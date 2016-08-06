class Math::Discrete::Graph
  class VertexNotFound < StandardError; end
  class VertexNotUnique < StandardError; end
  class EdgeNotFound < StandardError; end
  class EdgeNotUnique < StandardError; end
  class BadEdgeType < StandardError; end

  include Algorithms
  include Predicates

  attr_reader :vertex_set, :edge_set, :properties
  alias_method :node_set, :vertex_set

  def self.build(directed: true)
    new directed: directed
  end

  def self.build_from_sets(vertex_set: Set[], edge_set: Set[])
    raise Math::Discrete::TypeError, 'vertex_set must be of type Set' unless vertex_set.is_a? Set
    raise Math::Discrete::TypeError, 'edge_set must be of type Set' unless edge_set.is_a? Set

    graph = edge_set.empty? ? new : new(directed: edge_set.first.directed?)

    graph.add_vertices! vertex_set
    graph.add_edges! edge_set

    graph
  end

  def self.build_from_labels(directed: true, vertex_labels: Set[], edge_labels: Set[])
    raise Math::Discrete::TypeError, 'vertex_labels must be of type Set' unless vertex_labels.is_a? Set
    raise Math::Discrete::TypeError, 'edge_labels must be of type Set' unless edge_labels.is_a? Set

    vertices = vertex_labels.map { |label| Vertex.build_from_label label }

    edges = edge_labels.map do |label_set|
      from = vertices.find { |vertex| vertex.label == label_set.first }
      to = vertices.find { |vertex| vertex.label == label_set.to_a.last }

      raise VertexNotFound, "could not find a vertex with label=#{label_set.first}" if from.nil?
      raise VertexNotFound, "could not find a vertex with label=#{label_set.to_a.last}" if to.nil?

      if directed
        Edge::Directed.build from: from, to: to
      else
        Edge::Undirected.build_between from, to
      end
    end

    build_from_sets vertex_set: Set[*vertices], edge_set: Set[*edges]
  end

  def add_vertex!(vertex)
    raise Math::Discrete::TypeError, 'vertex must be of the type Math::Discrete::Graph::Vertex' unless vertex.is_a? Vertex
    raise VertexNotUnique, 'vertex labels must be unique' unless unique_vertex? vertex

    clear_properties!

    @vertex_set.add vertex
  end
  alias_method :add_node!, :add_vertex!

  def add_vertices!(vertices)
    vertices.each { |vertex| add_vertex! vertex }
  end
  alias_method :add_nodes!, :add_vertices!

  def add_edge!(edge)
    raise Math::Discrete::TypeError, 'edge must be of the type Math::Discrete::Graph::Edge' unless edge.is_a? Edge
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
    raise Math::Discrete::TypeError, 'vertex must be of the type Math::Discrete::Graph::Vertex' unless vertex.is_a? Vertex

    find_vertex_by_label! vertex.label
    clear_properties!

    @edge_set.delete_if { |edge| edge.labels.include? vertex.label }
    @vertex_set.delete vertex
  end
  alias_method :remove_node!, :remove_vertex!

  def remove_vertices!(vertices)
    vertices.each { |vertex| remove_vertex! vertex }
  end
  alias_method :remove_nodes!, :remove_vertices!

  def remove_edge!(edge)
    raise Math::Discrete::TypeError, 'edge must be of the type Math::Discrete::Graph::Edge' unless edge.is_a? Edge
    raise EdgeNotFound, "could not find a edge with labels=(#{edge.from.label},#{edge.to.label})" unless @edge_set.include? edge

    clear_properties!

    @edge_set.delete edge
  end

  def remove_edges!(edges)
    edges.each { |edge| remove_edge! edge }
  end

  def find_vertex_by_label!(label)
    result = @vertex_set.find { |vertex| vertex.label == label }

    raise VertexNotFound, "could not find a vertex with label=#{label}" if result.nil?

    result
  end
  alias_method :find_node_by_label!, :find_vertex_by_label!

  def find_vertices_by_labels!(*labels)
    Set[*[*labels].map { |label| find_vertex_by_label! label }]
  end
  alias_method :find_nodes_by_labels!, :find_vertices_by_labels!

  def find_edge_by_labels!(from_label, to_label)
    begin
      result = @edge_set.find do |edge|
        from = find_vertex_by_label! from_label
        to = find_vertex_by_label! to_label

        other_edge = if directed?
          Math::Discrete::Graph::Edge::Directed.build from: from, to: to
        else
          Math::Discrete::Graph::Edge::Undirected.build_between from, to
        end

        edge == other_edge
      end
    rescue VertexNotFound
      raise EdgeNotFound, "could not find a edge with labels=(#{from_label},#{to_label})"
    end

    raise EdgeNotFound, "could not find a edge with labels=(#{from_label},#{to_label})" if result.nil?

    result
  end

  def vertex_labels
    Set[*@vertex_set.map(&:label)]
  end
  alias_method :node_labels, :vertex_labels

  def edge_labels
    Set[*@edge_set.map(&:labels)]
  end

  def directed?
    @directed
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

  def initialize(directed: true, vertex_set: Set[], edge_set: Set[])
    @vertex_set = vertex_set
    @edge_set = edge_set
    @directed = directed
    @properties = {}
  end

  def unique_vertex?(vertex)
    find_vertex_by_label! vertex.label

    false
  rescue VertexNotFound
    true
  end

  def unique_edge?(edge)
    @edge_set.find { |other_edge| edge == other_edge }.nil?
  end

  def clear_properties!
    @properties = {}
  end
end
