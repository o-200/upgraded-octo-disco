require 'sinatra'

class DiscoOcto < Sinatra::Base
  def get_user(user_id)
    DB[:users].where(id: user_id).first
  end

  def get_user_template(user)
    DB[:templates].where(id: user[:template_id]).first
  end

  def get_product(product_id)
    DB[:products].where(id: product_id).first
  end

  post '/operation' do
    body = JSON.parse(request.body.read, symbolize_names: true)
    user_id   = body[:user_id]
    positions = body[:positions]

    user = get_user(user_id)
    return { status: 'error', message: 'User not found' }.to_json unless user

    loyalty_level = get_user_template(user)
    total_price = 0
    total_discount = 0
    total_cashback = 0
    response_positions = []

    # preload products to avoid n+1
    products_ids = positions.map { |pos| pos[:id] }
    products = DB[:products].where(id: products_ids).to_a

    positions.each do |pos|
      product = products[pos[:id]]

      unless product
        return { code: 404, status: 'Not Found', details: "Product with position: #{pos[:id]} not found" }.to_json
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
        id: pos[:id],
        price: pos[:price],
        quantity: pos[:quantity],
        discount: discount,
        cashback: cashback,
        final_price: final_price
      }
    end

    {
      status: 'success',
      user: user,
      total_price: total_price,
      total_discount: total_discount,
      total_cashback: total_cashback,
      positions: response_positions
    }.to_json
  end

  # Confirm operation and apply bonus points
  post '/submit' do
    request_payload = JSON.parse(request.body.read, symbolize_names: true)
    user_id = request_payload[:user][:id]
    operation_id = request_payload[:operation_id]
    write_off = request_payload[:write_off].to_f

    user = get_user(user_id)
    return { code: 404, status: 'Not Found', details: "User not found" }.to_json unless user

    operation = DB[:operations].where(id: operation_id).first
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
