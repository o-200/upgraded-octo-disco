module App::Repositories
  class ProductRepository
    def self.find_by_id(product_id)
      DB[:products].where(id: product_id)
    end
  end
end
