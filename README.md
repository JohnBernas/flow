# Flow [![Build Status](https://travis-ci.org/kabisaict/flow.png?branch=master)](https://travis-ci.org/kabisaict/flow) [![Code Climate](https://codeclimate.com/github/kabisaict/flow.png)](https://codeclimate.com/github/kabisaict/flow) [![Coverage Status](https://coveralls.io/repos/kabisaict/flow/badge.png)](https://coveralls.io/r/kabisaict/flow)

Flow is a KanBan layer on top of Pivotal Tracker.

## Benefits

With Flow you can use Pivotal Tracker as a backend for all your KanBan needs.
Synchronization is done through story statuses and labels. The application is
still heavily in development, but the following features are currently
implemented:

* Drag and drop KanBan interface
* Websockets for pushing state between clients
* Swimlanes based on story labels
* Columns based on story state and labels
* Story details in KanBan include story id, title, and a link to the Pivotal
  story

## Deployment

Due to the use of Websockets (and background workers) it is a bit more involved
to deploy the application to a server. You *can* use Heroku, but you will need
more than one worker to run the application.

A "start from scratch" server setup-guide will be added to the Wiki in the
future.

## Development

Flow is tested against ruby 2.0.0. Setting Flow up for local development
requires a few manual steps:

    brew install redis
    bundle install
    rake db:migrate
    cp db/seeds.example.rb config/seeds.rb    # Modify to set correct data
    rake db:seed

The easiest way to run the required processes is by using the `Procfile`.

    gem install foreman
    foreman start

## Contributing

Please see [CONTRIBUTING.md][] for details.

## Credits

Flow was originally written by Jean Mertz.

[![kabisa](http://kabisa.nl/assets/logo-7456ff79fa2f4a5d72514a807733182d.png)](http://www.kabisa.nl)

Flow is a Kabisa initiative.

## License

Flow is Copyright © 2013 Jean Mertz and Kabisa ICT. It is free software, and may
be redistributed under the terms specified in the [LICENSE.txt][] file.

[CONTRIBUTING.md]: CONTRIBUTING.md
[LICENSE.txt]: LICENSE.txt
