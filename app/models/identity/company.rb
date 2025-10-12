module Identity
  class Company < Base
    self.table_name = "companies"
    
    has_many :users, dependent: :destroy
    has_many :invites, dependent: :destroy
    
    validates :name, presence: true
    validates :domain, presence: true, uniqueness: true
    validates :domain, format: { with: /\A[a-z0-9-]+\.[a-z]{2,}\z/i }
    
    def email_domain
      "@#{domain}"
    end
    
    def can_add_users?
      users.count < max_users
    end
  end
end
