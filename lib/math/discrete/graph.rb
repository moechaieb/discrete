class Math::Discrete::Graph
  class VertexNotFound < StandardError; end
  class VertexNotUnique < StandardError; end
  class EdgeNotFound < StandardError; end
  class EdgeNotUnique < StandardError; end

  attr_reader :vertices, :edges, :name

  def initialize(name, vertices: [].to_set, edges: [].to_set)
    raise Math::Discrete::TypeError, 'vertices must be of type Set' unless vertices.is_a? Set
    raise Math::Discrete::TypeError, 'edges must be of type Set' unless edges.is_a? Set

    @name = name
    @vertices = [].to_set
    @edges = [].to_set

    vertices = vertices.map { |label| Vertex.from_label label }
    add_vertices! vertices

    edges = edges.map do |first, second|
      Edge.new(
        first: find_vertex_by_label!(first),
        second: find_vertex_by_label!(second)
      )
    end
    add_edges! edges
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
    add_nodes!(nodes)
  end

  def add_edge!(edge)
    raise Math::Discrete::TypeError, 'edge must be of the type Math::Discrete::Graph::Edge' unless edge.is_a? Edge
    raise Math::Discrete::TypeError, 'edge already exists in graph' unless unique_edge? edge

    edge.set_graph! self
    edge.first.add_adjacent_vertex edge.second
    edge.second.add_adjacent_vertex edge.first

    @edges.add edge
  end

  def add_edges!(edges)
    edges.each { |edge| add_edge! edge }
  end

  def find_by_id!(id)
    result = @vertices.find { |vertex| vertex.id == id }

    raise VertexNotFound, "could not find a vertex with id=#{id}" if result.nil?

    result
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

  def find_edge_by_labels!()
    result = @edges.find { |edge| edge.label == label }

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

  def unique_vertex?(vertex)
    find_vertices_by_labels! vertex.label
  rescue VertexNotFound
    true
  end

  def unique_edge?(edge)
    find_edge_by_labels! *edge.labels.to_a
  rescue EdgeNotFound
    true
  end
end
