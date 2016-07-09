require 'spec_helper'

describe Math::Discrete::Graph::Edge do
  let(:first_vertex) { Math::Discrete::Graph::Vertex.build_from_label 'A' }
  let(:second_vertex) { Math::Discrete::Graph::Vertex.build_from_label 'B' }
  let(:directed_edge) { Math::Discrete::Graph::Edge::Directed.build from: first_vertex, to: second_vertex }
  let(:undirected_edge) { Math::Discrete::Graph::Edge::Undirected.build_between first_vertex, second_vertex }

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
        expect { Math::Discrete::Graph::Edge::Directed.build from: 'Not a vertex', to: second_vertex }.to raise_error Math::Discrete::TypeError
        expect { Math::Discrete::Graph::Edge::Directed.build from: first_vertex, to: 'Not a vertex' }.to raise_error Math::Discrete::TypeError
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
        expect { Math::Discrete::Graph::Edge::Undirected.build_between 'Not a vertex', second_vertex }.to raise_error Math::Discrete::TypeError
        expect { Math::Discrete::Graph::Edge::Undirected.build_between first_vertex, 'Not a vertex' }.to raise_error Math::Discrete::TypeError
      end
    end
  end

  describe '#==' do

  end

  describe '#labels' do
    it 'returns a set of labels of the vertices connected by the edge' do
      labels = directed_edge.labels

      expect(labels).to be_a Set
      expect(labels).to contain_exactly 'A', 'B'
    end
  end

  describe '#to_set' do
    it 'returns a set of the vertices connected by the edge' do
      vertices = directed_edge.to_set

      expect(vertices).to be_a Set
      expect(vertices).to contain_exactly first_vertex, second_vertex
    end
  end
end
