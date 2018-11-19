class DummyMailer < ApplicationMailer
  def dummy_mailer
    @test_value = "I'm a working mailer"

    mail(to: 'witold.leicht@gmail.com', subject: 'Welcome!')
  end
end
