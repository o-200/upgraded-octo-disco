module App::Repositories
  class TemplateRepository
    def self.find_by_user(user)
      DB[:templates].where(id: user[:template_id])
    end
  end
end
