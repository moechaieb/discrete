module Math::Discrete::Graph::Properties
  class << self
    def all
      Set[bipartite].freeze
    end

    def bipartite
      Math::Discrete::Property.build name: :bipartite, structure_class: Math::Discrete::Graph do |graph|
        false
      end
    end

    def complete
      Math::Discrete::Property.build name: :complete, structure_class: Math::Discrete::Graph do |graph|
        false
      end
    end

    def planar
      Math::Discrete::Property.build name: :planar, structure_class: Math::Discrete::Graph do |graph|
        false
      end
    end
  end
end
