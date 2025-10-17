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

     # Subscription tiers
    TIERS = {
      'free' => {
        name: 'Individual',
        price: 0,
        max_active_requests: 1,
        max_responses_per_month: 10,
        features: ['basic_analytics', '7_day_history']
      },
      'pro' => {
        name: 'Professional',
        price: 15,
        price_id: 'price_test_pro', # We'll create this in Stripe dashboard
        max_active_requests: nil, # unlimited
        max_responses_per_month: nil, # unlimited
        features: ['basic_analytics', 'custom_questions', 'exports', 'sentiment_analysis', '90_day_history']
      },
      'team' => {
        name: 'Team',
        price: 49,
        price_id: 'price_test_team', # We'll create this in Stripe dashboard
        max_active_requests: nil,
        max_responses_per_month: nil,
        features: ['everything_in_pro', 'unlimited_members', 'team_dashboard', 'theme_extraction', 'unlimited_history']
      },
      'enterprise' => {
        name: 'Enterprise',
        price: nil, # custom pricing
        max_active_requests: nil,
        max_responses_per_month: nil,
        features: ['everything_in_team', 'sso', 'custom_domain', 'api_access', 'white_label']
      }
    }.freeze
    
    # Check if company has access to a feature
    def has_feature?(feature)
      tier_features = TIERS.dig(subscription_tier, :features) || []
      tier_features.include?(feature.to_s) || tier_features.include?('everything_in_pro') || tier_features.include?('everything_in_team')
    end
    
    # Check if subscription is active
    def subscription_active?
      return true if subscription_tier == 'free'
      return false if subscription_status.nil?
      
      ['active', 'trialing'].include?(subscription_status)
    end
    
    # Check if on trial
    def on_trial?
      trial_ends_at.present? && trial_ends_at > Time.current
    end
    
    # Get tier name
    def tier_name
      TIERS.dig(subscription_tier, :name) || 'Free'
    end
    
    # Check if can create more requests
    def can_create_request?
      max = TIERS.dig(subscription_tier, :max_active_requests)
      return true if max.nil? # unlimited
      
      active_requests_count = users.joins('INNER JOIN feedback_requests ON feedback_requests.anonymous_profile_id IN (SELECT profile_hash FROM anonymous_profiles WHERE anonymous_profiles.profile_hash IN (SELECT anonymous_profile_id FROM users WHERE users.company_id = companies.id))')
        .where('feedback_requests.archived = false')
        .count
      
      active_requests_count < max
    end
    
    # Create Stripe customer
    def create_stripe_customer!
      return if stripe_customer_id.present?
      
      customer = Stripe::Customer.create(
        email: users.first&.email,
        name: name,
        metadata: {
          company_id: id
        }
      )
      
      update!(stripe_customer_id: customer.id)
      customer
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
