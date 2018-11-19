# Mailing service written in Ruby on Rails API

This service provides an abstraction allowing the usage of two (or more) independent mailing solutions. The following
code is just a PoC with a lot of room for improvement.

Relevant code written by me can be found in:
https://github.com/WitekL/MailingTest/blob/master/app/services/mailer_service.rb
https://github.com/WitekL/MailingTest/blob/master/app/controllers/mailing_controller.rb
https://github.com/WitekL/MailingTest/blob/master/app/mailers/dummy_mailer.rb
https://github.com/WitekL/MailingTest/blob/master/spec/services/mailer_service_spec.rb

The main goal of this project was to create a failsafe in case the primary service fails. It was written with
microservice architecture in mind and thus uses the API verion of Rails. Live version of the app was deployed to Heroku.
To use this service one must only send a post request to:

https://mailer-service-smc.herokuapp.com/mail

No params, nor authentication is needed as it is only a PoC application. Unfortunately, due to the limitations of
sandbox environment in Mailgun, I will be the only recipient of the emails sent using this service.

Solution to this problem consists of three elements: a controller action, a mailer and a service object. Controller is
responsible for processing the HTTP request sent by an external service. Mailer is a variant of a controller that's
responsible for dispatching emails. And finally, service object is a Ruby specific design pattern that was conceived as
a refactoring method to keep the MVC architecture clean. The last piece of this app is where the most important things
are happening.

The MailerService object accepts a hash of parameters. Thanks to that one can easily extend this service object just by
passing the desired parameters within a hash and then using them inside the instance. In case of the code that I've
written, the only parameter being passed is the mailer which will be used for dispatching emails. Thanks to using DI
pattern, this service object can be reused with many different mailers. The only constraint right now is that it has to
respond to `deliver` message, as it can be seen in line no. 18. The `send_mail` method takes the mailer as an input
parameter and calls deliver method on it. In case of an email-related failure, an error is being rescued in the next
line of code. Inside the rescue block the code is checking the `@failures` counter for the value that it contains.
Depending on that value it will either retry sending the emails, change the mailing service provider or finally reraise
the exception to notify the extarnal service about a problem with both of the services.

In this service object one of Rails limitations occurs. In method `override_settings` in line 29 I'm overriding the
settings for the instance of the mailer. This is a very unclean and ugly way to do it. My first thought was to create a
separate mailer class for each of the service providers, unfortunatelly, when defining these settings on the level of
a mailer class it overwrites these settings for all mailers found withing the application. Parameters for the secondary
service are stored in a hash below the method. However, for the sake of future development it would be probably better
to create a value object that would store the settings for different services. This way it would be easy to manage more
than two providers.

The last part of this service object is the error handling. At the very bottom of the class an array of error classes
can be found. I'm using this array with a splat operator in lines no. 8 and 20 to get a list of classes. Thanks to this
approach I can handle a lot of email and network related issues without cluttering the code with a long list of classes
near the rescue statement. Depending on the outcome of the service's action, a hash will be returned consisting of a
status and a message if one occured.

I have written only two test cases for this service because of lack of time. In the first test case I
check whether the first mailer is working, while in the second one I merge invalid password to the mailer instance
configuration to check whether the second mailing service will succeed with email dispatch. For the third case a big
difficulty here was to stub the env variables for the failover option to test a failure of both services. This was
caused by the hardcoded parameters for the second mailing service. A good way to solve this issue would be to either
store the configuration of mailers in separte objects or to introduce one more layer of abstraction between the
environmental variables and my service object. The second solution would make it easy to stub it out and test a failure
of both services.

The service object is being called from the controller. There I inject the mailer to the service. As you can see it is
hardcoded, but it would be easy to swap it out for anything else depending for the parameters incoming to this action.
Also recipients of emails and other parameters could be sent to this action to customize the outbound emails. Currently
this service object always responds with a 200 HTTP status but it would be easy to adjust the response code based on the
result of the service object operation. After this service has done its job, a JSON is being rendered with messages
indicating the result of the operation.

This app has been deployed to Heroku. There, Sendgrid and Mailgun extensions have been installed. As for app monitoring,
Rollbar is used to listen to exceptions that may occur during runtime. It sends emails to all the subscribers of this
service in case anything goes wrong on production.










