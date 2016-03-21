FROM ruby:2.1-onbuild
ENV RACK_ENV production
ENV GITHUB_PUSH_SOURCE_TO Transifex Project Name
ENV GITHUB_USERNAME Your github username
ENV GITHUB_TOKEN Transifex API Token
ENV GITHUB_WEBHOOK_SECRET Auth for Github Webhook
ENV GITHUB_BRANCH master
ENV TX_CONFIG_PATH config/tx.config
ENV TX_USERNAME Transifex Username
ENV TX_PASSWORD Transifex Password
ENV TX_PUSH_TRANSLATIONS_TO Github Repo Name
ENV TX_WEBHOOK_SECRET Auth for Transifex Webhook

EXPOSE 9292
CMD ["puma", "-p", "9292"]


