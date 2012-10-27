module DataMapper
  class RelationRegistry
    class Builder

      # Builds relation nodes for relationships
      #
      class BaseBuilder < self

        # @api private
        def initialize(relations, mappers, relationship)
          super

          edge     = build_edge
          relation = build_relation(edge)
          node     = build_node(name, relation)

          @connector = RelationRegistry::Connector.new(name, node, relationship, relations)
          relations.add_connector(@connector)
        end

        def name
          @name ||= NodeName.new(left_name, right_name, relationship.name).to_connector_name
        end

      end # class BaseBuilder

    end # class Builder
  end # class RelationRegistry
end # module DataMapper
