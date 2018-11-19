require 'rails_helper'

describe MailerService do
  let(:mailer) { DummyMailer.dummy_mailer }
  let(:failover_params) do
    {
      port:                 ENV['MAILGUN_SMTP_PORT'],
      domain:               'none',
      address:              ENV['MAILGUN_SMTP_SERVER'],
      password:             ENV['MAILGUN_SMTP_PASSWORD'],
      user_name:            ENV['MAILGUN_SMTP_LOGIN'],
      authentication:       :plain
    }
  end
  let(:wrong_params) do
    {
      password:             'wrong_password',
    }
  end

  describe 'When the first service is fully operational' do
    it 'sends the email and returns success' do
      result = MailerService.new.call(mailer: mailer)

      expect(result).to eq({ status: 'success', msg: nil })
    end
  end

  describe 'When the first service is down and second one is operational' do
    it 'sends the email and returns success' do
      mailer.delivery_method.settings.merge!(wrong_params)
      result = MailerService.new.call(mailer: mailer)

      expect(result).to eq({ status: 'success', msg: nil })
    end
  end
end
