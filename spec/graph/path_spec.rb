require 'spec_helper'

describe Math::Discrete::Graph::Path do
  let(:vertices) { Vertex::Set[1,2,3,4] }
  let(:edges) do
    Edge::Set[
      [vertices.entries[0], vertices.entries[1]],
      [vertices.entries[1], vertices.entries[2]],
      [vertices.entries[2], vertices.entries[3]]
    ]
  end
  let(:path) { Graph::Path[*edges] }

  describe '::[]' do
    it 'raises an InvalidPath if the given edges do not make a continuous path' do
      edges.add Edge[vertices.entries[2], vertices.entries[0]]

      expect { Graph::Path[*edges] }.to raise_error Graph::Path::InvalidPath
    end

    it 'creates a new Path object with the given edges' do
      expect(path).to be_an_instance_of Graph::Path
      expect(path).to be_an_instance_of Graph::Path
    end
  end

  describe '#cyclical?' do
    it 'returns true if the path ends in the same vertex that it starts with' do
      edges.add Edge[vertices.entries[3], vertices.entries[0]]
      cycle = Graph::Path[*edges]

      expect(cycle).to be_cyclical
    end

    it 'returns false if the path is not a cycle' do
      expect(path).not_to be_cyclical
    end
  end

  describe '#edges' do
    it 'returns a Set of edges along the path' do
      expect(path.vertices).to be_an_instance_of Set
      expect(path.vertices).to contain_exactly *vertices
    end
  end

  describe '#vertices, #nodes' do
    it 'returns a Set of vertices along the path' do
      expect(path.vertices).to be_an_instance_of Set
      expect(path.vertices).to contain_exactly *vertices
    end
  end
end
