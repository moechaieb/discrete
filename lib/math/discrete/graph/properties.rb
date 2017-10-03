module Math::Discrete::Graph::Properties
  METHODS = %i(bipartiteness completeness regularity).freeze

  class << self
    def each
      all.each do |property|
        yield(property) if block_given?
      end
    end

    def map
      all.map do |property|
        yield(property) if block_given?
      end
    end

    def all
      [
        bipartiteness,
        completeness,
        regularity
      ]
    end

    # A bipartite graph (or bigraph) is a graph whose vertices can be divided into two disjoint and independent sets
    # U and V such that every edge connects a vertex in U to one in V.
    # Read more:
    # https://en.wikipedia.org/wiki/Bipartite_graph
    def bipartiteness
      Math::Discrete::Property.build name: :bipartiteness, adjective: :bipartite, structure_type: :graph do |graph|
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
    end

    # A complete graph is a graph in which every pair of distinct vertices is connected by a unique edge.
    # Read more:
    # https://en.wikipedia.org/wiki/Complete_graph
    def completeness
      Math::Discrete::Property.build name: :completeness, adjective: :complete, structure_type: :graph do |graph|
        n = graph.vertex_set.size
        m = graph.edge_set.size

        m == (n * (n - 1))
      end
    end

    # A regular graph is a graph where each vertex has the same number of neighbors; i.e. every vertex has the same degree
    # Read more:
    # https://en.wikipedia.org/wiki/Regular_graph
    def regularity
      Math::Discrete::Property.build name: :regularity, adjective: :regular, structure_type: :graph do |graph|
        graph.vertex_set.map { |vertex| vertex.adjacent_vertices.size }.uniq.size == 1
      end
    end
  end
end
