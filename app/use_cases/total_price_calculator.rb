require_relative '../repositories/product_repository'
require_relative '../repositories/user_repository'


module App
  module UseCases
    class TotalPriceCalculator
      def call(user_id, operation_id, write_off)
        user = Repositories::UserRepository.find_by_id(user_id).first
        return { code: 404, status: 'Not Found', details: "User not found" }.to_json unless user

        operation = Repositories::OperationRepository.find_by_id(operation_id)
        return { code: 404, status: 'Not Found', details: "Operation not found" }.to_json unless operation

        final_price = operation[:total_price] - write_off
        final_cashback = (final_price * 0.05).round(2)

        {
          status: 'success',
          message: 'Operation confirmed',
          operation: {
            user_id: user_id,
            earned_cashback: final_cashback,
            total_discount: operation[:total_discount],
            used_points: write_off,
            final_price: final_price
          }
        }.to_json
      end
    end
  end
end
