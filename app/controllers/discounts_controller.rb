require_relative 'application_controller'
require_relative '../use_cases/discount_calculator'
require_relative '../use_cases/total_price_calculator'

module App
  module Controllers
    # напрашивается presenter layer (использование например gem alba https://github.com/okuramasafumi/alba),
    # но я не стал его добавлять, чтобы не усложнять задачу
    class DiscountsController < ApplicationController
      def calculate_discounts(request)
        params = parse_req_body(request)

        user_id   = params[:user_id]
        positions = params[:positions]

        UseCases::DiscountCalculator.new.call(positions, user_id)
      end

      def submit_discount(params)
        params = parse_req_body(request)

        user_id      = params[:user][:id]
        operation_id = params[:operation_id]
        write_off    = params[:write_off]

        UseCases::TotalPriceCalculator.new.call(user_id, operation_id, write_off)
      end
    end
  end
end
