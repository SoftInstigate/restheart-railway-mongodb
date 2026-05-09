FROM softinstigate/restheart:latest-native

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
    && pip3 install bcrypt --break-system-packages \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080
WORKDIR /opt/restheart
ENTRYPOINT ["/entrypoint.sh"]
