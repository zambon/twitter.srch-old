# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_twitter_search_app_session',
  :secret      => '151c3e54a6870d85662dd819db79c292a056601f20a42ac732e3d291d1e1752775a4d8d0cee8ad99434a404e64db3138ef2699798c74e2b49e77278b7198fadc'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
