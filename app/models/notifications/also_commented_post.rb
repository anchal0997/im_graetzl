class Notifications::AlsoCommentedPost < Notification
  # another_user_comments_post: {
  #   triggered_by_activity_with_key: 'post.comment',
  #   bitmask: 32,
  #   receivers: ->(activity) { User.where(id: activity.trackable.comments.includes(:user).pluck(:user_id) - [activity.owner_id]) }
  # },

  # TRIGGER_KEY = 'meeting.create'
  # BITMASK = 1 #TODO autosave right bitmask attribute for new records...
  #
  #
  #
  # def self.receivers(activity)
  #   User.where(graetzl_id: activity.trackable.graetzl_id)
  # end
  #
  # def self.triggered_by?(activity)
  #   activity.key == TRIGGER_KEY
  # end
  #
  # def self.condition(activity)
  #   true
  # end
end
