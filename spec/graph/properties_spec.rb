require 'spec_helper'

describe Math::Discrete::Graph::Properties do
  let(:directed_graph) { Graph[[1,2,3,4], [[1,2],[2,3],[3,1], [1,4], [4,2]]] }
  let(:complete_graph) { Graph[[*(1..5)], (1..5).to_a.permutation(2).to_a] }
  let(:even_cycle) { Graph[[*(1..10)], [*((1..10).each_cons(2).to_a << [10,1])]] }
  let(:odd_cycle) { Graph[[*(1..7)], [*((1..7).each_cons(2).to_a << [7,1])]] }

  let(:tree) { Graph[(1..7).to_a, [[1,2], [1,3], [2,4], [2,5], [3,6], [3,7]]] }

  describe '::METHODS' do
    it 'returns an array of method names defining properties in the module' do
      expect(described_class::METHODS).to contain_exactly(*described_class.map(&:name))
    end
  end

  described_class::METHODS.each do |property_method|
    describe "##{property_method}" do
      it "builds a property called #{property_method}" do
        expect(Graph::Properties.send(property_method).name).to be property_method
      end

      it 'defines a valid Property object for graphs' do
        expect(Graph::Properties.send(property_method)).to be_a Math::Discrete::Property
        expect(Graph::Properties.send(property_method).structure_type).to be :graph
      end
    end
  end

  describe '::all' do
    it 'returns a Set of Property objects' do
      expect(described_class.all).to be_a Array
      expect(described_class.all).to all be_a Math::Discrete::Property
      expect(described_class.map(&:structure_type)).to all be :graph
    end
  end

  describe '::bipartiteness' do
    let(:bipartiteness) { Graph::Properties.bipartiteness }

    it 'returns false early if the graph contains too many edges to possibly be bipartite' do
      expect(complete_graph).to receive(:breadth_first_search).never

      expect(complete_graph).not_to be_bipartite
    end

    it 'returns true if the graph is an even cycle' do
      expect(even_cycle).to be_bipartite
    end

    it 'returns false if the graph is an odd cycle' do
      expect(odd_cycle).not_to be_bipartite
    end

    it 'returns true if the graph is a tree' do
      expect(tree).to be_bipartite
    end
  end

  describe '::completeness' do
    let(:completeness) { Graph::Properties.completeness }

    it 'returns true if and only if every vertex is adjacent to every other vertex in the graph' do
      expect(complete_graph.satisfies? completeness).to be true
    end

    it 'returns false if there is a vertex that is not adjacent to all other vertices in the graph' do
      expect(directed_graph.satisfies? completeness).to be false
    end
  end

  describe '::regularity' do
    let(:regularity) { Graph::Properties.regularity }

    it 'returns true if each vertex has the same number of adjacent vertices as all other vertices in the graph' do
      expect(even_cycle.satisfies? regularity).to be true
    end

    it 'returns false if there are two vertices that does not have the same number of adjacent vertices in the graph' do
      expect(directed_graph.satisfies? regularity).to be false
    end
  end
end
