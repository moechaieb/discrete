require 'spec_helper'

describe Math::Discrete::Graph::Edge do
  let(:first_vertex) { Math::Discrete::Graph::Vertex.build_from_label 'A' }
  let(:second_vertex) { Math::Discrete::Graph::Vertex.build_from_label 'B' }
  let(:edge) { Math::Discrete::Graph::Edge.build_from_vertices first_vertex, second_vertex }

  describe '::build_from_vertices' do
    it 'creates a new edge between the two given vertices, and has no graph' do
      expect(edge.graph).to be_nil
      expect(edge.from).to be first_vertex
      expect(edge.to).to be second_vertex
    end

    it 'connects the vertices and updates their set of adjacent vertices' do
      expect(edge.from.adjacent_vertices).to include edge.to
    end
  end

  describe '#set_graph!' do
    let(:graph) { Math::Discrete::Graph.build_from_sets }

    it 'raises an error when given an input that is not of type Math::Discrete::Graph' do
      expect { edge.set_graph! 'I am not a graph' }.to raise_error(Math::Discrete::TypeError)
    end

    it 'sets the graph attribute to the given graph' do
      expect { edge.set_graph! graph }.not_to raise_error
      expect(edge.graph).to eq graph
      expect(edge.graph).to be_a Math::Discrete::Graph
    end
  end

  describe '#labels' do
    it 'returns a set of labels of the vertices connected by the edge' do
      labels = edge.labels

      expect(labels).to be_a Set
      expect(labels).to contain_exactly 'A', 'B'
    end
  end

  describe '#to_set' do
    it 'returns a set of the vertices connected by the edge' do
      vertices = edge.to_set

      expect(vertices).to be_a Set
      expect(vertices).to contain_exactly first_vertex, second_vertex
    end
  end
end
