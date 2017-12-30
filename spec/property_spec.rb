require 'spec_helper'

describe Math::Discrete::Property do
  describe '::build' do
    it 'raises a SatisfiabilityTestMissing if no block is given' do
      expect {
        described_class.build name: :test_prop, adjective: :test
      }.to raise_error described_class::SatisfiabilityTestMissing
    end

    it 'creates a new property with the given arguments when supplied a block' do
      property = described_class.build(name: :test_prop, adjective: :test) { |_| true }

      expect(property.name).to be :test_prop
    end
  end

  describe '#satisfied?' do
    let(:property) do
      described_class.build name: :even, adjective: :even_number_of_vertices do |graph|
        graph.vertex_set.size % 2 == 0
      end
    end

    let(:bad_property) do
      described_class.build name: :even, adjective: :even_number_of_vertices do |graph|
        graph.vertex_set.size
      end
    end

    it 'raises a TypeError if the satisfiability_test returns a non-Boolean result' do
      graph = Graph[]

      expect { bad_property.satisfied? graph }.to raise_error TypeError
    end

    it 'returns the result of the satisfiability_test if the structure and result types are correct' do
      graph = Graph[['a', 'b'], [%w(a b)]]
      other_graph = Graph[['a', 'b', 'c'], [%w(a b), %w(b c)]]

      expect(property).to be_satisfied(graph)
      expect(property).not_to be_satisfied(other_graph)
    end
  end
end
