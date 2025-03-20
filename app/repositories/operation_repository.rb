module App::Repositories
  class OperationRepository
    def self.find_by_id(operation_id)
      DB[:operations].where(id: operation_id)
    end
  end
end
