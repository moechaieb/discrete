require 'spec_helper'

describe Math::Discrete::Graph::Edge do
  let(:first_vertex) { Graph::Vertex.build_from_label 'A' }
  let(:second_vertex) { Graph::Vertex.build_from_label 'B' }
  let(:directed_edge) { described_class::Directed.build from: first_vertex, to: second_vertex }
  let(:undirected_edge) { described_class::Undirected.build_between first_vertex, second_vertex }

  context '::Directed' do
    describe '::build' do
      it 'creates a new edge between the two given vertices' do
        expect(directed_edge.from).to be first_vertex
        expect(directed_edge.to).to be second_vertex
      end

      it 'connects the vertices and updates their set of adjacent vertices' do
        expect(directed_edge.from.adjacent_vertices).to include directed_edge.to
        expect(directed_edge.to.adjacent_vertices).to be_empty
      end

      it 'raises a TypeError when given objects of non-Vertex type as input' do
        expect { described_class::Directed.build from: 'Not a vertex', to: second_vertex }.to raise_error Math::Discrete::TypeError
        expect { described_class::Directed.build from: first_vertex, to: 'Not a vertex' }.to raise_error Math::Discrete::TypeError
      end

      it 'raises a TypeError when given a non-numeric weight' do
        expect { described_class::Directed.build from: 'Not a vertex', to: second_vertex, weight: '1' }.to raise_error Math::Discrete::TypeError
      end
    end
  end

  context '::Undirected' do
    describe '::build_between' do
      it 'creates a new edge between the two given vertices' do
        expect(undirected_edge.from).to be first_vertex
        expect(undirected_edge.to).to be second_vertex
      end

      it 'connects the vertices and updates their set of adjacent vertices' do
        expect(undirected_edge.from.adjacent_vertices).to include undirected_edge.to
        expect(undirected_edge.to.adjacent_vertices).to include undirected_edge.from
      end

      it 'raises a TypeError when given objects of non-Vertex type as input' do
        expect { described_class::Undirected.build_between 'Not a vertex', second_vertex }.to raise_error Math::Discrete::TypeError
        expect { described_class::Undirected.build_between first_vertex, 'Not a vertex' }.to raise_error Math::Discrete::TypeError
      end

      it 'raises a TypeError when given a non-numeric weight' do
        expect { described_class::Undirected.build_between 'Not a vertex', second_vertex, weight: '1' }.to raise_error Math::Discrete::TypeError
      end
    end
  end

  describe '#==' do
    let(:third_vertex) { Graph::Vertex.build_from_label 'B' }
    let(:same_undirected_edge) { described_class::Undirected.build_between second_vertex, first_vertex }
    let(:same_directed_edge) { described_class::Directed.build from: first_vertex, to: second_vertex }

    it 'returns false when undirected and other_edge is directed or vice versa' do
      expect(directed_edge).not_to eq undirected_edge
      expect(undirected_edge).not_to eq directed_edge
    end

    it 'returns true if both edges are directed, originate from the same vertex and end at the same vertex' do
      expect(same_directed_edge).to eq directed_edge
      expect(directed_edge).to eq same_directed_edge
    end

    it 'returns true if both edges are undirected and between the same vertices' do
      expect(undirected_edge).to eq same_undirected_edge
      expect(same_undirected_edge).to eq undirected_edge
    end
  end

  describe '#labels' do
    it 'returns a set of labels of the vertices connected by the edge' do
      labels = directed_edge.labels

      expect(labels).to be_a Set
      expect(labels).to contain_exactly 'A', 'B'
    end
  end

  describe '#vertices' do
    it 'returns a set of the vertices connected by the edge' do
      vertices = directed_edge.vertices

      expect(vertices).to be_a Set
      expect(vertices).to contain_exactly first_vertex, second_vertex
    end
  end

  describe '#weighted?' do
    it 'returns true if the weight is different from 1' do
      directed_edge.weight = 2

      expect(directed_edge).to be_weighted
    end

    it 'returns false if the weight is equal to 1' do
      expect(undirected_edge).not_to be_weighted
    end
  end
end
