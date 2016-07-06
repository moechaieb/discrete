require 'spec_helper'

describe Math::Discrete::Graph do
  let(:graph) { Math::Discrete::Graph.build }
  let(:labels) { Set['A', 'B'] }

  describe '::build' do
    it 'creates agraph with an empty vertex set and edge set' do
      expect(graph.vertex_set).to be_empty
      expect(graph.edge_set).to be_empty
    end
  end

  describe '::build_from_sets' do
    let(:vertex_set) { Math::Discrete::Graph::Vertex.build_from_labels 'A', 'B', 'C' }
    let(:edge_set) do
      [
        Edge.build_from_vertices(vertex_set.to_a[0], vertex_set.to_a[1]),
        Edge.build_from_vertices(vertex_set.to_a[1], vertex_set.to_a[0]),
        Edge.build_from_vertices(vertex_set.to_a[1], vertex_set.to_a[2]),
        Edge.build_from_vertices(vertex_set.to_a[2], vertex_set.to_a[1])
      ].to_set
    end
    let(:graph) { Math::Discrete::Graph.build_from_sets vertex_set: vertex_set, edge_set: edge_set }

    it 'creates a graph from the given sets of vertices and edges' do
      expect(graph).to be_a Math::Discrete::Graph
      expect(graph.vertex_set).to eq vertex_set
      expect(graph.edge_set).to eq edge_set
    end
  end

  describe '::build_from_labels' do
    let(:vertex_labels) { Set['A', 'B', 'C', 'D'] }
    let(:edge_labels) { Set[*[%w(A D), %w(B D), %w(A C)].map(&:to_set)] }
    let(:graph) { Math::Discrete::Graph.build_from_labels vertex_labels: vertex_labels, edge_labels: edge_labels }

    it 'creates a graph from the given sets of labels' do
      expect(graph).to be_a Math::Discrete::Graph
      expect(graph.vertex_labels).to eq vertex_labels
      expect(graph.edge_labels).to eq edge_labels
    end
  end

  describe '#add_vertex!, #add_node!' do
    let(:vertex) { Math::Discrete::Graph::Vertex.build_from_label 'A' }

    it 'adds the vertex to the vertex set' do
      expect { graph.add_vertex! vertex }.to change(graph.vertex_set, :count).by 1
      expect(graph.vertex_set).to include vertex
    end

    it 'raises a TypeError if the input is an object of a non-Vertex type' do
      expect { graph.add_vertex! 'This is not a vertex' }.to raise_error Math::Discrete::TypeError
    end

    it 'raises a VertexNotUnique if the vertex is already part of the vertex set' do
      graph.add_vertex! vertex

      expect { graph.add_vertex! vertex }.to raise_error Math::Discrete::Graph::VertexNotUnique
    end
  end

  describe '#add_vertices!, #add_nodes!' do
    let(:vertices) { Math::Discrete::Graph::Vertex.build_from_labels *labels }

    it 'adds the vertices to the vertex set' do
      expect { graph.add_vertices! vertices }.to change(graph.vertex_set, :count).by 2
      expect(graph.vertex_set).to include *vertices
    end

    it 'raises a TypeError if the input includes an object of a non-Vertex type' do
      expect { graph.add_vertices!(vertices << 'This is not a vertex') }.to raise_error Math::Discrete::TypeError
    end

    it 'raises a VertexNotUnique if the input includes a vertex that is already part of the vertex set' do
      graph.add_vertex! vertices.first

      expect { graph.add_vertices! vertices }.to raise_error Math::Discrete::Graph::VertexNotUnique
    end
  end

  describe '#add_edge!' do
    let(:vertices) { Math::Discrete::Graph::Vertex.build_from_labels *labels }
    let(:edge) { Math::Discrete::Graph::Edge.build_from_vertices *vertices }
    let(:graph) { Math::Discrete::Graph.build_from_sets vertex_set: vertices }

    it 'adds the edge to the edge set' do
      expect { graph.add_edge! edge }.to change(graph.edge_set, :count).by 1
      expect(graph.edge_set).to include edge
    end

    it 'raises a TypeError if the input is an object of a non-Edge type' do
      expect { graph.add_edge! 'This is not an edge' }.to raise_error Math::Discrete::TypeError
    end

    it 'raises a EdgeNotUnique if the edge is already part of the edge set' do
      graph.add_edge! edge

      expect { graph.add_edge! edge }.to raise_error Math::Discrete::Graph::EdgeNotUnique
    end
  end

  describe '#add_edges!' do
    let(:vertices) { Math::Discrete::Graph::Vertex.build_from_labels *labels }
    let(:edges) { [Math::Discrete::Graph::Edge.build_from_vertices(*vertices)] }
    let(:graph) { Math::Discrete::Graph.build_from_sets vertex_set: vertices }

    it 'adds the edges to the edge set' do
      expect { graph.add_edges! edges }.to change(graph.edge_set, :count).by 1
      expect(graph.edge_set).to include *edges
    end

    it 'raises a TypeError if the input includes an object of a non-Edge type' do
      expect { graph.add_edges!(edges << 'This is not an edge') }.to raise_error Math::Discrete::TypeError
    end

    it 'raises a EdgeNotUnique if the input includes an edge that is already part of the edge set' do
      graph.add_edge! edges.first

      expect { graph.add_edges! edges }.to raise_error Math::Discrete::Graph::EdgeNotUnique
    end
  end

  describe '#remove_vertex!, #remove_node!' do
    let(:vertices) { Math::Discrete::Graph::Vertex.build_from_labels *labels }
    let(:vertex) { vertices.first }
    let(:edge) { Math::Discrete::Graph::Edge.build_from_vertices *vertices }
    let(:edges) { Set[edge] }
    let(:graph) { Math::Discrete::Graph.build_from_sets vertex_set: vertices, edge_set: edges }

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
      foreign_vertex = Math::Discrete::Graph::Vertex.build_from_label 'Z'

      expect { graph.remove_vertex! foreign_vertex }.to raise_error Math::Discrete::Graph::VertexNotFound
    end
  end

  describe '#remove_vertices!, #remove_nodes!' do
    let(:vertices) { Math::Discrete::Graph::Vertex.build_from_labels *labels }
    let(:vertex) { vertices.first }
    let(:edge) { Math::Discrete::Graph::Edge.build_from_vertices *vertices }
    let(:edges) { Set[edge] }
    let(:graph) { Math::Discrete::Graph.build_from_sets vertex_set: vertices, edge_set: edges }

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
      foreign_vertex = Math::Discrete::Graph::Vertex.build_from_label 'Z'

      expect { graph.remove_vertices! vertices.add(foreign_vertex) }.to raise_error Math::Discrete::Graph::VertexNotFound
    end
  end

  describe '#remove_edge' do
    let(:vertices) { Math::Discrete::Graph::Vertex.build_from_labels *labels }
    let(:edge) { Math::Discrete::Graph::Edge.build_from_vertices *vertices }
    let(:edges) { Set[edge] }
    let(:graph) { Math::Discrete::Graph.build_from_sets vertex_set: vertices, edge_set: edges }

    it 'removes the edge from the edge set' do
      expect { graph.remove_edge! edge }.to change(graph.edge_set, :count).by -1
      expect(graph.edge_set).not_to include edge
    end

    it 'raises a TypeError if the input is an object of non-Edge type' do
      expect { graph.remove_edge! 'This is not a vertex' }.to raise_error Math::Discrete::TypeError
    end

    it 'raises an EdgeNotFound if the input is an edge that is not part of the edge set' do
      foreign_edge = Math::Discrete::Graph::Edge.build_from_vertices *vertices.to_a.reverse

      expect { graph.remove_edge! foreign_edge }.to raise_error Math::Discrete::Graph::EdgeNotFound
    end
  end

  describe '#remove_edges' do
    let(:vertices) { Math::Discrete::Graph::Vertex.build_from_labels *labels }
    let(:edge) { Math::Discrete::Graph::Edge.build_from_vertices *vertices }
    let(:edges) { Set[edge] }
    let(:graph) { Math::Discrete::Graph.build_from_sets vertex_set: vertices, edge_set: edges }

    it 'removes the edge from the edge set' do
      expect { graph.remove_edges! edges }.to change(graph.edge_set, :count).by -1
      expect(graph.edge_set).not_to include *edge
    end

    it 'raises a TypeError if the input includes an an object of non-Edge type' do
      expect { graph.remove_edges! %w(This is not a vertex) }.to raise_error Math::Discrete::TypeError
    end

    it 'raises an EdgeNotFound if the input includes an edge that is not part of the edge set' do
      foreign_edge = Math::Discrete::Graph::Edge.build_from_vertices *vertices.entries.reverse

      expect { graph.remove_edges! edges.add(foreign_edge) }.to raise_error Math::Discrete::Graph::EdgeNotFound
    end
  end

  describe '#find_vertex_by_label!' do
    let(:vertices) { Math::Discrete::Graph::Vertex.build_from_labels 'A' }
    let(:graph) { Math::Discrete::Graph.build_from_sets vertex_set: vertices }
    let(:result) { graph.find_vertex_by_label! 'A' }

    it 'returns the vertex with the given label in the vertex set' do
      expect(result).to be_a Math::Discrete::Graph::Vertex
      expect(result.label).to eq 'A'
    end

    it 'raises VertexNotFound if the vertex set does not include a vertex with the given label' do
      expect { graph.find_vertex_by_label! 'Z' }.to raise_error Math::Discrete::Graph::VertexNotFound
    end
  end

  describe '#find_vertices_by_labels!' do
    let(:vertices) { Math::Discrete::Graph::Vertex.build_from_labels *labels }
    let(:graph) { Math::Discrete::Graph.build_from_sets vertex_set: vertices}
    let(:result) { graph.find_vertices_by_labels! *labels }

    it 'returns the vertices with the given labels in the vertex set' do
      expect(result).to be_a Set
      expect(result).to all be_a Math::Discrete::Graph::Vertex
      expect(result.size).to be 2
      expect(result.map &:label).to contain_exactly *labels
    end

    it 'raises VertexNotFound if the vertex set does not include a vertex with one of the given labels' do
      expect { graph.find_vertices_by_labels! 'C', 'D' }.to raise_error Math::Discrete::Graph::VertexNotFound
    end
  end

  describe '#find_edge_by_labels!' do
    let(:vertices) { Math::Discrete::Graph::Vertex.build_from_labels *labels }
    let(:edge) { Math::Discrete::Graph::Edge.build_from_vertices *vertices }
    let(:edges) { Set[edge] }
    let(:graph) { Math::Discrete::Graph.build_from_sets vertex_set: vertices, edge_set: edges }
    let(:result) { graph.find_edge_by_labels! *labels }

    it 'returns the edge with the given labels in the edge set' do
      expect(result).to be_a Math::Discrete::Graph::Edge
      expect(result.labels).to contain_exactly *labels
    end

    it 'raises EdgeNotFound if the edge set does not include an edge with the given labels' do
      expect { graph.find_edge_by_labels! 'X', 'Y' }.to raise_error Math::Discrete::Graph::EdgeNotFound
    end
  end

  describe '#vertex_labels' do
    let(:vertices) { Math::Discrete::Graph::Vertex.build_from_labels 'A', 'B' }
    let(:graph) { Math::Discrete::Graph.build_from_sets vertex_set: vertices }

    it 'returns a set of all the vertex labels' do
      expect(graph.vertex_labels).to contain_exactly 'A', 'B'
    end
  end
end
