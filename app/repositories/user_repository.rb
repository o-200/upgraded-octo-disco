module App::Repositories
  class UserRepository
    def self.find_by_id(user_id)
      DB[:users].where(id: user_id)
    end
  end
end
