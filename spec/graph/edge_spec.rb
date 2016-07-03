require 'spec_helper'

describe Math::Discrete::Graph::Edge do
  let(:first_vertex) { Math::Discrete::Graph::Vertex.build_from_label 'A' }
  let(:second_vertex) { Math::Discrete::Graph::Vertex.build_from_label 'B' }
  let(:edge) { Math::Discrete::Graph::Edge.build_from_vertices first_vertex, second_vertex }

  describe '::build_from_vertices' do
    it 'creates a new edge between the two given vertices' do
      expect(edge.from).to be first_vertex
      expect(edge.to).to be second_vertex
    end

    it 'connects the vertices and updates their set of adjacent vertices' do
      expect(edge.from.adjacent_vertices).to include edge.to
      expect(edge.to.adjacent_vertices).to be_empty
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
