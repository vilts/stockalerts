# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_stockalerts_session',
  :secret      => '555297ed8f18293e1feeb600e3abec71cf9cedd935f1906b4e0aa5a70fed4ee92eec0a7a6ab444b9dc0ceb2d45ca4b4508d5a604078530be42450c0a392b68aa'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
