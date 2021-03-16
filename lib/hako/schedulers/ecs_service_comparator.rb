# frozen_string_literal: true

require 'hako/schema'

module Hako
  module Schedulers
    class EcsServiceComparator
      def initialize(expected_service)
        @expected_service = expected_service
        @schema = service_schema
      end

      # @param [Aws::ECS::Types::Service] actual_service
      # @return [Boolean]
      def different?(actual_service)
        !@schema.same?(actual_service.to_h, @expected_service)
      end

      private

      def service_schema
        Schema::Structure.new.tap do |struct|
          struct.member(:desired_count, Schema::Integer.new)
          struct.member(:task_definition, Schema::String.new)
          struct.member(:deployment_configuration, Schema::WithDefault.new(deployment_configuration_schema, default_configuration))
          struct.member(:capacity_provider_strategy, Schema::Nullable.new(Schema::UnorderedArray.new(capacity_provider_strategy_schema)))
          struct.member(:platform_version, Schema::WithDefault.new(Schema::String.new, 'LATEST'))
          struct.member(:network_configuration, Schema::Nullable.new(network_configuration_schema))
          struct.member(:health_check_grace_period_seconds, Schema::Nullable.new(Schema::Integer.new))
          struct.member(:enable_execute_command, Schema::Nullable.new(Schema::Boolean.new))
        end
      end

      def deployment_configuration_schema
        Schema::Structure.new.tap do |struct|
          struct.member(:maximum_percent, Schema::Integer.new)
          struct.member(:minimum_healthy_percent, Schema::Integer.new)
        end
      end

      def capacity_provider_strategy_schema
        Schema::Structure.new.tap do |struct|
          struct.member(:capacity_provider, Schema::String.new)
          struct.member(:weight, Schema::WithDefault.new(Schema::Integer.new, 0))
          struct.member(:base, Schema::WithDefault.new(Schema::Integer.new, 0))
        end
      end

      def network_configuration_schema
        Schema::Structure.new.tap do |struct|
          struct.member(:awsvpc_configuration, awsvpc_configuration_schema)
        end
      end

      def awsvpc_configuration_schema
        Schema::Structure.new.tap do |struct|
          struct.member(:subnets, Schema::UnorderedArray.new(Schema::String.new))
          struct.member(:security_groups, Schema::UnorderedArray.new(Schema::String.new))
          struct.member(:assign_public_ip, Schema::WithDefault.new(Schema::String.new, 'DISABLED'))
        end
      end

      def default_configuration
        {
          maximum_percent: 200,
          minimum_healthy_percent: 100,
        }
      end
    end
  end
end
