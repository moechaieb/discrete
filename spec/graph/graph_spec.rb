require 'spec_helper'

describe Math::Discrete::Graph do
  let(:labels) { [1, 2] }

  describe '::[]' do
    let(:vertex_set) { Vertex::Set['A', 'B', 'C'] }
    let(:directed_edge_set) do
      Edge::Set::Directed[
        [vertex_set.entries[0], vertex_set.entries[1]],
        [vertex_set.entries[1], vertex_set.entries[0]],
        [vertex_set.entries[1], vertex_set.entries[2]],
        [vertex_set.entries[2], vertex_set.entries[1]]
      ]
    end
    let(:undirected_edge_set) do
      Edge::Set::Undirected[
        [vertex_set.entries[0], vertex_set.entries[1]],
        [vertex_set.entries[1], vertex_set.entries[2]],
      ]
    end
    let(:directed_graph_from_sets) { Graph[vertex_set, directed_edge_set] }
    let(:undirected_graph_from_sets) { Graph[vertex_set, undirected_edge_set] }
    let(:graph_from_labels) { Graph[[1, 2, 3], [[1, 2], [2, 3], [3, 1], [1, 3]]] }

    it 'raises a TypeError if the given vertex set or label set is not a Set or an Array' do
      expect { Graph['vertices', []] }.to raise_error TypeError
    end

    it 'raises a TypeError if the given edge set or label set is not a Set or an Array' do
      expect { Graph[[], 'edges'] }.to raise_error TypeError
    end

    it 'builds a graph from the given vertex set and edge set' do
      expect(directed_graph_from_sets).to be_a Graph
      expect(directed_graph_from_sets.vertex_set).to eq vertex_set
      expect(directed_graph_from_sets.edge_set).to eq directed_edge_set
    end

    it 'builds a directed graph from the given vertex label set and edge label set' do
      expect(graph_from_labels).to be_a Graph
      expect(graph_from_labels).to be_directed
      expect(graph_from_labels.vertex_labels).to contain_exactly 1, 2, 3
    end

    it 'builds a directed or undirected graph based on the edge set' do
      expect(directed_edge_set).to all be_directed
      expect(directed_graph_from_sets).to be_directed

      expect(undirected_edge_set).to all satisfy { |edge| !edge.directed? }
      expect(undirected_graph_from_sets).not_to be_directed
    end
  end

  describe '#add_vertex!, #add_node!' do
    let(:graph) { Graph[] }
    let(:vertex) { Vertex['A'] }

    it 'adds the vertex to the vertex set' do
      graph.add_vertex! vertex
      expect(graph.vertex_set).to include vertex
    end

    it 'raises a TypeError if the input is an object of a non-Vertex type' do
      expect { graph.add_vertex! 'This is not a vertex' }.to raise_error TypeError
    end

    it 'raises a VertexNotUnique if the vertex is already part of the vertex set' do
      graph.add_vertex! vertex

      expect { graph.add_vertex! vertex }.to raise_error Graph::VertexNotUnique
    end
  end

  describe '#add_vertices!, #add_nodes!' do
    let(:graph) { Graph[] }
    let(:vertices) { Vertex::Set[*labels] }

    it 'adds the vertices to the vertex set' do
      graph.add_vertices! vertices
      expect(graph.vertex_set).to include *vertices
    end

    it 'raises a TypeError if the input includes an object of a non-Vertex type' do
      expect { graph.add_vertices!(vertices << 'This is not a vertex') }.to raise_error TypeError
    end

    it 'raises a VertexNotUnique if the input includes a vertex that is already part of the vertex set' do
      graph.add_vertex! vertices.first

      expect { graph.add_vertices! vertices }.to raise_error Graph::VertexNotUnique
    end
  end

  describe '#add_edge!' do
    let(:vertices) { Vertex::Set[*labels] }
    let(:directed_graph) { Graph[vertices, []] }
    let(:undirected_graph) { Graph.build directed: false }
    let(:directed_edge) { Edge::Directed[*vertices] }
    let(:undirected_edge) { Edge::Undirected[*vertices] }

    it 'adds the edge to the edge set' do
      directed_graph.add_edge! directed_edge
      expect(directed_graph.edge_set).to include directed_edge
    end

    it 'raises a TypeError if the input is an object of a non-Edge type' do
      expect { directed_graph.add_edge! 'This is not an edge' }.to raise_error TypeError
    end

    it 'raises a EdgeNotUnique if the edge is already part of the edge set' do
      directed_graph.add_edge! directed_edge

      expect { directed_graph.add_edge! directed_edge }.to raise_error Graph::EdgeNotUnique
    end

    it 'raises a BadEdgeType if the edge is directed and the graph is undirected' do
      expect { undirected_graph.add_edge! directed_edge }.to raise_error Graph::BadEdgeType
    end

    it 'raises a BadEdgeType if the edge is undirected and the graph is directed' do
      expect { directed_graph.add_edge! undirected_edge }.to raise_error Graph::BadEdgeType
    end
  end

  describe '#add_edges!' do
    let(:vertices) { Vertex::Set[*labels] }
    let(:directed_graph) { Graph[vertices] }
    let(:undirected_graph) { Graph.build directed: false }
    let(:directed_edges) { Edge::Set::Directed[[*vertices]] }
    let(:undirected_edges) { Edge::Set::Undirected[[*vertices]] }

    it 'adds the edges to the edge set' do
      directed_graph.add_edges! directed_edges
      expect(directed_graph.edge_set).to include *directed_edges
    end

    it 'raises a TypeError if the input includes an object of a non-Edge type' do
      expect { directed_graph.add_edges!(directed_edges << 'This is not an edge') }.to raise_error TypeError
    end

    it 'raises a EdgeNotUnique if the input includes an edge that is already part of the edge set' do
      directed_graph.add_edge! directed_edges.first

      expect { directed_graph.add_edges! directed_edges }.to raise_error Graph::EdgeNotUnique
    end

    it 'raises a BadEdgeType if the edge is directed and the graph is undirected' do
      expect { undirected_graph.add_edges! directed_edges }.to raise_error Graph::BadEdgeType
    end

    it 'raises a BadEdgeType if the edge is undirected and the graph is directed' do
      expect { directed_graph.add_edges! undirected_edges }.to raise_error Graph::BadEdgeType
    end
  end

  describe '#remove_vertex!, #remove_node!' do
    let(:vertices) { Vertex::Set[*labels] }
    let(:vertex) { vertices.first }
    let(:edges) { Edge::Set::Undirected[[*vertices]] }
    let(:edge) { edges.first }
    let(:graph) { Graph[vertices, edges] }

    it 'removes the vertex from the vertex set' do
      graph.remove_vertex! vertex
      expect(graph.vertex_set).not_to include vertex
    end

    it 'removes the edges incident to the vertex from the edge set' do
      graph.remove_vertex! vertex
      expect(graph.edge_set).not_to include edge
    end

    it 'raises a TypeError if the input is an object of non-Vertex type' do
      expect { graph.remove_vertex! 'This is not a vertex' }.to raise_error TypeError
    end

    it 'raises a VertexNotFound if the input is a vertex that is not part of the vertex set' do
      foreign_vertex = Vertex['Z']

      expect { graph.remove_vertex! foreign_vertex }.to raise_error Graph::VertexNotFound
    end
  end

  describe '#remove_vertices!, #remove_nodes!' do
    let(:vertices) { Vertex::Set[*labels] }
    let(:vertex) { vertices.first }
    let(:edges) { Edge::Set::Undirected[[*vertices]] }
    let(:edge) { edges.first }
    let(:graph) { Graph[vertices, edges] }

    it 'removes the vertices from the vertex set' do
      graph.remove_vertices! vertices
      expect(graph.vertex_set).not_to include *vertices
    end

    it 'removes the edges incident to the vertices from the edge set' do
      graph.remove_vertices! vertices
      expect(graph.edge_set).not_to include edge
    end

    it 'raises a TypeError if the input is an object of non-Vertex type' do
      expect { graph.remove_vertices! %w(This is not a vertex) }.to raise_error TypeError
    end

    it 'raises a VertexNotFound if the input is a vertex that is not part of the vertex set' do
      foreign_vertex = Vertex['Z']

      expect { graph.remove_vertices! vertices.add(foreign_vertex) }.to raise_error Graph::VertexNotFound
    end
  end

  describe '#remove_edge!' do
    let(:vertices) { Vertex::Set[*labels] }
    let(:edges) { Edge::Set::Undirected[[*vertices]] }
    let(:edge) { edges.first }
    let(:graph) { Graph[vertices, edges] }

    it 'removes the edge from the edge set' do
      graph.remove_edge! edge
      expect(graph.edge_set).not_to include edge
    end

    it 'raises a TypeError if the input is an object of non-Edge type' do
      expect { graph.remove_edge! 'This is not a vertex' }.to raise_error TypeError
    end

    it 'raises an EdgeNotFound if the input is an edge that is not part of the edge set' do
      foreign_edge = Edge::Undirected[*vertices]

      expect { graph.remove_edge! foreign_edge }.to raise_error Graph::EdgeNotFound
    end
  end

  describe '#remove_edges!' do
    let(:vertices) { Vertex::Set[*labels] }
    let(:edges) { Edge::Set::Undirected[[*vertices]] }
    let(:edge) { edges.first }
    let(:graph) { Graph[vertices, edges] }

    it 'removes the edge from the edge set' do
      graph.remove_edges! edges
      expect(graph.edge_set).not_to include *edge
    end

    it 'raises a TypeError if the input includes an an object of non-Edge type' do
      expect { graph.remove_edges! %w(This is not an edge) }.to raise_error TypeError
    end

    it 'raises an EdgeNotFound if the input includes an edge that is not part of the edge set' do
      foreign_edge = Edge::Undirected[*vertices]

      expect { graph.remove_edges! [foreign_edge] }.to raise_error Graph::EdgeNotFound
    end
  end

  describe '#find_vertex_by_label!' do
    let(:vertex) { Vertex[1] }
    let(:graph) { Graph[[vertex], []] }

    it 'returns the vertex with the given label in the vertex set' do
      result = graph.find_vertex_by_label! 1

      expect(result).to be_a Vertex
      expect(result.label).to eq 1
    end

    it 'raises VertexNotFound if the vertex set does not include a vertex with the given label' do
      expect { graph.find_vertex_by_label! 'Z' }.to raise_error Graph::VertexNotFound
    end
  end

  describe '#find_vertices_by_labels!' do
    let(:vertices) { Vertex::Set[*labels] }
    let(:graph) { Graph[vertices, []]}
    let(:result) { graph.find_vertices_by_labels! *labels }

    it 'returns the vertices with the given labels in the vertex set' do
      expect(result).to be_a Set
      expect(result).to all be_a Vertex
      expect(result.size).to be 2
      expect(result.map &:label).to contain_exactly *labels
    end

    it 'raises VertexNotFound if the vertex set does not include a vertex with one of the given labels' do
      expect { graph.find_vertices_by_labels! 'C', 'D' }.to raise_error Graph::VertexNotFound
    end
  end

  describe '#find_edge_by_labels!' do
    let(:vertices) { Vertex::Set[*labels] }
    let(:directed_edges) { Edge::Set::Directed[[*vertices]] }
    let(:directed_edge) { directed_edges.first }
    let(:undirected_edges) { Edge::Set::Undirected[[*vertices]] }
    let(:undirected_edge) { undirected_edges.first }
    let(:directed_graph) { Graph[vertices, directed_edges] }
    let(:undirected_graph) { Graph[vertices, undirected_edges] }
    let(:directed_result) { directed_graph.find_edge_by_labels! *labels }
    let(:undirected_result) { undirected_graph.find_edge_by_labels! *labels.entries.reverse }

    it 'returns the directed edge with the given labels in order in the edge set' do
      expect(directed_result).to be_a Edge
      expect(directed_result).to be_directed
      expect(directed_result.labels).to contain_exactly *labels
    end

    it 'returns the undirected edge with the given labels regardless of order in the edge set' do
      expect(undirected_edge).to be_a Edge
      expect(undirected_edge).not_to be_directed
      expect(undirected_result.labels).to contain_exactly *labels
    end

    it 'raises EdgeNotFound if the edge set does not include an edge with the given labels' do
      expect { directed_graph.find_edge_by_labels! 'X', 'Y' }.to raise_error Graph::EdgeNotFound
      expect { undirected_graph.find_edge_by_labels! 'X', 'Y' }.to raise_error Graph::EdgeNotFound
    end
  end

  describe '#vertex_labels' do
    let(:vertices) { Vertex::Set[*labels] }
    let(:graph) { Graph[vertices, []] }

    it 'returns a set of all the vertex labels' do
      expect(graph.vertex_labels).to contain_exactly *labels
    end
  end

  describe '#satisfies_property?' do
    let(:property) { Graph::Properties.all.sample }
    let(:graph) { Graph[] }

    it 'caches results of previous queries' do
      expect(property).to receive(:satisfied?).once

      graph.satisfies? property

      expect(graph.properties).not_to be_empty
      expect(graph.properties).to include property.name
    end

    it 'returns the cached value when possible' do
      result = graph.satisfies? property

      expect(property).to receive(:satisfied?).never

      expect(graph.satisfies? property).to be result
    end
  end

  describe '#determine_properties!' do
    let(:graph) { Graph[] }

    it 'checks whether properties in Graph::Properties.all are verified by default' do
      graph.determine_properties!

      expect(graph.properties).to include *Graph::Properties.all.map(&:name)
    end

    it 'checks whether the given properties are verified' do
      properties = Graph::Properties.all.sample 2

      graph.determine_properties! properties

      expect(graph.properties).to include *properties.map(&:name)
    end
  end

  describe '#weighted?' do
    let(:graph) { Graph[labels, [labels]]}
    let(:empty_graph) { Graph[] }

    it 'returns true if the graph has weighted edges' do
      graph.edge_set.first.weight = 5

      expect(graph).to be_weighted
    end

    it 'returns false if the graph has no weighted edges' do
      expect(graph).not_to be_weighted
    end

    it 'returns false if the graph has no edges' do
      expect(empty_graph).not_to be_weighted
    end
  end
end
