module Math::Discrete::Graph::Properties
  class << self
    def all
      [
        bipartiteness,
        completeness,
        planarity,
        regularity
      ]
    end

    def bipartiteness
      Math::Discrete::Property.build name: :bipartiteness, adjective: :bipartite, structure_type: :graph do |graph|
        n = graph.vertex_set.size
        m = graph.edge_set.size

        next false if m > (n * n) / 4

        bfs_tree = graph.breadth_first_search

        root_label = bfs_tree.empty? ? nil : bfs_tree.first[0]

        super_parent = graph.vertex_set.find do |vertex|
          vertex.adjacent_vertices.map(&:label).include? root_label
        end

        bfs_tree[root_label][:parent] = super_parent.label unless super_parent.nil?

        bfs_tree.each do |label, search_tree_data|
          bfs_tree[label][:color] = search_tree_data[:distance].odd? ? :blue : :red
        end

        bfs_tree.none? do |label, search_tree_data|
          next if search_tree_data[:parent].nil?

          bfs_tree[label][:color] == bfs_tree[search_tree_data[:parent]][:color]
        end
      end
    end

    def completeness
      Math::Discrete::Property.build name: :completeness, adjective: :complete, structure_type: :graph do |graph|
        n = graph.vertex_set.size
        m = graph.edge_set.size

        m == (n * (n - 1)) / (graph.directed? ? 1 : 2)
      end
    end

    def planarity
      Math::Discrete::Property.build name: :planarity, adjective: :planar, structure_type: :graph do |graph|
        false
      end
    end

    def regularity
      Math::Discrete::Property.build name: :regularity, adjective: :regular, structure_type: :graph do |graph|
        graph.vertex_set.map { |vertex| vertex.adjacent_vertices.size }.uniq.size == 1
      end
    end
  end
end
