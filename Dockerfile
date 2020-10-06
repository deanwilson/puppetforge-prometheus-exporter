FROM ruby:2.7.2-slim-buster

ENV PUPPETFORGE_EXPORTER_USERS deanwilson

COPY ["Gemfile", "puppetforge-exporter.rb", "/app/"]
WORKDIR /app

RUN bundle install --without=development

ENTRYPOINT ["./puppetforge-exporter.rb"]
