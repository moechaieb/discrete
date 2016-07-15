require 'spec_helper'

describe Math::Discrete::Graph::Properties do
  (described_class.methods - Object.methods - %i(all)).each do |property_method|
    describe property_method do
      it "builds a property called #{property_method}" do
        expect(Math::Discrete::Graph::Properties.send(property_method).name).to be property_method
      end
    end
  end
end
