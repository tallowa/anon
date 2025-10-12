module Identity
  class VerificationToken < Base
    self.table_name = "verification_tokens"
    
    belongs_to :user
    
    validates :token, presence: true, uniqueness: true
    validates :token_type, presence: true
    validates :expires_at, presence: true
    
    before_validation :generate_token, on: :create
    before_validation :set_expiration, on: :create
    
    scope :email_verification, -> { where(token_type: 'email_verification') }
    scope :password_reset, -> { where(token_type: 'password_reset') }
    scope :unused, -> { where(used: false) }
    scope :valid_tokens, -> { unused.where('expires_at > ?', Time.current) }
    
    def expired?
      expires_at <= Time.current
    end
    
    def mark_as_used!
      update!(used: true)
    end
    
    private
    
    def generate_token
      self.token = SecureRandom.urlsafe_base64(32)
    end
    
    def set_expiration
      self.expires_at = case token_type
      when 'email_verification'
        24.hours.from_now
      when 'password_reset'
        2.hours.from_now
      else
        24.hours.from_now
      end
    end
  end
end
