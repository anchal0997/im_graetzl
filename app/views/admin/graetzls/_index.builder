context.instance_eval do
  selectable_column
  id_column
  column :name
  column(:state){|g| status_tag(g.state) }
  column :slug
  column :updated_at
  column('#Users'){ |g| g.users.count }
  actions
end