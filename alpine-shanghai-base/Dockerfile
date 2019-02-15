# Base alpine docker image with Asia/Shanghai timezone
FROM alpine:3.9

ENV ENV LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8"

LABEL MAINTAINER="peerlesszh@163.com"

RUN apk --no-cache add tzdata ca-certificates && \
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
echo "Asia/Shanghai" > /etc/timezone
