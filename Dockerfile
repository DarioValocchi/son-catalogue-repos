FROM ruby:2.1
RUN mkdir -p /app
COPY Gemfile /app/
WORKDIR /app
RUN bundle install
COPY . /app
RUN rake yard
ENV PORT 4567
EXPOSE 8808
EXPOSE 4567
WORKDIR /app
CMD ["rake", "start"]
