FROM ruby:2.4.2

RUN gem install specific_install
RUN gem specific_install -l https://github.com/zinfra/fastlane.git
