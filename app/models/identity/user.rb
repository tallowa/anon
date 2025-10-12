module Identity
  class User < Base
    self.table_name = "users"
    
    belongs_to :company
    has_many :verification_tokens, dependent: :destroy
    has_many :sent_invites, class_name: 'Invite', foreign_key: 'invited_by_id', dependent: :destroy
    
    has_secure_password
    
    validates :email_hash, presence: true, uniqueness: true
    validates :password, length: { minimum: 8 }, if: :password_digest_changed?
    
    attr_accessor :email
    
    validates :email, presence: true, on: :create
    validate :email_matches_company_domain, on: :create
    
    def anonymous_profile_id
      Digest::SHA256.hexdigest([
        id,
        created_at.to_i,
        Rails.application.secret_key_base
      ].join('-'))
    end
    
    def create_email_verification_token
      verification_tokens.email_verification.create!(token_type: 'email_verification')
    end
    
    before_validation :hash_email, on: :create
    
    private
    
    def hash_email
      return unless email.present?
      self.email_hash = BCrypt::Password.create(email)
    end
    
    def email_matches_company_domain
      return unless email.present?
      unless email.end_with?(company.email_domain)
        errors.add(:email, "must be from #{company.email_domain}")
      end
    end
  end
end
