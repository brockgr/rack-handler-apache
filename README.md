rack-handler-apache
===================

A rack-handler like gem for apache/passenger.

By default, when developing rails, or other rack based applications, Webrick is used as the web server.
However sometimes, you want to quickly check that things are working with Apache/Passenger.

Now you can just type:

    rails server apache

or

    rails s apache

or

    rackup -s apache config.ru

This will run a minimally configured Apache instance as the current user. When you control-c your app,
the server will shutdown too.

Yes, this is not the right way to run your production rails apps!

Yes, this is running as you, so there are the usual security issues!

But it might be handy!!


Configuration Options
---------------------

* Port

  Port defaults to 8080

* SSLEnable

  Boolean to enable use of SSL. Deafult is false.
  If SSL is enables, then SSLCertificateFile and SSLPrivateKeyFile
  must be set.

* SSLCertificateFile

  The SSL Certificate file name. (Note this is the file name, not a 
  certificate object, like in Webricks SSLCertificate)

* SSLPrivateKeyFile

  The SSL Private Key file name. (Again this is not the key object)


Things todo
-----------

* Better config customisation - if anyone needs it
