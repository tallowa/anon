module Identity
  class Invite < Base
    self.table_name = "invites"
    
    belongs_to :company
    belongs_to :invited_by, class_name: 'User'
    
    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :token, presence: true, uniqueness: true
    validates :expires_at, presence: true
    
    validate :email_matches_company_domain
    
    before_validation :generate_token, on: :create
    before_validation :set_expiration, on: :create
    
    scope :pending, -> { where(accepted: false).where('expires_at > ?', Time.current) }
    scope :expired, -> { where('expires_at <= ?', Time.current) }
    
    def expired?
      expires_at <= Time.current
    end
    
    def accept!(user)
      update!(accepted: true, accepted_at: Time.current)
    end
    
    private
    
    def generate_token
      self.token = SecureRandom.urlsafe_base64(32)
    end
    
    def set_expiration
      self.expires_at = 7.days.from_now
    end
    
    def email_matches_company_domain
      return unless email.present? && company.present?
      
      unless email.end_with?(company.email_domain)
        errors.add(:email, "must be from #{company.email_domain}")
      end
    end
  end
end
