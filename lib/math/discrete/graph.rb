class Math::Discrete::Graph
  class VertexNotFound < StandardError; end
  class VertexNotUnique < StandardError; end
  class EdgeNotFound < StandardError; end
  class EdgeNotUnique < StandardError; end

  attr_reader :vertices, :edges, :name

  def self.build
    new
  end

  def self.build_from_sets(vertices: [].to_set, edges: [].to_set)
    raise Math::Discrete::TypeError, 'vertices must be of type Set' unless vertex_labels.is_a? Set
    raise Math::Discrete::TypeError, 'edges must be of type Set' unless edge_labels.is_a? Set

    graph = new

    graph.add_vertices! vertices
    graph.add_edges! edges

    graph
  end

  def self.build_from_labels(vertex_labels: [].to_set, edge_labels: [].to_set)
    raise Math::Discrete::TypeError, 'vertices must be of type Set' unless vertex_labels.is_a? Set
    raise Math::Discrete::TypeError, 'edges must be of type Set' unless edge_labels.is_a? Set

    vertices = vertex_labels.map { |label| Vertex.build_from_label label }

    edges = edge_labels.flat_map do |from, to|
      [
        Edge.new(from: find_vertex_by_label!(from), to: find_vertex_by_label!(to)),
        Edge.new(from: find_vertex_by_label!(to), to: find_vertex_by_label!(from))
      ]
    end

    build_from_sets vertices: vertices, edges: edges
  end

  def add_vertex!(vertex)
    raise Math::Discrete::TypeError, 'vertex must be of the type Math::Discrete::Graph::Vertex' unless vertex.is_a? Vertex
    raise Math::Discrete::TypeError, 'vertex labels must be unique' unless unique_vertex? vertex

    @vertices.add vertex
  end

  def add_node!(node)
    add_vertex! node
  end

  def add_vertices!(vertices)
    vertices.each { |vertex| add_vertex! vertex }
  end

  def add_nodes!(nodes)
    add_vertices!(nodes)
  end

  def add_edge!(edge)
    raise Math::Discrete::TypeError, 'edge must be of the type Math::Discrete::Graph::Edge' unless edge.is_a? Edge
    raise Math::Discrete::TypeError, 'edge already exists in graph' unless unique_edge? edge

    @edges.add edge
  end

  def add_edges!(edges)
    edges.each { |edge| add_edge! edge }
  end

  def find_vertex_by_label!(label)
    result = @vertices.find { |vertex| vertex.label == label }

    raise VertexNotFound, "could not find a vertex with label=#{label}" if result.nil?

    result
  end

  def find_vertices_by_labels!(labels)
    result = @vertices.find_all { |vertex| labels.include? vertex.label }

    raise VertexNotFound, "could not find a vertices with labels #{labels}" if result.nil?

    result
  end

  def find_edge_by_labels!(from, to)
    result = @edges.find { |edge| edge.from == from && edge.to == to || edge.from == to && edge.to == from }

    raise EdgeNotFound, "could not find a edge with label=#{label}" if result.nil?

    result
  end

  def vertex_labels
    @vertices.map &:label
  end

  def vertex_ids
    @vertices.map &:id
  end

  def nodes
    vertices
  end

  private

  attr_writer :vertices, :edges, :name

  def initialize(vertices: [].to_set, edges: [].to_set)
    @vertices = vertices
    @edges = edges
  end

  def unique_vertex?(vertex)
    find_vertices_by_labels! vertex.label
  rescue VertexNotFound
    true
  end

  def unique_edge?(edge)
    find_edge_by_labels! edge.from.label, edge.to.label
  rescue EdgeNotFound
    true
  end
end
