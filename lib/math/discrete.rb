require_relative 'discrete/version'
require 'set'

module Math::Discrete
  class Structure; end
  class Graph < Structure; end
end

require_relative 'discrete/property'
require_relative 'discrete/structure'
require_relative 'discrete/graph/algorithms'
require_relative 'discrete/graph/vertex'
require_relative 'discrete/graph/edge'
require_relative 'discrete/graph/path'
require_relative 'discrete/graph'

Structure = Math::Discrete::Structure
Graph = Math::Discrete::Graph
Vertex = Graph::Vertex
Node = Vertex
Edge = Graph::Edge
