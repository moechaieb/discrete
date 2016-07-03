require 'spec_helper'

describe Math::Discrete::Graph::Vertex do
  let(:vertex) { Math::Discrete::Graph::Vertex.build_from_label 'test' }

  describe '::build_from_label' do
    it 'creates a new vertex with the given label and no adjacent vertices' do
      expect(vertex).to be_a Math::Discrete::Graph::Vertex
      expect(vertex.label).to eq 'test'
      expect(vertex.adjacent_vertices).to be_empty
    end
  end

  describe '#add_adjacent_vertex' do
    let(:other_vertex) { Math::Discrete::Graph::Vertex.build_from_label 'other' }

    it 'adds the given vertex to the vertex\'s set of adjacent vertices' do
      vertex.add_adjacent_vertex other_vertex

      expect(vertex.adjacent_vertices).to include other_vertex
    end
  end

  describe '#remove_adjacent_vertex' do
    let(:other_vertex) { Math::Discrete::Graph::Vertex.build_from_label 'other' }

    it 'removes the given vertex from the vertex\'s set of adjacent vertices' do
      vertex.add_adjacent_vertex other_vertex
      vertex.remove_adjacent_vertex other_vertex

      expect(vertex.adjacent_vertices).not_to include other_vertex
    end
  end

  describe '#==' do
    let(:same_vertex) { Math::Discrete::Graph::Vertex.build_from_label 'test' }
    let(:different_vertex) { Math::Discrete::Graph::Vertex.build_from_label 'other_vertex'}

    it 'returns true if compared with itself' do
      expect(vertex == vertex).to be true
    end

    it 'returns true if compared to vertex with the same label' do
      expect(vertex == same_vertex).to be true
    end

    it 'returns false if compared to a vertex with a different label' do
      expect(vertex == different_vertex).to be false
    end

    it 'raises an error when compared to an object of non-Vertex type' do
      expect { vertex == 'This is not a vertex' }.to raise_error Math::Discrete::TypeError
    end
  end
end
