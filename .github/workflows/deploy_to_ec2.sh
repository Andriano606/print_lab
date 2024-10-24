#!/bin/bash

if sudo lsof -t -i:3000; then
  sudo lsof -t -i:3000 | xargs sudo kill -9
else
  echo "No processes running on port 3000"
fi

cd /home/ubuntu/print_lab

# print current folder
echo $PWD

git pull origin main
gem install bundler
bundle install
yarn install
yarn build
RAILS_ENV=production bundle exec rails db:migrate
RAILS_ENV=production bundle exec puma -C config/puma.rb
