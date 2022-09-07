# Approximate size: 260MB
FROM ubuntu:18.04

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /src

COPY requirements.txt ./
RUN apt-get -qq update \
  && apt-get install -y --no-install-recommends  python3-pip python3-dev python3-setuptools \
  && pip3 install -U pip \
  && pip3 install --no-cache-dir -r requirements.txt \
  && rm -rf /var/lib/apt/lists/*
