module OrderQuery
  module SQL
    class OrderBy
      attr_reader :space

      # @param [Array<Condition>]
      def initialize(space)
        @space = space
      end

      # @return [String]
      def build
        join_order_by_clauses order_by_sql_clauses
      end

      # @return [String]
      def build_reverse
        join_order_by_clauses order_by_reverse_sql_clauses
      end

      protected

      # @return [Array<String>]
      def order_by_sql_clauses
        space.conditions.map { |cond|
          if cond.order_enum
            cond.order_enum.map { |v|
              "#{cond.sql.column_name}=#{cond.sql.quote v} #{cond.order.to_s.upcase}"
            }.join(', ').freeze
          else
            "#{cond.sql.column_name} #{sort_direction_sql cond.order}".freeze
          end
        }
      end

      SORT_DIRECTIONS = [:asc, :desc].freeze
      # @return [String]
      def sort_direction_sql(direction)
        if SORT_DIRECTIONS.include?(direction)
          direction.to_s.upcase.freeze
        else
          raise ArgumentError.new("sort direction must be in #{SORT_DIRECTIONS.map(&:inspect).join(', ')}, is #{direction.inspect}")
        end
      end

      # @param [Array<String>] clauses
      def join_order_by_clauses(clauses)
        clauses.join(', ').freeze
      end

      # @return [Array<String>]
      def order_by_reverse_sql_clauses
        swap = {'DESC' => 'ASC', 'ASC' => 'DESC'}
        order_by_sql_clauses.map { |s|
          s.gsub(/DESC|ASC/) { |m| swap[m] }
        }
      end
    end
  end
end