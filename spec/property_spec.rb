require 'spec_helper'

describe Math::Discrete::Property do
  describe '::build' do
    it 'raises an InvalidStructureType if the given structure_type is unknown' do
      expect {
        described_class.build(name: :test_prop, adjective: :test, structure_type: :yolo) { |_| _ }
      }.to raise_error described_class::InvalidStructureType
    end

    it 'raises a SatisfiabilityTestMissing if no block is given' do
      expect {
        described_class.build name: :test_prop, adjective: :test, structure_type: :graph
      }.to raise_error described_class::SatisfiabilityTestMissing
    end

    it 'creates a new property with the given arguments when supplied a block' do
      property = described_class.build(name: :test_prop, adjective: :test, structure_type: :graph) { |_| true }

      expect(property.name).to be :test_prop
      expect(property.structure_type).to be :graph
    end
  end

  describe '#satisfied?' do
    let(:property) do
      described_class.build name: :even, adjective: :even_number_of_vertices, structure_type: :graph do |graph|
        graph.vertex_set.size % 2 == 0
      end
    end

    let(:bad_property) do
      described_class.build name: :even, adjective: :even_number_of_vertices, structure_type: :graph do |graph|
        graph.vertex_set.size
      end
    end

    it 'raises a TypeError if the method is called with a structure of the wrong type' do
      expect { property.satisfied? 'This is not a graph.' }.to raise_error TypeError
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
