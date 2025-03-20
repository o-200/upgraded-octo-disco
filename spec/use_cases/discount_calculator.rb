require 'spec_helper'
require_relative '../../app/use_cases/discount_calculator'
require_relative '../../app/repositories/product_repository'
require_relative '../../app/repositories/user_repository'
require_relative '../../app/repositories/template_repository'

RSpec.describe App::UseCases::DiscountCalculator do
  let(:user) { { id: 1, name: 'John Doe', template_id: 1 } }
  let(:template) { 'Gold' }
  let(:products) do
    [
      { id: 1, type: 'discount', price: 100 },
      { id: 2, type: 'increased_cashback', price: 200 }
    ]
  end
  let(:positions) do
    [
      { id: 1, price: 100, quantity: 2 },
      { id: 2, price: 200, quantity: 1 }
    ]
  end

  before do
    allow(Repositories::UserRepository).to receive(:find_by_id).with(1).and_return(user)
    allow(Repositories::TemplateRepository).to receive(:find_by_user).with(user).and_return(template)
    allow(Repositories::ProductRepository).to receive(:find_by_id).with([1, 2]).and_return(products)
  end

  it 'calculates the discount and cashback correctly' do
    calculator = described_class.new
    result = JSON.parse(calculator.call(positions, 1), symbolize_names: true)

    expect(result[:status]).to eq('success')
    expect(result[:user][:id]).to eq(1)
    expect(result[:total_price]).to eq(360.0)
    expect(result[:total_discount]).to eq(40.0)
    expect(result[:total_cashback]).to eq(15.0)
    expect(result[:positions].size).to eq(2)

    expect(result[:positions][0][:id]).to eq(1)
    expect(result[:positions][0][:final_price]).to eq(180.0)

    expect(result[:positions][1][:id]).to eq(2)
    expect(result[:positions][1][:final_price]).to eq(180.0)
  end

  it 'returns an error if user is not found' do
    allow(Repositories::UserRepository).to receive(:find_by_id).with(1).and_return(nil)

    calculator = described_class.new
    result = JSON.parse(calculator.call(positions, 1), symbolize_names: true)

    expect(result[:status]).to eq('error')
    expect(result[:message]).to eq('User not found')
  end

  it 'returns an error if product is not found' do
    allow(Repositories::ProductRepository).to receive(:find_by_id).with([1, 2]).and_return([])

    calculator = described_class.new
    result = JSON.parse(calculator.call(positions, 1), symbolize_names: true)

    expect(result[:positions].size).to eq(2)
    expect(result[:positions][0][:status]).to eq('Not Found')
    expect(result[:positions][1][:status]).to eq('Not Found')
  end
end
