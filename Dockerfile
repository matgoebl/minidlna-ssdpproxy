FROM alpine:latest as builder

# source: https://pkgs.alpinelinux.org/package/edge/community/x86_64/minidlna
RUN apk --no-cache add build-base autoconf automake bsd-compat-headers ffmpeg-dev flac-dev gettext-dev libexif-dev libid3tag-dev libjpeg-turbo-dev libogg-dev libtool libvorbis-dev sqlite-dev zlib-dev

ARG version=1.3.3
ENV version=${version}

RUN cd /root && \
    wget https://downloads.sourceforge.net/project/minidlna/minidlna/${version}/minidlna-${version}.tar.gz
COPY minidlna-ssdphost.patch /root/
RUN cd /root && \
    tar xf minidlna-${version}.tar.gz && \
    cd minidlna-${version} && \
    patch -p1 < ../minidlna-ssdphost.patch && \
    ./configure && \
    make && \
    cp minidlnad ..


FROM alpine:latest

RUN apk --no-cache add bash curl tini shadow su-exec alpine-conf inotify-tools minidlna minissdpd
# overwrite binary, dependencies are already pulled by official minidlna package
COPY --from=builder /root/minidlnad /usr/sbin/minidlnad

# Entrypoint
COPY entrypoint.sh /

ARG BUILDTAG=unknown
ENV BUILDTAG=${BUILDTAG}
RUN echo "${BUILDTAG}" > /build.txt

USER 100:101
VOLUME /minidlna
WORKDIR /minidlna

ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]

LABEL org.opencontainers.image.title="MiniDLNA with SSDP-Proxy" \
      org.opencontainers.image.source="https://github.com/matgoebl/minidlna-ssdpproxy" \
      org.opencontainers.image.authors="Matthias.Goebl@goebl.net" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.version="${BUILDTAG}"
