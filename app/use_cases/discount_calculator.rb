require_relative '../repositories/product_repository'
require_relative '../repositories/user_repository'
require_relative '../repositories/template_repository'

module App
  module UseCases
    class DiscountCalculator
      def call(positions, user_id)
        user = Repositories::UserRepository.find_by_id(user_id)
        return { status: 'error', message: 'User not found' }.to_json unless user

        loyalty_level = Repositories::TemplateRepository.find_by_user(user)

        response_positions = []
        total_price = 0
        total_discount = 0
        total_cashback = 0

        # preload products to avoid n+1
        products_ids = positions.map { |pos| pos[:id] }
        products = Repositories::ProductRepository.find_by_id(products_ids).to_a

        positions.each do |pos|
          product = products[pos[:id]]

          unless product
            response_positions << { code: 404, status: 'Not Found', details: "Product with position: #{pos[:id]} not found" }
            next
          end

          base_price = pos[:price] * pos[:quantity]
          discount   = 0
          cashback   = 0

          discount = if product[:type] == 'discount' || %w[Gold Silver].include?(loyalty_level)
                      base_price * 0.1
                    else
                      0
                    end

          cashback = if product[:type] == 'increased_cashback' || loyalty_level == 'Gold'
                      base_price * 0.05
                    else
                      0
                    end

          total_price += base_price - discount
          total_discount += discount
          total_cashback += cashback

          final_price = base_price - discount

          response_positions << {
            id:          pos[:id],
            price:       pos[:price],
            quantity:    pos[:quantity],
            discount:    discount,
            cashback:    cashback,
            final_price: final_price
          }
        end

        {
          status:         'success',
          user:           user,
          total_price:    total_price,
          total_discount: total_discount,
          total_cashback: total_cashback,
          positions:      response_positions
        }.to_json
      end
    end
  end
end
