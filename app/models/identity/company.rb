module Identity
  class Company < Base
    self.table_name = "companies"
    
    has_many :users, dependent: :destroy
    has_many :invites, dependent: :destroy
    
    validates :name, presence: true
    validates :email_domain, presence: true, uniqueness: true
    
    before_validation :normalize_and_sync_domain
    
    # Check if an email belongs to this company's domain
    def owns_email?(email)
      email.to_s.downcase.end_with?("@#{email_domain}")
    end
    
    private
    
    def normalize_and_sync_domain
      if email_domain.present?
        # Normalize
        self.email_domain = email_domain.to_s.downcase.strip.gsub(/^@/, '')
        # Sync to domain column
        self.domain = self.email_domain
      end
    end
  end
end
