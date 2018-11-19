class DummyMailer < ApplicationMailer
  def dummy_mailer
    @test_value = "I'm a working mailer"

    mail(to: ENV['RECIPIENT'], subject: 'Welcome!')
  end
end
