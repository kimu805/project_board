json.extract! project, :id, :name, :client_name, :unit_price, :work_style, :start_date, :end_date, :tech_stack, :status, :created_at, :updated_at
json.url project_url(project, format: :json)
