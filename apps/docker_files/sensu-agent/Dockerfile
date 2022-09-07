# Approximate size: 124MB
FROM ubuntu:18.04

RUN set -o pipefail \
  apt-get -qq update \
  && DEBIAN_FRONTEND=noninteractive apt-get -qq -y upgrade \
  && apt-get install -y --no-install-recommends monitoring-plugins monitoring-plugins-basic monitoring-plugins-standard monitoring-plugins-common debian-archive-keyring apt-transport-https curl lsb-release ca-certificates gnupg \
  && curl -sSf "https://packagecloud.io/install/repositories/sensu/stable/config_file.list?os=$(lsb_release -si | awk '{ print tolower($1) }')&dist=$(lsb_release -sc)&source=script" > /etc/apt/sources.list.d/sensu_stable.list \
  && curl -L "https://packagecloud.io/sensu/stable/gpgkey" 2> /dev/null | apt-key add -  \
  && apt-get -qq update \
  && apt-get install -y --no-install-recommends sensu-go-agent libpq5\
  && apt-get -y remove curl lsb-release gnupg \
  && apt-get -y autoremove \
  && apt-get -y purge curl lsb-release gnupg \
  && apt-get -y clean all \
  && rm -rf /var/lib/apt/lists/*

# Override SUBSCRIPTIONS
ENV SUBSCRIPTIONS=services

CMD ["sensu-agent", "start", "--backend-url ws://sensu-backend:8081 --subscriptions $SUBSCRIPTIONS --log-level debug"]
