require 'spec_helper'

describe Graph::Algorithms do
  let(:empty_directed_graph) { Graph.build }
  let(:empty_undirected_graph) { Graph.build directed: false }
  let(:directed_graph) {
    Graph.build_from_labels vertex_labels: Set[1,2,3,4], edge_labels: Set[[1,2],[2,3],[3,1], [1,4], [4,2]]
  }
  let(:foreign_vertex) { Graph::Vertex.build_from_label 'Z' }

  describe '#breadth_first_search' do
    let(:search_tree) { directed_graph.breadth_first_search }

    it 'returns an empty search tree if the graph is empty' do
      expect(empty_directed_graph.breadth_first_search).to be_a Hash
      expect(empty_directed_graph.breadth_first_search).to be_empty
    end

    it 'returns a valid search tree in Hash form' do
      expect(search_tree).to be_a Hash
      expect(search_tree).not_to be_empty
      expect(search_tree.keys).to contain_exactly *directed_graph.vertex_labels
    end

    it 'satisfies the properties of a BFS tree' do
      expect(search_tree[1][:distance]).to be_zero
      expect(search_tree[1][:parent]).to be_nil

      expect(search_tree[2][:distance]).to be 1
      expect(search_tree[2][:parent]).to be 1

      expect(search_tree[4][:distance]).to be 1
      expect(search_tree[4][:parent]).to be 1

      expect(search_tree[3][:distance]).to be 2
      expect(search_tree[3][:parent]).to be 2

      search_tree.each do |label, data|
        next if label == 1
        expect(data[:distance]).to be(search_tree[data[:parent]][:distance] + 1)
      end
    end

    it 'raises a TypeError if the root is not a Vertex' do
      expect {
        directed_graph.breadth_first_search root: 'not_a_vertex'
      }.to raise_error Math::Discrete::TypeError
    end

    it 'raises a VertexNotFound if the root is not in the graph' do
      expect {
        directed_graph.breadth_first_search root: foreign_vertex
      }.to raise_error Graph::VertexNotFound
    end
  end

  describe '#depth_first_search' do
    let(:search_tree) { directed_graph.depth_first_search }

    it 'returns an empty search tree if the graph is empty' do
      expect(empty_directed_graph.depth_first_search).to be_a Hash
      expect(empty_directed_graph.depth_first_search).to be_empty
    end

    it 'returns a valid search tree in Hash form' do
      expect(search_tree).to be_a Hash
      expect(search_tree).not_to be_empty
      expect(search_tree.keys).to contain_exactly *directed_graph.vertex_labels
    end

    it 'raises a TypeError if the root is not a Vertex' do
      expect {
        directed_graph.depth_first_search root: 'not_a_vertex'
      }.to raise_error Math::Discrete::TypeError
    end

    it 'raises a VertexNotFound if the root is not in the graph' do
      expect {
        directed_graph.depth_first_search root: foreign_vertex
      }.to raise_error Graph::VertexNotFound
    end
  end
end
