require 'algorithms'

module Math::Discrete::Graph::Algorithms
  class NegativeWeightCycleError < StandardError; end

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

  def shortest_path_between(source, target)
    raise TypeError, 'source and target vertices must be of type Vertex' unless source.is_a?(Vertex) && target.is_a?(Vertex)
    raise Graph::VertexNotFound, "could not find vertex with label=#{source.label}" unless vertex_labels.include? source.label
    raise Graph::VertexNotFound, "could not find vertex with label=#{target.label}" unless vertex_labels.include? target.label

    return Graph::Path[] if source == target

    distance_tree = if @edge_set.map(&:weight).all? { |weight| weight > 0 }
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

  private

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

  def bellman_fords_algorithm(source, target)
    distance_tree = { source.label => { distance: 0, parent: nil } }

    vertex_set.each do |vertex|
      unless vertex == source
        distance_tree[vertex.label] = { distance: Float::INFINITY, parent: nil }
      end
    end

    (vertex_set.size - 1).times do
      @edge_set.each do |edge|
        alt = distance_tree[edge.from.label][:distance] + edge.weight

        if alt < distance_tree[edge.to.label][:distance]
          distance_tree[edge.to.label] = { distance: alt, parent: edge.from.label }
        end
      end
    end

    @edge_set.each do |edge|
      if distance_tree[edge.from.label][:distance] + edge.weight < distance_tree[edge.to.label][:distance]
        raise NegativeWeightCycleError, 'the graph contains a negative-weight cycle'
      end
    end

    distance_tree
  end
end
