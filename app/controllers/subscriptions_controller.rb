class SubscriptionsController < ApplicationController
  before_action :require_login
  
  def create
    # Get the price_id from params (pro or team)
    tier = params[:tier]
    price_id = Identity::Company::TIERS.dig(tier, :price_id)
    
    unless price_id
      redirect_to pricing_path, alert: "Invalid subscription tier"
      return
    end
    
    # Create Stripe Checkout Session
    session = SubscriptionService.create_checkout_session(
      company: current_user.company,
      price_id: price_id,
      success_url: subscription_success_url,
      cancel_url: pricing_url
    )
    
    redirect_to session.url, allow_other_host: true
  rescue Stripe::StripeError => e
    redirect_to pricing_path, alert: "Payment error: #{e.message}"
  end
  
  def success
    # Show success page
  end
  
  def cancel
    redirect_to pricing_path, notice: "Subscription cancelled"
  end
  
  def billing_portal
    # Create billing portal session
    portal_session = Stripe::BillingPortal::Session.create(
      customer: current_user.company.stripe_customer_id,
      return_url: dashboard_url
    )
    
    redirect_to portal_session.url, allow_other_host: true
  rescue Stripe::StripeError => e
    redirect_to dashboard_path, alert: "Error: #{e.message}"
  end
end
