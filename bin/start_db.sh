#!/bin/bash

cd spec/dummy
docker compose up -d
bundle exec rails db:test:prepare
