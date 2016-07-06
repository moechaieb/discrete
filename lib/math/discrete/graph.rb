class Math::Discrete::Graph
  class VertexNotFound < StandardError; end
  class VertexNotUnique < StandardError; end
  class EdgeNotFound < StandardError; end
  class EdgeNotUnique < StandardError; end
  class PropertyNotFound < StandardError; end

  attr_reader :vertex_set, :edge_set, :name, :property_set
  alias_method :node_set, :vertex_set

  def self.build
    new
  end

  def self.build_from_sets(vertex_set: Set[], edge_set: Set[])
    raise Math::Discrete::TypeError, 'vertex_set must be of type Set' unless vertex_set.is_a? Set
    raise Math::Discrete::TypeError, 'edge_set must be of type Set' unless edge_set.is_a? Set

    graph = new

    graph.add_vertices! vertex_set
    graph.add_edges! edge_set

    graph
  end

  def self.build_from_labels(vertex_labels: Set[], edge_labels: Set[])
    raise Math::Discrete::TypeError, 'vertex_labels must be of type Set' unless vertex_labels.is_a? Set
    raise Math::Discrete::TypeError, 'edge_labels must be of type Set' unless edge_labels.is_a? Set

    vertices = vertex_labels.map { |label| Vertex.build_from_label label }

    edges = edge_labels.map do |label_set|
      from = vertices.find { |vertex| vertex.label == label_set.first }
      to = vertices.find { |vertex| vertex.label == label_set.to_a.last }

      raise VertexNotFound, "could not find a vertex with label=#{label_set.first}" if from.nil?
      raise VertexNotFound, "could not find a vertex with label=#{label_set.to_a.last}" if to.nil?

      Edge.new from: from, to: to
    end

    build_from_sets vertex_set: Set[*vertices], edge_set: Set[*edges]
  end

  def add_vertex!(vertex)
    raise Math::Discrete::TypeError, 'vertex must be of the type Math::Discrete::Graph::Vertex' unless vertex.is_a? Vertex
    raise VertexNotUnique, 'vertex labels must be unique' unless unique_vertex? vertex

    clear_property_map!

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

    clear_property_map!

    @edge_set.add edge
  end

  def add_edges!(edges)
    edges.each { |edge| add_edge! edge }
  end

  def remove_vertex!(vertex)
    raise Math::Discrete::TypeError, 'vertex must be of the type Math::Discrete::Graph::Vertex' unless vertex.is_a? Vertex

    find_vertex_by_label! vertex.label
    clear_property_map!

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

    find_edge_by_labels! *edge.labels
    clear_property_map!

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

        edge.from == from && edge.to == to
      end
    rescue VertexNotFound
      raise EdgeNotFound, "could not find a edge with labels=(#{from_label},#{to_label})"
    end

    raise EdgeNotFound, "could not find a edge with labels=(#{from_label},#{to_label})" if result.nil?

    result
  end

  def find_property_by_name!(name)
    result = @property_set.find { |property| property.name == name.to_sym }

    raise PropertyNotFound, "could not find property with name=#{name}" if result.nil?

    result
  end

  def vertex_labels
    Set[*@vertex_set.map(&:label)]
  end
  alias_method :node_labels, :vertex_labels

  def edge_labels
    Set[*@edge_set.map(&:labels)]
  end

  def satisfies_property?(name)
    return @property_map[name] unless @property_map[name].nil?

    find_property_by_name!(name).satisfied? self
  end

  private

  def initialize(vertex_set: Set[], edge_set: Set[], property_set: Properties::all)
    @vertex_set = vertex_set
    @edge_set = edge_set
    @property_set = property_set
    @property_map = {}
  end

  def unique_vertex?(vertex)
    find_vertex_by_label! vertex.label

    false
  rescue VertexNotFound
    true
  end

  def unique_edge?(edge)
    find_edge_by_labels! *edge.labels

    false
  rescue EdgeNotFound
    true
  end

  def build_property_map!
    @property_map = @property_set.map(&:name).reduce do |map, property_name|
      map.merge property_name => satisfies_property?(property_name)
    end
  end

  def clear_property_map!
    @property_map = {}
  end
end
