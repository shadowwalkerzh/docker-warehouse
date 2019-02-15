# Base python3.7 docker image with Asia/Shanghai timezone
FROM python:3.7

ENV ENV LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8"

LABEL MAINTAINER="peerlesszh@163.com"

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
echo "Asia/Shanghai" > /etc/timezone