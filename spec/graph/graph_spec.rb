require 'spec_helper'

describe Math::Discrete::Graph do
  let(:directed_graph) { Graph.build }
  let(:undirected_graph) { Graph.build directed: false }
  let(:labels) { Set['A', 'B'] }

  describe '::build, ::build directed: true' do
    it 'creates a directed graph with an empty vertex set and edge set' do
      expect(directed_graph.vertex_set).to be_empty
      expect(directed_graph.edge_set).to be_empty
      expect(directed_graph).to be_directed
    end
  end

  describe '::build directed: false' do
    it 'creates an undirected graph with an empty vertex set and edge set' do
      expect(undirected_graph.vertex_set).to be_empty
      expect(undirected_graph.edge_set).to be_empty
      expect(undirected_graph).not_to be_directed
    end
  end

  describe '::build_from_sets' do
    let(:vertex_set) { Graph::Vertex.build_from_labels 'A', 'B', 'C' }
    let(:directed_edge_set) do
      Set[
        Edge::Directed.build(from: vertex_set.entries[0], to: vertex_set.entries[1]),
        Edge::Directed.build(from: vertex_set.entries[1], to: vertex_set.entries[0]),
        Edge::Directed.build(from: vertex_set.entries[1], to: vertex_set.entries[2]),
        Edge::Directed.build(from: vertex_set.entries[2], to: vertex_set.entries[1])
      ]
    end

    let(:undirected_edge_set) do
      Set[
        Edge::Undirected.build_between(vertex_set.entries[0], vertex_set.entries[1]),
        Edge::Undirected.build_between(vertex_set.entries[1], vertex_set.entries[2]),
      ]
    end

    let(:directed_graph) { Graph.build_from_sets vertex_set: vertex_set, edge_set: directed_edge_set }
    let(:undirected_graph) { Graph.build_from_sets vertex_set: vertex_set, edge_set: undirected_edge_set }

    it 'creates a graph from the given sets of vertices and edges' do
      expect(directed_graph).to be_a Graph
      expect(directed_graph).to be_directed
      expect(directed_graph.vertex_set).to eq vertex_set
      expect(directed_graph.edge_set).to eq directed_edge_set

      expect(undirected_graph).to be_a Graph
      expect(undirected_graph).not_to be_directed
      expect(undirected_graph.vertex_set).to eq vertex_set
      expect(undirected_graph.edge_set).to eq undirected_edge_set
    end

    it 'creates a directed or undirected graph based on the edge set' do
      expect(directed_edge_set).to all be_directed
      expect(directed_graph).to be_directed

      expect(undirected_edge_set).to all satisfy { |edge| !edge.directed? }
      expect(undirected_graph).not_to be_directed
    end
  end

  describe '::build_from_labels' do
    let(:vertex_labels) { Set['A', 'B', 'C', 'D'] }
    let(:edge_labels) { Set[*[%w(A D), %w(B D), %w(A C)].map(&:to_set)] }
    let(:directed_graph) { Graph.build_from_labels vertex_labels: vertex_labels, edge_labels: edge_labels }
    let(:undirected_graph) { Graph.build_from_labels directed: false, vertex_labels: vertex_labels, edge_labels: edge_labels }

    it 'creates a directed graph from the given sets of labels by default' do
      expect(directed_graph).to be_a Graph
      expect(directed_graph).to be_directed
      expect(directed_graph.vertex_labels).to eq vertex_labels
      expect(directed_graph.edge_labels).to eq edge_labels
      expect(directed_graph.edge_set).to all be_directed
    end

    it 'creates an undirected graph from the given sets of labels when passed directed: false' do
      expect(undirected_graph).to be_a Graph
      expect(undirected_graph).not_to be_directed
      expect(undirected_graph.vertex_labels).to eq vertex_labels
      expect(undirected_graph.edge_set).to all( satisfy { |edge| !edge.directed? })
      expect(undirected_graph.edge_labels).to eq edge_labels
    end
  end

  describe '#add_vertex!, #add_node!' do
    let(:graph) { Graph.build }
    let(:vertex) { Graph::Vertex.build_from_label 'A' }

    it 'adds the vertex to the vertex set' do
      expect { graph.add_vertex! vertex }.to change(graph.vertex_set, :count).by 1
      expect(graph.vertex_set).to include vertex
    end

    it 'raises a TypeError if the input is an object of a non-Vertex type' do
      expect { graph.add_vertex! 'This is not a vertex' }.to raise_error Math::Discrete::TypeError
    end

    it 'raises a VertexNotUnique if the vertex is already part of the vertex set' do
      graph.add_vertex! vertex

      expect { graph.add_vertex! vertex }.to raise_error Graph::VertexNotUnique
    end
  end

  describe '#add_vertices!, #add_nodes!' do
    let(:graph) { Graph.build }
    let(:vertices) { Graph::Vertex.build_from_labels *labels }

    it 'adds the vertices to the vertex set' do
      expect { graph.add_vertices! vertices }.to change(graph.vertex_set, :count).by 2
      expect(graph.vertex_set).to include *vertices
    end

    it 'raises a TypeError if the input includes an object of a non-Vertex type' do
      expect { graph.add_vertices!(vertices << 'This is not a vertex') }.to raise_error Math::Discrete::TypeError
    end

    it 'raises a VertexNotUnique if the input includes a vertex that is already part of the vertex set' do
      graph.add_vertex! vertices.first

      expect { graph.add_vertices! vertices }.to raise_error Graph::VertexNotUnique
    end
  end

  describe '#add_edge!' do
    let(:vertices) { Graph::Vertex.build_from_labels *labels }
    let(:directed_graph) { Graph.build_from_sets vertex_set: vertices }
    let(:undirected_graph) { Graph.build directed: false }
    let(:directed_edge) { Graph::Edge::Directed.build from: vertices.entries[0], to: vertices.entries[1] }
    let(:undirected_edge) { Graph::Edge::Undirected.build_between *vertices}

    it 'adds the edge to the edge set' do
      expect { directed_graph.add_edge! directed_edge }.to change(directed_graph.edge_set, :count).by 1
      expect(directed_graph.edge_set).to include directed_edge
    end

    it 'raises a TypeError if the input is an object of a non-Edge type' do
      expect { directed_graph.add_edge! 'This is not an edge' }.to raise_error Math::Discrete::TypeError
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
    let(:vertices) { Graph::Vertex.build_from_labels *labels }
    let(:directed_graph) { Graph.build_from_sets vertex_set: vertices }
    let(:undirected_graph) { Graph.build directed: false }
    let(:directed_edges) { Set[Graph::Edge::Directed.build from: vertices.entries[0], to: vertices.entries[1]] }
    let(:undirected_edges) { Set[Graph::Edge::Undirected.build_between *vertices] }

    it 'adds the edges to the edge set' do
      expect { directed_graph.add_edges! directed_edges }.to change(directed_graph.edge_set, :count).by 1
      expect(directed_graph.edge_set).to include *directed_edges
    end

    it 'raises a TypeError if the input includes an object of a non-Edge type' do
      expect { directed_graph.add_edges!(directed_edges << 'This is not an edge') }.to raise_error Math::Discrete::TypeError
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
    let(:vertices) { Graph::Vertex.build_from_labels *labels }
    let(:vertex) { vertices.first }
    let(:edge) { Graph::Edge::Undirected.build_between *vertices }
    let(:edges) { Set[edge] }
    let(:graph) { Graph.build_from_sets vertex_set: vertices, edge_set: edges }

    it 'removes the vertex from the vertex set' do
      expect { graph.remove_vertex! vertex }.to change(graph.vertex_set, :count).by -1
      expect(graph.vertex_set).not_to include vertex
    end

    it 'removes the edges incident to the vertex from the edge set' do
      expect { graph.remove_vertex! vertex }.to change(graph.edge_set, :count).by -1
      expect(graph.edge_set).not_to include edge
    end

    it 'raises a TypeError if the input is an object of non-Vertex type' do
      expect { graph.remove_vertex! 'This is not a vertex' }.to raise_error Math::Discrete::TypeError
    end

    it 'raises a VertexNotFound if the input is a vertex that is not part of the vertex set' do
      foreign_vertex = Graph::Vertex.build_from_label 'Z'

      expect { graph.remove_vertex! foreign_vertex }.to raise_error Graph::VertexNotFound
    end
  end

  describe '#remove_vertices!, #remove_nodes!' do
    let(:vertices) { Graph::Vertex.build_from_labels *labels }
    let(:vertex) { vertices.first }
    let(:edge) { Graph::Edge::Undirected.build_between *vertices }
    let(:edges) { Set[edge] }
    let(:graph) { Graph.build_from_sets vertex_set: vertices, edge_set: edges }

    it 'removes the vertices from the vertex set' do
      expect { graph.remove_vertices! vertices }.to change(graph.vertex_set, :count).by -2
      expect(graph.vertex_set).not_to include *vertices
    end

    it 'removes the edges incident to the vertices from the edge set' do
      expect { graph.remove_vertices! vertices }.to change(graph.edge_set, :count).by -1
      expect(graph.edge_set).not_to include edge
    end

    it 'raises a TypeError if the input is an object of non-Vertex type' do
      expect { graph.remove_vertices! %w(This is not a vertex) }.to raise_error Math::Discrete::TypeError
    end

    it 'raises a VertexNotFound if the input is a vertex that is not part of the vertex set' do
      foreign_vertex = Graph::Vertex.build_from_label 'Z'

      expect { graph.remove_vertices! vertices.add(foreign_vertex) }.to raise_error Graph::VertexNotFound
    end
  end

  describe '#remove_edge' do
    let(:vertices) { Graph::Vertex.build_from_labels *labels }
    let(:edge) { Graph::Edge::Directed.build from: vertices.entries[0], to: vertices.entries[1] }
    let(:edges) { Set[edge] }
    let(:graph) { Graph.build_from_sets vertex_set: vertices, edge_set: edges }

    it 'removes the edge from the edge set' do
      expect { graph.remove_edge! edge }.to change(graph.edge_set, :count).by -1
      expect(graph.edge_set).not_to include edge
    end

    it 'raises a TypeError if the input is an object of non-Edge type' do
      expect { graph.remove_edge! 'This is not a vertex' }.to raise_error Math::Discrete::TypeError
    end

    it 'raises an EdgeNotFound if the input is an edge that is not part of the edge set' do
      foreign_edge = Graph::Edge::Undirected.build_between *vertices

      expect { graph.remove_edge! foreign_edge }.to raise_error Graph::EdgeNotFound
    end
  end

  describe '#remove_edges' do
    let(:vertices) { Graph::Vertex.build_from_labels *labels }
    let(:edge) { Graph::Edge::Directed.build from: vertices.entries[0], to: vertices.entries[1] }
    let(:edges) { Set[edge] }
    let(:graph) { Graph.build_from_sets vertex_set: vertices, edge_set: edges }

    it 'removes the edge from the edge set' do
      expect { graph.remove_edges! edges }.to change(graph.edge_set, :count).by -1
      expect(graph.edge_set).not_to include *edge
    end

    it 'raises a TypeError if the input includes an an object of non-Edge type' do
      expect { graph.remove_edges! %w(This is not an edge) }.to raise_error Math::Discrete::TypeError
    end

    it 'raises an EdgeNotFound if the input includes an edge that is not part of the edge set' do
      foreign_edge = Graph::Edge::Undirected.build_between *vertices

      expect { graph.remove_edges! [foreign_edge] }.to raise_error Graph::EdgeNotFound
    end
  end

  describe '#find_vertex_by_label!' do
    let(:vertices) { Graph::Vertex.build_from_labels 'A' }
    let(:graph) { Graph.build_from_sets vertex_set: vertices }
    let(:result) { graph.find_vertex_by_label! 'A' }

    it 'returns the vertex with the given label in the vertex set' do
      expect(result).to be_a Vertex
      expect(result.label).to eq 'A'
    end

    it 'raises VertexNotFound if the vertex set does not include a vertex with the given label' do
      expect { graph.find_vertex_by_label! 'Z' }.to raise_error Graph::VertexNotFound
    end
  end

  describe '#find_vertices_by_labels!' do
    let(:vertices) { Graph::Vertex.build_from_labels *labels }
    let(:graph) { Graph.build_from_sets vertex_set: vertices}
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
    let(:vertices) { Graph::Vertex.build_from_labels *labels }
    let(:directed_edge) { Graph::Edge::Directed.build from: vertices.entries[0], to: vertices.entries[1] }
    let(:directed_edges) { Set[directed_edge] }
    let(:undirected_edge) { Graph::Edge::Undirected.build_between *vertices }
    let(:undirected_edges) { Set[undirected_edge] }
    let(:directed_graph) { Graph.build_from_sets vertex_set: vertices, edge_set: directed_edges }
    let(:undirected_graph) { Graph.build_from_sets vertex_set: vertices, edge_set: undirected_edges }
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
    let(:vertices) { Graph::Vertex.build_from_labels 'A', 'B' }
    let(:graph) { Graph.build_from_sets vertex_set: vertices }

    it 'returns a set of all the vertex labels' do
      expect(graph.vertex_labels).to contain_exactly 'A', 'B'
    end
  end

  describe '#satisfies_property?' do
    let(:property) { Graph::Properties.all.sample }
    it 'caches results of previous queries' do
      expect(property).to receive(:satisfied?).once

      undirected_graph.satisfies? property

      expect(undirected_graph.properties).not_to be_empty
      expect(undirected_graph.properties).to include property.name
    end

    it 'returns the cached value when possible' do
      result = undirected_graph.satisfies? property

      expect(property).to receive(:satisfied?).never

      expect(undirected_graph.satisfies? property).to be result
    end
  end

  describe '#determine_properties!' do
    it 'checks whether properties in Graph::Properties.all are verified by default' do
      undirected_graph.determine_properties!

      expect(undirected_graph.properties).to include *Graph::Properties.all.map(&:name)
    end

    it 'checks whether the given properties are verified' do
      properties = Graph::Properties.all.sample 2

      undirected_graph.determine_properties! properties

      expect(undirected_graph.properties).to include *properties.map(&:name)
    end
  end

  describe '#weighted?' do
    let(:graph) { Graph.build_from_labels vertex_labels: labels, edge_labels: Set[labels]}

    it 'returns true if the graph has weighted edges' do
      graph.edge_set.first.weight = 5

      expect(graph).to be_weighted
    end

    it 'returns false if the graph has no weighted edges' do
      expect(graph).not_to be_weighted
    end

    it 'returns false if the graph has no edges' do
      expect(directed_graph).not_to be_weighted
      expect(undirected_graph).not_to be_weighted
    end
  end
end
