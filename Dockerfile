FROM ubuntu:22.04
ARG BUILDARCH
ARG TARGETARCH
ARG LC_ALL=C.UTF-8
ARG LANG=C.UTF-8
ARG TZ=UTC
ARG DEBIAN_FRONTEND=noninteractive
ENV PATH=/app/venv/bin:${PATH}
RUN <<EOF
#!/bin/sh -eux
umask 022
apt-get update -y
apt-get dist-upgrade -y
apt-get install -y python3-venv
apt-get autoremove --purge -y
apt-get clean -y
rm -rf /var/lib/apt/lists/*
mkdir /app
python3.10 -m venv /app/venv
pip install --upgrade pip setuptools
EOF
COPY --link requirements.txt /app/requirements.txt
RUN <<EOF
#!/bin/sh -eux
umask 022
pip install -r /app/requirements.txt
EOF
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV TZ=UTC
CMD ["/bin/sh"]
