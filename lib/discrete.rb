require 'set'

module Math::Discrete
  class TypeError < StandardError; end
end

require 'math/discrete/version'
require 'math/discrete/graph'
require 'math/discrete/graph/vertex'
require 'math/discrete/graph/edge'

Graph = Math::Discrete::Graph
Vertex = Graph::Vertex
Edge = Graph::Edge
