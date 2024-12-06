FROM --platform=${BUILDPLATFORM} ubuntu:24.04 AS builder
ARG BUILDARCH
ARG TARGETARCH
ARG LC_ALL=C.UTF-8
ARG LANG=C.UTF-8
ARG TZ=UTC
ARG DEBIAN_FRONTEND=noninteractive
ADD --link --chmod=644 https://github.com/canonical/chisel/releases/download/v1.0.0/chisel_v1.0.0_linux_${BUILDARCH}.tar.gz /root/chisel.tar.gz
RUN <<EOF
#!/bin/sh -eux
umask 022
apt-get update -y
apt-get install -y --no-install-recommends ca-certificates busybox
apt-get clean -y
rm -rf /var/lib/apt/lists/*
tar -xvf /root/chisel.tar.gz -C /usr/bin/ chisel
rm -f /root/chisel.tar.gz
mkdir -p /rootfs
chisel cut --release ubuntu-24.04 --arch ${TARGETARCH} --root /rootfs \
  base-files_base \
  base-files_chisel \
  base-files_release-info \
  base-passwd_data \
  libc-bin_locale \
  busybox_bins \
  python3.12_standard \
  python3.12-venv_ensurepip
for i in $(busybox --list); do ln -s busybox /rootfs/bin/$i; done
mkdir -p /rootfs/app
EOF
FROM scratch
COPY --from=builder /rootfs /
COPY --link requirements.txt /app/requirements.txt
ARG LC_ALL=C.UTF-8
ARG LANG=C.UTF-8
ARG TZ=UTC
ARG QEMU_CPU=cortex-a72
ENV PATH=/app/venv/bin:${PATH}
RUN <<EOF
#!/bin/sh -eux
umask 022
python3.12 -m venv /app/venv
pip install --upgrade pip setuptools
pip install -r /app/requirements.txt
EOF
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV TZ=UTC
CMD ["/bin/sh"]
