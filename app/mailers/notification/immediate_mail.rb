class Notification::ImmediateMail
  include MailUtils

  def initialize(notification)
    @notification = notification
    @user = @notification.user
  end

  def deliver
    MandrillMailer.deliver template: template, message: message
  end

  private

  attr_reader :notification, :user

  def template
    @notification.mail_template
  end

  def message
    {
      to: [ { email: @user.email } ],
      from_email: FROM_EMAIL,
      from_name: FROM_NAME,
      subject: @notification.mail_subject,
      global_merge_vars: global_vars,
      merge_vars: [
        rcpt: @user.email,
        vars: @notification.basic_mail_vars + [
          { name: 'notification', content: @notification.mail_vars }
        ]
      ]
    }
  end

  def global_vars
    [
      { name: 'username', content: @user.username },
      { name: 'edit_user_url', content: edit_user_url(URL_OPTIONS) },
      { name: 'graetzl_name', content: @user.graetzl.name },
      { name: 'graetzl_url', content: graetzl_url(@user.graetzl, URL_OPTIONS) }
    ]
  end
end
