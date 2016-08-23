require 'algorithms'
require 'union_find'

module Math::Discrete::Graph::Algorithms
  class NegativeWeightCycleError < StandardError; end

  # Breadth-first search (BFS) is an algorithm for traversing a graph
  # It starts at the givenroot and explores the neighbor nodes first, before moving to the next level neighbours.
  # Read more:
  # https://en.wikipedia.org/wiki/Breadth-first_search
  def breadth_first_search(root: vertex_set.first)
    return {} if @vertex_map.empty?

    raise TypeError, 'root must be of the type Math::Discrete::Graph::Vertex' unless root.is_a? Vertex
    raise Graph::VertexNotFound, "could not find vertex with label=#{root.label}" unless vertex_labels.include? root.label


    search_queue = Containers::Queue.new [root]
    search_tree = { root.label => { distance: 0, parent: nil } }

    until search_queue.empty?
      vertex = search_queue.pop

      vertex.adjacent_vertices.each do |child|
        if search_tree[child.label].nil?
          search_tree[child.label] = {
            distance: search_tree[vertex.label][:distance] + 1,
            parent: vertex.label
          }

          search_queue.push child
        end
      end
    end

    search_tree
  end

  # Depth-first search (DFS) is an algorithm for traversing a graph
  # It starts at the given root and explores as far as possible along each branch before backtracking.
  # Read more:
  # https://en.wikipedia.org/wiki/Depth-first_search
  def depth_first_search(root: vertex_set.first)
    return {} if @vertex_map.empty?

    raise TypeError, 'root must be of the type Math::Discrete::Graph::Vertex' unless root.is_a? Vertex
    raise Graph::VertexNotFound, "could not find vertex with label=#{root.label}" unless vertex_labels.include? root.label


    search_stack = Containers::Stack.new [root]
    search_tree = { root.label => { distance: 0, parent: nil } }

    until search_stack.empty?
      vertex = search_stack.pop

      vertex.adjacent_vertices.each do |child|
        if search_tree[child.label].nil?
          search_tree[child.label] = {
            distance: search_tree[vertex.label][:distance] + 1,
            parent: vertex.label
          }

          search_stack.push child
        end
      end
    end

    search_tree
  end

  # The shortest path finds a path between two vertices (or nodes) in the graph such that the sum of the weights of
  # its constituent edges is minimized.
  # Read more:
  # https://en.wikipedia.org/wiki/Shortest_path_problem
  def shortest_path_between(source, target)
    raise TypeError, 'source and target vertices must be of type Vertex' unless source.is_a?(Vertex) && target.is_a?(Vertex)
    raise Graph::VertexNotFound, "could not find vertex with label=#{source.label}" unless vertex_labels.include? source.label
    raise Graph::VertexNotFound, "could not find vertex with label=#{target.label}" unless vertex_labels.include? target.label

    return Graph::Path[] if source == target

    distance_tree = if edge_set.map(&:weight).all? { |weight| weight > 0 }
      dijkstras_algorithm(source, target)
    else
      bellman_fords_algorithm(source, target)
    end

    edges = []
    current_vertex = target.label
    until distance_tree[current_vertex][:parent].nil? do
      edges << find_edge_by_labels!(distance_tree[current_vertex][:parent], current_vertex)
      current_vertex = distance_tree[current_vertex][:parent]
    end

    Graph::Path[*edges.reverse]
  end

  # A minimum spanning tree (MST) is a subset of the edges of a connected, edge-weighted undirected graph that
  # connects all the vertices together, without any cycles and with the minimum possible total edge weight.
  # That is, it is a spanning tree whose sum of edge weights is as small as possible.
  # Read more:
  # https://en.wikipedia.org/wiki/Minimum_spanning_tree
  def minimum_spanning_tree
    minimum_edge_set = Set[]
    union_set = UnionFind::UnionFind.new vertex_set

    edge_set.sort_by(&:weight).each do |edge|
      unless union_set.connected?(edge.from, edge.to)
        minimum_edge_set.add edge

        union_set.union(edge.from, edge.to)
      end
    end

    Graph[vertex_set, minimum_edge_set]
  end

  def weakly_connected_components
    # Return a set of weakly connected components as Graph objects
    Set[]
  end

  def strongly_connected_components
    # Return a set of weakly connected components as Graph objects
    Set[]
  end

  def cycles
    # Return a set of cycles as Path objects
    Set[]
  end

  private

  # Dijkstra's algorithm is an algorithm for finding the shortest paths between nodes in a graph.
  # The graph must not have negative-weighted edges
  # Read more:
  # https://en.wikipedia.org/wiki/Dijkstra's_algorithm
  def dijkstras_algorithm(source, target)
    distance_tree = { source.label => { distance: 0, parent: nil } }
    priority_queue = Containers::PriorityQueue.new do |a,b|
      (distance_tree[a][:distance] <=> distance_tree[b][:distance]) == -1
    end

    vertex_set.each do |vertex|
      unless vertex == source
        distance_tree[vertex.label] = { distance: Float::INFINITY, parent: nil }
      end

      priority_queue.push vertex, vertex.label
    end

    until priority_queue.empty?
      vertex = priority_queue.pop

      vertex.adjacent_vertices.each do |neighbour|
        alt = distance_tree[vertex.label][:distance] + vertex.distance_to(neighbour)

        if alt < distance_tree[neighbour.label][:distance]
          distance_tree[neighbour.label] = { distance: alt, parent: vertex.label }
        end
      end
    end

    distance_tree
  end

  # The Bellman–Ford algorithm is an algorithm that computes shortest paths from a source vertex to all of the other
  # vertices in a weighted graph. It is slower than Dijkstra's algorithm for the same problem, but more versatile,
  # as it is capable of handling graphs in which some of the edge weights are negative numbers.
  # Read more:
  # https://en.wikipedia.org/wiki/Bellman–Ford_algorithm
  def bellman_fords_algorithm(source, target)
    distance_tree = { source.label => { distance: 0, parent: nil } }

    vertex_set.each do |vertex|
      unless vertex == source
        distance_tree[vertex.label] = { distance: Float::INFINITY, parent: nil }
      end
    end

    (vertex_set.size - 1).times do
      edge_set.each do |edge|
        alt = distance_tree[edge.from.label][:distance] + edge.weight

        if alt < distance_tree[edge.to.label][:distance]
          distance_tree[edge.to.label] = { distance: alt, parent: edge.from.label }
        end
      end
    end

    edge_set.each do |edge|
      if distance_tree[edge.from.label][:distance] + edge.weight < distance_tree[edge.to.label][:distance]
        raise NegativeWeightCycleError, 'the graph contains a negative-weight cycle'
      end
    end

    distance_tree
  end
end
