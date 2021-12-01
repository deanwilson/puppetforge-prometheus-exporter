FROM ruby:3.0.3-slim-buster

ENV PUPPETFORGE_EXPORTER_USERS deanwilson

COPY ["Gemfile", "puppetforge-exporter.rb", "/app/"]
WORKDIR /app

RUN bundle install --without=development

ENTRYPOINT ["./puppetforge-exporter.rb"]
