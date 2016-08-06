require 'set'


module Math::Discrete
  class TypeError < StandardError; end

  class Property; end

  class Graph; end
  module Graph::Properties; end
  module Graph::Predicates; end
  module Graph::Algorithms; end
  class Graph::Vertex; end
  class Graph::Edge; end
end

require 'math/discrete/version'
require 'math/discrete/property'
require 'math/discrete/graph/properties'
require 'math/discrete/graph/algorithms'
require 'math/discrete/graph'
require 'math/discrete/graph/predicates'
require 'math/discrete/graph/vertex'
require 'math/discrete/graph/edge'


Graph = Math::Discrete::Graph
Vertex = Graph::Vertex
Node = Vertex
Edge = Graph::Edge
