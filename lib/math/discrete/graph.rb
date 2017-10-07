class Math::Discrete::Graph < Math::Discrete::Structure
  class VertexNotFound < StandardError; end
  class VertexNotUnique < StandardError; end
  class EdgeNotFound < StandardError; end
  class EdgeNotUnique < StandardError; end

  include Algorithms

  # A bipartite graph (or bigraph) is a graph whose vertices can be divided into two disjoint and independent sets
  # U and V such that every edge connects a vertex in U to one in V.
  # Read more:
  # https://en.wikipedia.org/wiki/Bipartite_graph
  property :bipartiteness, adjective: :bipartite do |graph|
    n = graph.vertex_set.size
    m = graph.edge_set.size

    next false if m > (n * n) / 4

    bfs_tree = graph.breadth_first_search

    root_label = bfs_tree.empty? ? nil : bfs_tree.first[0]

    bfs_tree = bfs_tree.to_a.reverse.to_h

    super_parent = graph.vertex_set.find do |vertex|
      vertex.adjacent_vertices.map(&:label).include? root_label
    end

    bfs_tree[root_label][:parent] = super_parent.label unless super_parent.nil?

    bfs_tree.none? do |label, search_tree_data|
      next if search_tree_data[:parent].nil?

      bfs_tree[label][:color] = search_tree_data[:distance].odd? ? :blue : :red

      bfs_tree[label][:color] == bfs_tree[search_tree_data[:parent]][:color]
    end
  end

  # A complete graph is a graph in which every pair of distinct vertices is connected by a unique edge.
  # Read more:
  # https://en.wikipedia.org/wiki/Complete_graph
  property :completeness, adjective: :complete do |graph|
    n = graph.vertex_set.size
    m = graph.edge_set.size

    m == (n * (n - 1))
  end

  # A regular graph is a graph where each vertex has the same number of neighbors; i.e. every vertex has the same degree
  # Read more:
  # https://en.wikipedia.org/wiki/Regular_graph
  property :regularity, adjective: :regular do |graph|
    graph.vertex_set.map { |vertex| vertex.adjacent_vertices.size }.uniq.size == 1
  end

  property :weightedness, adjective: :weighted do |graph|
    distinct_weights = graph.edge_set.map(&:weight).uniq.size

    distinct_weights > 1
  end

  private_class_method :new
  def initialize(vertex_set: Set[], edge_set: Set[])
    @vertex_map = vertex_set.map { |v| [v.label, v] }.to_h
    @edge_map = edge_set.map { |e| [[e.from.label, e.to.label], e] }.to_h

    super
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

  class << self
    private

    def build_from_sets(vertex_set: Set[], edge_set: Set[])
      raise TypeError, 'vertex_set must be of type Set' unless vertex_set.is_a? Set
      raise TypeError, 'edge_set must be of type Set' unless edge_set.is_a? Set

      graph = new

      graph.send :add_vertices!, vertex_set
      graph.send :add_edges!, edge_set

      graph
    end

    def build_from_labels(vertex_labels: Set[], edge_labels: Set[])
      raise TypeError, 'vertex_labels must be of type Set' unless vertex_labels.is_a? Set
      raise TypeError, 'edge_labels must be of type Set' unless edge_labels.is_a? Set

      graph = new

      graph.send :add_vertices!, Vertex::Set[*vertex_labels]

      edge_labels.each do |label_set|
        from_label, to_label, weight = label_set.entries

        from = graph[from_label]
        raise VertexNotFound, "could not find a vertex with label=#{ from_label }" if from.nil?

        to = graph[to_label]
        raise VertexNotFound, "could not find a vertex with label=#{ to_label }" if to.nil?

        weight ||= 1
        raise TypeError, 'edge weight must be of a Numeric type' unless weight.is_a? Numeric

        graph.add_edge! Edge[from, to, weight]
      end

      graph
    end
  end

  def [](vertex_label, other_vertex_label = nil)
    return @vertex_map[vertex_label] if other_vertex_label.nil?

    @edge_map[[vertex_label, other_vertex_label]]
  end

  def <<(vertex_or_edge)
    case vertex_or_edge
    when Edge
      add_edge! vertex_or_edge
    when Vertex
      add_vertex! vertex_or_edge
    else
      raise TypeError, 'input must be of type Edge or Vertex'
    end
  end

  def vertex_set
    @vertex_map.values.to_set
  end
  alias_method :node_set, :vertex_set

  def edge_set
    @edge_map.values.to_set
  end

  def vertex_labels
    @vertex_map.keys.to_set
  end
  alias_method :node_labels, :vertex_labels

  def edge_labels
    edge_set.map(&:labels).to_set
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

    clear_properties!

    @edge_map[[edge.from.label, edge.to.label]] = edge
  end

  def add_edges!(edges)
    edges.each { |edge| add_edge! edge }
  end

  def remove_vertex!(vertex)
    raise TypeError, 'vertex must be of the type Math::Discrete::Graph::Vertex' unless vertex.is_a? Vertex

    find_vertex_by_label! vertex.label
    clear_properties!

    @edge_map.delete_if { |edge_key, _| edge_key.include? vertex.label }
    @vertex_map.delete vertex.label
  end
  alias_method :remove_node!, :remove_vertex!

  def remove_vertices!(vertices)
    vertices.each { |vertex| remove_vertex! vertex }
  end
  alias_method :remove_nodes!, :remove_vertices!

  def remove_edge!(edge)
    raise TypeError, 'edge must be of the type Math::Discrete::Graph::Edge' unless edge.is_a? Edge
    raise EdgeNotFound, "could not find a edge with labels=(#{ edge.from.label },#{ edge.to.label })" unless edge_set.include? edge

    clear_properties!

    @edge_map.delete [edge.from.label, edge.to.label]
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
    result = @edge_map[[from_label, to_label]]

    raise EdgeNotFound, "could not find a edge with labels=(#{ from_label },#{ to_label })" if result.nil?

    result
  end

  private

  def unique_vertex?(vertex)
    @vertex_map[vertex.label].nil?
  end

  def unique_edge?(edge)
    @edge_map[[edge.from.label, edge.to.label]].nil?
  end
end
