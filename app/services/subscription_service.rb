class SubscriptionService
  def self.create_checkout_session(company:, price_id:, success_url:, cancel_url:)
    # Ensure company has a Stripe customer
    company.create_stripe_customer! unless company.stripe_customer_id
    
    Stripe::Checkout::Session.create(
      customer: company.stripe_customer_id,
      mode: 'subscription',
      line_items: [{
        price: price_id,
        quantity: 1
      }],
      success_url: success_url,
      cancel_url: cancel_url,
      subscription_data: {
        trial_period_days: 14,
        metadata: {
          company_id: company.id
        }
      },
      metadata: {
        company_id: company.id
      }
    )
  end
  
  def self.update_subscription_from_stripe(stripe_subscription)
    company = Identity::Company.find_by(stripe_customer_id: stripe_subscription.customer)
    return unless company
    
    # Determine tier from price
    tier = tier_from_price_id(stripe_subscription.items.data.first.price.id)
    
    company.update!(
      subscription_tier: tier,
      stripe_subscription_id: stripe_subscription.id,
      subscription_status: stripe_subscription.status,
      trial_ends_at: stripe_subscription.trial_end ? Time.at(stripe_subscription.trial_end) : nil,
      subscription_ends_at: stripe_subscription.current_period_end ? Time.at(stripe_subscription.current_period_end) : nil
    )
  end
  
  def self.cancel_subscription(company)
    return unless company.stripe_subscription_id
    
    subscription = Stripe::Subscription.update(
      company.stripe_subscription_id,
      cancel_at_period_end: true
    )
    
    company.update!(subscription_status: 'canceling')
    subscription
  end
  
  private
  
  def self.tier_from_price_id(price_id)
    Identity::Company::TIERS.each do |tier, data|
      return tier if data[:price_id] == price_id
    end
    'free'
  end
end
