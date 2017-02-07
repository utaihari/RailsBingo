json.extract! change_log, :id, :body, :log_type, :created_at, :updated_at
json.url change_log_url(change_log, format: :json)