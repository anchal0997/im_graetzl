class Notifications::NewWallComment < Notification
  TRIGGER_KEY = 'user.comment'
  BITMASK = 2**10

  def self.receivers(activity)
    User.where(id: activity.trackable.id)
  end

  def self.condition(activity)
    activity.owner.present? && activity.recipient.present?
  end

  def self.description
    'Die Pinnwand auf meinem Profil hat einen neuen Kommentar'
  end

  def mail_vars
    {
      comment_url: graetzl_user_url(activity.trackable.graetzl, activity.trackable, DEFAULT_URL_OPTIONS) + "#comment-#{activity.recipient.id}",
      comment_content: activity.recipient.content.truncate(300, separator: ' '),
      owner_name: activity.owner.username,
      owner_url: user_url(activity.owner, DEFAULT_URL_OPTIONS),
      owner_avatar_url: Notifications::AvatarService.new(activity.owner).call
    }
  end

  def mail_subject
    'Neuer Beitrag an deiner Pinnwand'
  end
end
