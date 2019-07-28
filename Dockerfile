FROM alpine:latest AS builder
ARG RELEASE=master
RUN apk add --no-cache curl unzip
RUN curl -L "https://git.pleroma.social/pleroma/pleroma/-/jobs/artifacts/$RELEASE/download?job=amd64-musl" -o /tmp/pleroma.zip && unzip /tmp/pleroma.zip -d /tmp/ && rm /tmp/pleroma.zip

FROM alpine:latest
RUN apk add --no-cache ncurses
RUN adduser --system --shell  /bin/false --home /opt/pleroma pleroma
COPY --from=builder --chown=pleroma:root /tmp/release/ /opt/pleroma
RUN mkdir --parents /var/lib/pleroma /etc/pleroma \
 && chown -R pleroma /var/lib/pleroma /etc/pleroma
USER pleroma
VOLUME ["/var/lib/pleroma/uploads", "/var/lib/pleroma/static", "/etc/pleroma"]
ENTRYPOINT ["/opt/pleroma/bin/pleroma", "start"]
EXPOSE 4000/tcp
