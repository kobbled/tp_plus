module TPPlus
  module Nodes
    class PositionDataNode < BaseNode
      attr_reader :hash
      def initialize(hash)
        @hash = hash
        @ids  = []
      end

      def valid?
        return false unless @hash[:positions].is_a?(Array)
        return false if @hash[:positions].map {|p| position_valid?(p) == false }.any?

        true
      end

      def position_valid?(position_hash)
        return false if @ids.include?(position_hash[:id])
        @ids.push(position_hash[:id])

        return false unless position_hash[:mask].is_a? Array

        position_hash[:mask].select {|q|
          !mask_valid?(q)
        }.empty?
      end

      def mask_valid?(position_hash)
        return false unless position_hash[:group].is_a?(Integer)
        return false unless position_hash[:uframe].is_a?(Integer)
        return false unless position_hash[:utool].is_a?(Integer)

        if position_hash[:config].is_a?(Hash)
          return false unless boolean?(position_hash[:config][:flip])
          return false unless boolean?(position_hash[:config][:up])
          return false unless boolean?(position_hash[:config][:top])
          return false unless position_hash[:config][:turn_counts].is_a?(Array)
          return false unless position_hash[:config][:turn_counts].length == 3
          return false if position_hash[:config][:turn_counts].map {|tc| tc.is_a?(Integer) == false }.any?
          return false unless position_hash[:components].is_a?(Hash)
          [:x,:y,:z,:w,:p,:r].each do |component|
            return false unless position_hash[:components][component].is_a?(Float)
          end
        else
          # must be joint representation
          return false unless position_hash[:components].is_a?(Hash)
          position_hash[:components].each do |component|
            return false unless component[1].is_a?(Float)
          end
        end

        true
      end

      def boolean?(thing)
        thing.is_a?(TrueClass) || thing.is_a?(FalseClass)
      end

      def eval(context, options={})
        raise "Invalid position data" unless valid?
        context.position_data = @hash
        nil
      end
    end
  end
end
