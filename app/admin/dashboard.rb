ActiveAdmin.register_page "Dashboard" do
  menu priority: 1

  content title: proc{ I18n.t("active_admin.dashboard") } do

    columns do
      column do
        panel 'Offene Location Anfragen' do
          table_for Location.all_pending.order(updated_at: :asc) do
            column(:location, sortable: :name) do |location|
              link_to location.name, admin_location_path(location)
            end
            column('User') do |location|
              location.users.each do |user|
                a user.username, href: admin_user_path(user)
                text_node ', '.html_safe
              end
            end
            column('Erstellt', :updated_at)
            column('status') { |location| status_tag(location.state) }
          end

          span do
            link_to 'Anfragen Bearbeiten', '/admin/locations?scope=pending'
          end
        end

        panel 'Offene Inhaber Anfragen' do
          table_for LocationOwnership.all_pending.order(updated_at: :asc) do
            column(:location) do |ownership|
              link_to ownership.location.name, admin_location_path(ownership.location)
            end
            column(:user) do |ownership|
              link_to ownership.user.username, admin_user_path(ownership.user_id)
            end
            column('Erstellt', :updated_at)
            column('status') { |ownership| status_tag(ownership.state) }
          end

          span do
            link_to 'Anfragen Bearbeiten', '/admin/location_ownerships?scope=pending'
          end
        end
      end

      column do
        panel 'Neue Adressen' do
          'soon to come...'
        end
      end
    end
  end
end