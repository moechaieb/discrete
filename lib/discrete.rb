require 'set'


module Math::Discrete
  class TypeError < StandardError; end

  class Graph; end
  module Graph::Predicates; end
end

require 'math/discrete/version'
require 'math/discrete/property'
require 'math/discrete/graph/properties'
require 'math/discrete/graph/algorithms'
require 'math/discrete/graph'
require 'math/discrete/graph/predicates'
require 'math/discrete/graph/vertex'
require 'math/discrete/graph/edge'
require 'math/discrete/graph/path'

Graph = Math::Discrete::Graph
Vertex = Graph::Vertex
Node = Vertex
Edge = Graph::Edge
