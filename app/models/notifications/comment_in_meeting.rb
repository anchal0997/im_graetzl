class Notifications::CommentInMeeting < Notification
  TRIGGER_KEY = 'meeting.comment'
  BITMASK = 2**4

  def self.receivers(activity)
    activity.trackable.users
  end

  def self.description
    "Meine erstellten Inhalte wurden kommentiert"
  end

  def mail_vars
    {
      meeting_name: activity.trackable.name,
      meeting_url: graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, DEFAULT_URL_OPTIONS),
      comment_url: graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, DEFAULT_URL_OPTIONS),
      comment_content: activity.recipient.content.truncate(300, separator: ' '),
      owner_name: activity.owner.username,
      owner_url: user_url(activity.owner, DEFAULT_URL_OPTIONS),
      owner_avatar_url: Notifications::AvatarService.new(activity.owner).call
    }
  end

  def mail_subject
    "Neuer Kommentar bei einem Treffen"
  end
end
