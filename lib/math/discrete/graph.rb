class Math::Discrete::Graph
  class VertexNotFound < StandardError; end
  class VertexNotUnique < StandardError; end
  class EdgeNotFound < StandardError; end
  class EdgeNotUnique < StandardError; end

  attr_reader :vertices, :edges, :name

  def self.build_from_sets(vertices: [].to_set, edges: [].to_set)
    raise Math::Discrete::TypeError, 'vertices must be of type Set' unless vertices.is_a? Set
    raise Math::Discrete::TypeError, 'edges must be of type Set' unless edges.is_a? Set

    graph = new

    vertices = vertices.map { |label| Vertex.build_from_label label }
    graph.add_vertices! vertices

    edges = edges.map do |from, to|
      Edge.new(
        from: find_vertex_by_label!(from),
        to: find_vertex_by_label!(to)
      )
    end
    graph.add_edges! edges

    graph
  end

  def add_vertex!(vertex)
    raise Math::Discrete::TypeError, 'vertex must be of the type Math::Discrete::Graph::Vertex' unless vertex.is_a? Vertex
    raise Math::Discrete::TypeError, 'vertex labels in a graph must be unique' unless unique_vertex? vertex

    vertex.set_graph! self
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

    edge.set_graph! self
    edge.from.add_adjacent_vertex edge.to
    edge.to.add_adjacent_vertex edge.from

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
