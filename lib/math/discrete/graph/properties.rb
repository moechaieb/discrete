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
      Math::Discrete::Property.build name: :bipartiteness, structure_type: :graph do |graph|
        false
      end
    end

    def completeness
      Math::Discrete::Property.build name: :completeness, structure_type: :graph do |graph|
        n = graph.vertex_set.size
        m = graph.edge_set.size

        m == (n * (n - 1)) / (graph.directed? ? 1 : 2)
      end
    end

    def planarity
      Math::Discrete::Property.build name: :planarity, structure_type: :graph do |graph|
        false
      end
    end

    def regularity
      Math::Discrete::Property.build name: :regularity, structure_type: :graph do |graph|
        vertices = graph.vertex_set

        vertices.map { |vertex| vertex.adjacent_vertices.size }.uniq.size == 1
      end
    end
  end
end
