require 'spec_helper'

describe Math::Discrete::Structure do
  let!(:structure_class) do
    Class.new(described_class) do
      property(:test_property, adjective: :test_property_satisfied) { |_| true }
    end
  end
  let(:property) { structure_class.properties.sample }
  let(:structure) { structure_class.new }

  describe '#satisfies_property?' do
    it 'caches results of previous queries' do
      expect(property).to receive(:satisfied?).once

      structure.satisfies? property

      expect(structure.properties).not_to be_empty
      expect(structure.properties).to include property.name
    end

    it 'returns the cached value when possible' do
      result = structure.satisfies? property

      expect(property).to receive(:satisfied?).never

      expect(structure.satisfies? property).to be result
    end
  end

  describe '#determine_properties!' do
    it "checks whether properties in the structure class' properties are verified by default" do
      structure.determine_properties!

      expect(structure.properties).to include *structure_class.properties.map(&:name)
    end

    it 'checks whether the given properties are verified' do
      properties = structure_class.properties.sample 2

      structure.determine_properties! properties

      expect(structure.properties).to include *properties.map(&:name)
    end
  end
end
