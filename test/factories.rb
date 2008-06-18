Factory.sequence :email do |n|
  "person#{n}@example.com" 
end

Factory.define :user do |u|
  u.password "Sup3r"
  u.password_confirmation "Sup3r"
  u.login "JDough"
  u.email { Factory.next :email }
end

# DEFINITION EXAMPLES

# This will guess the User class
# Factory.define :user do |u|
#   u.first_name 'John'
#   u.last_name  'Doe'
#   u.admin false
#   u.activation_code { User.generate_activation_code }
#   u.email {|a| "#{a.first_name}.#{a.last_name}@example.com".downcase }
# end

# This will use the User class (Admin would have been guessed)
# Factory.define :admin, :class => User do |u|
#   u.first_name 'Admin'
#   u.last_name  'User'
#   u.admin true
# end

# Factory.define :post do |p|
#   # ...
#   p.author {|author| author.association(:user, :last_name => 'Writely') }
# end


# SEQUENCES

# Defines a new sequence
# Factory.sequence :email do |n|
#   "person#{n}@example.com" 
# end
# Factory.next :email
# # => "person1@example.com" 
# 
# Factory.next :email
# # => "person2@example.com"


# USAGE EXAMPLES

# # Builds and saves a User and a Post
# post = Factory(:post)
# post.new_record?       # => false
# post.author.new_record # => false
# 
# # Builds but does not save a User and a Post
# Factory.build(:post)
# post.new_record?       # => true
# post.author.new_record # => true



# # Build and save a User instance
# Factory(:user)
# 
# Factory(:user, :last_name => 'Doe').email
#
# # Build a User instance and override the first_name property
# Factory.build(:user, :first_name => 'Joe')
# 
# # Return an attributes Hash that can be used to build a User instance
# attrs = Factory.attributes_for(:user)