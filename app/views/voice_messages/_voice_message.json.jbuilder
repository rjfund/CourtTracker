json.extract! voice_message, :id, :url, :user_id, :is_new, :created_at, :updated_at
json.url voice_message_url(voice_message, format: :json)
