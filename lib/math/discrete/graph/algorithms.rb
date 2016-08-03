require 'algorithms'

module Math::Discrete::Graph::Algorithms
  def breadth_first_search(root: @vertex_set.first)
    return {} if @vertex_set.empty?

    raise Math::Discrete::TypeError, 'root must be of the type Math::Discrete::Graph::Vertex' unless root.is_a? Vertex
    raise Math::Discrete::Graph::VertexNotFound, "could not find vertex with label=#{root.label}" unless vertex_labels.include? root.label


    search_queue = Containers::Queue.new [root]
    search_tree = { root.label => { distance: 0, parent: nil } }

    until search_queue.empty?
      vertex = search_queue.pop

      vertex.adjacent_vertices.each do |child|
        if search_tree[child.label].nil?
          search_tree[child.label] = {
            distance: search_tree[vertex.label][:distance] + 1,
            parent: vertex.label
          }

          search_queue.push child
        end
      end
    end

    search_tree
  end

  def depth_first_search(root: @vertex_set.first)
    return {} if @vertex_set.empty?

    raise Math::Discrete::TypeError, 'root must be of the type Math::Discrete::Graph::Vertex' unless root.is_a? Vertex
    raise Math::Discrete::Graph::VertexNotFound, "could not find vertex with label=#{root.label}" unless vertex_labels.include? root.label


    search_stack = Containers::Stack.new [root]
    search_tree = { root.label => { distance: 0, parent: nil } }

    until search_stack.empty?
      vertex = search_stack.pop

      vertex.adjacent_vertices.each do |child|
        if search_tree[child.label].nil?
          search_tree[child.label] = {
            distance: search_tree[vertex.label][:distance] + 1,
            parent: vertex.label
          }

          search_stack.push child
        end
      end
    end

    search_tree
  end
end
