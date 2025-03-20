require 'sinatra'
require_relative '../app/controllers/discounts_controller'

class DiscoOcto < Sinatra::Base
  post '/operation' do
    App::Controllers::DiscountsController.new.calculate_discounts(request)
  end

  post '/submit' do
    App::Controllers::DiscountsController.new.submit_discount(request)
  end
end
