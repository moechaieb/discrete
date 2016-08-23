require 'spec_helper'

describe Graph::Algorithms do
  describe '#breadth_first_search' do
    let(:empty_graph) { Graph[] }
    let(:graph) { Graph[[1,2,3,4], [[1,2],[2,3],[3,1], [1,4], [4,2]]] }
    let(:foreign_vertex) { Vertex['Z'] }
    let(:search_tree) { graph.breadth_first_search }

    it 'returns an empty search tree if the graph is empty' do
      expect(empty_graph.breadth_first_search).to be_an_instance_of Hash
      expect(empty_graph.breadth_first_search).to be_empty
    end

    it 'returns a valid search tree in Hash form' do
      expect(search_tree).to be_an_instance_of Hash
      expect(search_tree).not_to be_empty
      expect(search_tree.keys).to contain_exactly *graph.vertex_labels
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
        graph.breadth_first_search root: 'not_a_vertex'
      }.to raise_error TypeError
    end

    it 'raises a VertexNotFound if the root is not in the graph' do
      expect {
        graph.breadth_first_search root: foreign_vertex
      }.to raise_error Graph::VertexNotFound
    end
  end

  describe '#depth_first_search' do
    let(:empty_graph) { Graph[] }
    let(:graph) { Graph[[1,2,3,4], [[1,2],[2,3],[3,1], [1,4], [4,2]]] }
    let(:foreign_vertex) { Vertex['X'] }
    let(:search_tree) { graph.depth_first_search }

    it 'returns an empty search tree if the graph is empty' do
      expect(empty_graph.depth_first_search).to be_an_instance_of Hash
      expect(empty_graph.depth_first_search).to be_empty
    end

    it 'returns a valid search tree in Hash form' do
      expect(search_tree).to be_an_instance_of Hash
      expect(search_tree).not_to be_empty
      expect(search_tree.keys).to contain_exactly *graph.vertex_labels
    end

    it 'raises a TypeError if the root is not a Vertex' do
      expect {
        graph.depth_first_search root: 'not_a_vertex'
      }.to raise_error TypeError
    end

    it 'raises a VertexNotFound if the root is not in the graph' do
      expect {
        graph.depth_first_search root: foreign_vertex
      }.to raise_error Graph::VertexNotFound
    end
  end

  describe '#shortest_path_between' do
    let(:positive_weight_graph) do
      Graph[[1,2,3,4,5,6], [[1,2,7],[2,1,7],[1,6,14],[6,1,14],[1,3,9],[3,1,9],[2,3,10],[3,2,10],[3,6,2],[6,3,2],[3,4,11],[4,3,11],[2,4,15],[4,2,15],[4,5,6],[5,4,6],[6,5,9],[5,6,9]]]
    end
    let(:source) { positive_weight_graph.find_vertex_by_label! 1 }
    let(:target) { positive_weight_graph.find_vertex_by_label! 5 }
    let(:foreign_vertex) { Vertex[7] }

    let(:negative_weight_graph) do
      Graph[[1,2,3,4,5], [[1,2,-3],[2,3,1],[3,4,1],[4,5,1]]]
    end
    let(:source) { negative_weight_graph.find_vertex_by_label! 1 }
    let(:target) { negative_weight_graph.find_vertex_by_label! 5 }

    it 'raises a TypeError if the source vertex is not of type Vertex' do
      expect {
        positive_weight_graph.shortest_path_between 'not a vertex', target
      }.to raise_error TypeError
    end

    it 'raises a TypeError if the target vertex is not of type Vertex' do
      expect {
        positive_weight_graph.shortest_path_between source, 'not a vertex'
      }.to raise_error TypeError
    end

    it 'raises a Graph::VertexNotFound if the source vertex is not in the graph' do
      expect {
        positive_weight_graph.shortest_path_between foreign_vertex, target
      }.to raise_error Graph::VertexNotFound
    end

    it 'raises a Graph::VertexNotFound if the target vertex is not in the graph' do
      expect {
        positive_weight_graph.shortest_path_between source, foreign_vertex
      }.to raise_error Graph::VertexNotFound
    end

    it 'returns an empty path if the source and the target are the same vertex' do
      path = positive_weight_graph.shortest_path_between source, source

      expect(path.edges).to be_empty
    end

    it 'returns a valid shortest path for graphs with positive-weight edges' do
      path = positive_weight_graph.shortest_path_between source, target

      expect(path).to be_an_instance_of Graph::Path
    end

    it 'returns a valid shortest path for graphs with negative-weight edges' do
      path = negative_weight_graph.shortest_path_between source, target

      expect(path).to be_an_instance_of Graph::Path
    end

    it 'raises a NegativeWeightCycleError if the graph contains a negative-weight cycle' do
      negative_weight_cycle_graph = Graph[[1,2,3,4,5], [[1,2,5],[2,3,-1],[3,4,-1],[4,2,-1],[2,5,1]]]
      source = negative_weight_cycle_graph.find_vertex_by_label! 1
      target = negative_weight_cycle_graph.find_vertex_by_label! 5

      expect {
        negative_weight_cycle_graph.shortest_path_between source, target
      }.to raise_error Graph::Algorithms::NegativeWeightCycleError
    end
  end

  describe '#minimum_spanning_tree' do
    let(:graph) do
      Graph[
        %w(A B C D E F G),
        [
          ['A', 'B', 7], ['B', 'A', 7],
          ['A', 'D', 5], ['D', 'A', 5],
          ['B', 'C', 8], ['C', 'B', 8],
          ['B', 'D', 9], ['D', 'B', 9],
          ['B', 'E', 7], ['E', 'B', 7],
          ['C', 'E', 5], ['E', 'C', 5],
          ['D', 'E', 15], ['E', 'D', 15],
          ['D', 'F', 6], ['F', 'D', 6],
          ['E', 'F', 8], ['F', 'E', 8],
          ['F', 'G', 11], ['G', 'F', 11],
          ['E', 'G', 9], ['G', 'E', 9],
        ]
      ]
    end
    let(:mst) { graph.minimum_spanning_tree }

    it 'returns a valid minimum spanning tree' do
      expect(mst).to be_an_instance_of Graph
      expect(mst.vertex_set).to eq graph.vertex_set
      expect(mst.edge_set.size).to be 6
      expect(mst.edge_set.map(&:weight).reduce(:+)).to be 39
    end
  end

  describe '#weakly_connected_components' do
    skip
  end

  describe '#strongly_connected_components' do
    skip
  end

  describe '#cycles' do
    skip
  end
end
