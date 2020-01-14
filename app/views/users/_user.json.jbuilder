json.extract! user, :id, :name, :second_name, :phone, :cni, :ville, :password, :created_at, :updated_at
json.url user_url(user, format: :json)
