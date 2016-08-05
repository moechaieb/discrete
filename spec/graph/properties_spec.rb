require 'spec_helper'

describe Math::Discrete::Graph::Properties do
  (described_class.methods - Object.methods - %i(all)).each do |property_method|
    describe property_method do
      it "builds a property called #{property_method}" do
        expect(Math::Discrete::Graph::Properties.send(property_method).name).to be property_method
      end

      it 'defines a valid Property object for graphs' do
        expect(Math::Discrete::Graph::Properties.send(property_method)).to be_a Math::Discrete::Property
        expect(Math::Discrete::Graph::Properties.send(property_method).structure_type).to be :graph
      end
    end
  end

  describe '::all' do
    it 'returns a Set of Property objects' do
      expect(described_class.all).to be_a Array
      expect(described_class.all).to all be_a Math::Discrete::Property
    end
  end

  describe '::bipartiteness' do
    it 'returns early if the graph contains too many edges to possibly be bipartite' do
      skip
    end

    it 'returns true if the graph is an even cycle' do
      skip
    end

    it 'returns false if the graph is an odd cycle' do
      skip
    end

    it 'returns true if the graph is a tree' do
      skip
    end
  end

  describe '::completeness' do
    it 'returns true if and only if every vertex is adjacent to every other vertex in the graph' do
      skip
    end

    it 'returns false if there is a vertex that is not adjacent to all other vertices in the graph' do
      skip
    end
  end

  describe '::planarity' do
    skip
  end

  describe '::regularity' do
    it 'returns true if each vertex has the same number of adjacent vertices as all other vertices in the graph' do
      skip
    end

    it 'returns false if there are two vertices that does not have the same number of adjacent vertices in the graph' do
      skip
    end
  end
end
