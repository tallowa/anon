puts "Cleaning databases..."
Identity::User.destroy_all
Identity::Company.destroy_all
Feedback::FeedbackResponse.destroy_all
Feedback::FeedbackRequest.destroy_all
Feedback::AnonymousProfile.destroy_all

puts "Creating companies..."
acme = Identity::Company.create!(
  name: "Acme Corp",
  domain: "acme.com"
)

tech_startup = Identity::Company.create!(
  name: "Tech Startup Inc",
  domain: "techstartup.com"
)

puts "Creating users..."
user1 = Identity::User.create!(
  company: acme,
  email: "john@acme.com",
  password: "password123",
  password_confirmation: "password123",
  job_title: "Software Engineer",
  department: "Engineering",
  email_verified: true
)

user2 = Identity::User.create!(
  company: acme,
  email: "sarah@acme.com",
  password: "password123",
  password_confirmation: "password123",
  job_title: "Product Manager",
  department: "Product",
  email_verified: true
)

puts "Creating anonymous profiles..."
profile1 = Feedback::AnonymousProfile.create!(
  profile_hash: user1.anonymous_profile_id
)

profile2 = Feedback::AnonymousProfile.create!(
  profile_hash: user2.anonymous_profile_id
)

puts "Creating feedback requests..."
request1 = Feedback::FeedbackRequest.create!(
  anonymous_profile: profile1
)

puts "\n=== Setup Complete ==="
puts "User 1: john@acme.com (password: password123)"
puts "User 2: sarah@acme.com (password: password123)"
puts "Feedback URL for User 1: #{request1.shareable_url}"
puts "Token: #{request1.token}"
puts "\nDatabases:"
puts "  Identity: #{Identity::User.connection.current_database}"
puts "  Feedback: #{Feedback::AnonymousProfile.connection.current_database}"
