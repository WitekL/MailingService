class MailingController < ApplicationController
  def send_mail
    result = MailerService.new.call(mailer: DummyMailer.dummy_mailer)

    render json: { status: result[:status], msg: result[:msg] }
  end
end
