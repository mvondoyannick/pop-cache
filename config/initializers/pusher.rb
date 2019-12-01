# config/initializers/pusher.rb
require 'pusher'

Pusher.app_id = '910003'
Pusher.key = '4c8feee7978c479c1da3'
Pusher.secret = '2d1f003f9e56e9aa38b7'
Pusher.cluster = 'eu'
Pusher.logger = Rails.logger
Pusher.encrypted = true