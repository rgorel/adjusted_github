FROM ruby:2.7.1-slim

RUN apt-get update && apt-get install -y build-essential

WORKDIR /app
