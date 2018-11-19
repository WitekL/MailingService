class MailerService
  def call(params = {})
    @mailer = params[:mailer]
    @failures = 0

    begin
      send_mail(@mailer)
    rescue *FAILURES => e
      return { status: 'failed', msg: e }
    end

    return { status: 'success', msg: nil }
  end

  private

  def send_mail(mailer)
    mailer.deliver

  rescue *FAILURES => e
    @failures += 1
    override_settings(mailer) if @failures == 3

    retry if @failures < 6

    raise e if @failures >= 6
  end

  def override_settings(mailer)
    mailer.delivery_method.settings.merge!(FAILOVER_PARAMS)
  end

  FAILOVER_PARAMS = {
    port:                 ENV['MAILGUN_SMTP_PORT'],
    domain:               'none',
    address:              ENV['MAILGUN_SMTP_SERVER'],
    password:             ENV['MAILGUN_SMTP_PASSWORD'],
    user_name:            ENV['MAILGUN_SMTP_LOGIN'],
    authentication:       :plain
  }.freeze

  FAILURES = [
    Net::SMTPFatalError,
    Net::SMTPSyntaxError,
    Net::SMTPAuthenticationError,
    Net::OpenTimeout,
    Net::SMTPServerBusy,
    Errno::ECONNRESET,
    Errno::ECONNREFUSED,
    Errno::ETIMEDOUT,
    Timeout::Error,
    EOFError
  ].freeze
end
