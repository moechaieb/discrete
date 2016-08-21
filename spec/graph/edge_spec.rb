require 'spec_helper'

describe Math::Discrete::Graph::Edge do
  let(:first_vertex) { Vertex['A'] }
  let(:second_vertex) { Vertex['B'] }
  let(:edge) { Edge[first_vertex, second_vertex] }

  describe '::build' do
    it 'creates a new edge between the two given vertices' do
      expect(edge.from).to be first_vertex
      expect(edge.to).to be second_vertex
    end

    it 'connects the vertices and updates their set of adjacent vertices' do
      expect(edge.from.adjacent_vertices).to include edge.to
      expect(edge.to.adjacent_vertices).to be_empty
    end

    it 'raises a TypeError when given objects of non-Vertex type as input' do
      expect { Edge['Not a vertex', second_vertex] }.to raise_error TypeError
      expect { Edge[first_vertex, 'Not a vertex'] }.to raise_error TypeError
    end

    it 'raises a TypeError when given a non-numeric weight' do
      expect { Edge['Not a vertex', second_vertex, '1'] }.to raise_error TypeError
    end
  end

  describe '#==' do
    let(:same_edge) { Edge[first_vertex, second_vertex] }
    let(:third_vertex) { Vertex['C'] }
    let(:different_edge) { Edge[second_vertex, third_vertex] }

    it 'returns false the other edge does not have the same vertices' do
      expect(edge).not_to eq different_edge
      expect(different_edge).not_to eq edge
    end

    it 'returns true if both edges are between the same vertices' do
      expect(edge).to eq same_edge
      expect(same_edge).to eq edge
    end
  end

  describe '#labels' do
    it 'returns a set of labels of the vertices connected by the edge' do
      labels = edge.labels

      expect(labels).to be_an_instance_of Set
      expect(labels).to contain_exactly 'A', 'B'
    end
  end

  describe '#vertices' do
    it 'returns a set of the vertices connected by the edge' do
      vertices = edge.vertices

      expect(vertices).to be_an_instance_of Set
      expect(vertices).to contain_exactly first_vertex, second_vertex
    end
  end

  describe '#weighted?' do
    it 'returns true if the weight is different from 1' do
      edge.weight = 2

      expect(edge).to be_weighted
    end

    it 'returns false if the weight is equal to 1' do
      expect(edge).not_to be_weighted
    end
  end
end
