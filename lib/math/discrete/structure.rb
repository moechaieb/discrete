require 'pry'

class Math::Discrete::Structure
  attr_reader :properties

  class << self
    def properties
      @properties || []
    end

    private

    def property(name, adjective:, &block)
      register_property Math::Discrete::Property.build name: name, adjective: adjective, &block
    end


    def register_property(property)
      @properties = properties << property

      define_helper_methods(property)
    end

    def define_helper_methods(property)
      self.define_singleton_method(property.name) { property }
      define_method(:"#{property.adjective}?") { satisfies? property }
    end
  end

  def initialize(*args)
    clear_properties!
  end

  def satisfies?(property)
    property_name = property.name.to_sym

    return @properties[property_name] unless @properties[property_name].nil?

    @properties[property_name] = property.satisfied? self
    @properties.fetch property_name
  end

  def determine_properties!(properties = self.class.properties)
    properties.map { |property| satisfies? property }

    @properties
  end

  protected

  def clear_properties!
    @properties = {}
  end
end
