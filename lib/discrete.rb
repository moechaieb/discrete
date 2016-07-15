require 'set'

module Math::Discrete
  class TypeError < StandardError; end

  class Graph; end
  class Graph::Vertex; end
  class Graph::Edge; end
  module Graph::Properties; end
  module Graph::Algorithms; end
end

require 'math/discrete/version'
require 'math/discrete/graph'
require 'math/discrete/graph/vertex'
require 'math/discrete/graph/edge'
require 'math/discrete/graph/properties'
require 'math/discrete/graph/algorithms'
require 'math/discrete/property'

Graph = Math::Discrete::Graph
Vertex = Graph::Vertex
Node = Vertex
Edge = Graph::Edge
