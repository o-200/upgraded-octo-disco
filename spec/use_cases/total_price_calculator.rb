require 'spec_helper'
require_relative '../../app/use_cases/total_price_calculator'
require_relative '../../app/repositories/user_repository'
require_relative '../../app/repositories/operation_repository'

RSpec.describe App::UseCases::TotalPriceCalculator do
  let(:user) { { id: 1, name: 'John Doe' } }
  let(:operation) { { id: 1, total_price: 100.0, total_discount: 10.0 } }
  let(:write_off) { 20.0 }

  before do
    allow(App::Repositories::UserRepository).to receive(:find_by_id).with(1).and_return(user)
    allow(App::Repositories::OperationRepository).to receive(:find_by_id).with(1).and_return(operation)
  end

  it 'calculates the final price and cashback correctly' do
    calculator = described_class.new
    result = JSON.parse(calculator.call(1, 1, write_off), symbolize_names: true)

    expect(result[:status]).to eq('success')
    expect(result[:message]).to eq('Operation confirmed')
    expect(result[:operation][:user_id]).to eq(1)
    expect(result[:operation][:earned_cashback]).to eq(4.0)
    expect(result[:operation][:total_discount]).to eq(10.0)
    expect(result[:operation][:used_points]).to eq(write_off)
    expect(result[:operation][:final_price]).to eq(80.0)
  end

  it 'returns an error if user is not found' do
    allow(App::Repositories::UserRepository).to receive(:find_by_id).with(1).and_return(nil)

    calculator = described_class.new
    result = JSON.parse(calculator.call(1, 1, write_off), symbolize_names: true)

    expect(result[:code]).to eq(404)
    expect(result[:status]).to eq('Not Found')
    expect(result[:details]).to eq('User not found')
  end

  it 'returns an error if operation is not found' do
    allow(App::Repositories::OperationRepository).to receive(:find_by_id).with(1).and_return(nil)

    calculator = described_class.new
    result = JSON.parse(calculator.call(1, 1, write_off), symbolize_names: true)

    expect(result[:code]).to eq(404)
    expect(result[:status]).to eq('Not Found')
    expect(result[:details]).to eq('Operation not found')
  end
end
