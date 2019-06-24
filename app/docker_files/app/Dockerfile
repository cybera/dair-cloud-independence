# Approximate size: 260MB
FROM ubuntu:18.04

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /src

COPY requirements.txt ./
RUN apt-get -qq update \
  && DEBIAN_FRONTEND=noninteractive apt-get -qq -y upgrade \
  && apt-get install -y --no-install-recommends  python3-pip python3-dev \
  && apt-get -y clean all \
  && pip3 install --no-cache-dir -r requirements.txt \
  && rm -rf /var/lib/apt/lists/*
