class Notifications::NewMeeting < Notification

  TRIGGER_KEY = 'meeting.create'
  BITMASK = 1

  def self.receivers(activity)
    User.where(graetzl_id: activity.trackable.graetzl_id)
  end

  def mail_vars
    {
      owner_name: activity.owner.username,
      owner_url: user_url(activity.owner, DEFAULT_URL_OPTIONS),
      owner_avatar_url: ApplicationController.helpers.attachment_url(activity.owner, :avatar, :fill, 40, 40, fallback: "avatar/user/40x40.png", host: "http://#{DEFAULT_URL_OPTIONS[:host]}"),
      meeting_name: activity.trackable.name,
      meeting_url: graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, DEFAULT_URL_OPTIONS),
      meeting_starts_at_date: activity.trackable.starts_at_date ? I18n.localize(activity.trackable.starts_at_date, format:'%A %d. %B') : '',
      meeting_starts_at_time: activity.trackable.starts_at_time ? I18n.localize(activity.trackable.starts_at_time, format:'%H:%M') : '',
      meeting_description: activity.trackable.description.truncate(300, separator: ' ')
    }
  end

  def mail_subject
    "Neues Treffen im Grätzl #{activity.trackable.graetzl.name}"
  end
end
