FROM debian:stretch
LABEL maintainer="Viktor Taranenko <viktor@whisk.com>"

ARG GRAAL_VERSION
ENV GRAAL_VERSION ${GRAAL_VERSION:-19.2.0}

RUN set -xeu && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        curl ca-certificates ca-certificates-java \
        && \
    mkdir /graalvm && \
    curl -fsSL "https://github.com/oracle/graal/releases/download/vm-${GRAAL_VERSION}/graalvm-ce-linux-amd64-${GRAAL_VERSION}.tar.gz" \
        | tar -zxC /graalvm --strip-components 1 && \
    echo 'HOTFIX for missing certificates: https://github.com/oracle/graal/issues/378' && \
    cp /etc/ssl/certs/java/cacerts /graalvm/jre/lib/security/cacerts && \
    find /graalvm -name "*src.zip"  -printf "Deleting %p\n" -exec rm {} + && \
    rm -r /graalvm/man && \
    echo Cleaning up... && \
    apt-get remove -y \
        curl \
        ca-certificates-java \
        && \
    apt-get autoremove -y && \
    apt-get clean && rm -r "/var/lib/apt/lists"/* && \
    echo 'PATH="/graalvm/bin:$PATH"' | install --mode 0644 /dev/stdin /etc/profile.d/graal-on-path.sh && \
    echo OK

# This applies to all container processes. However, `bash -l` will source `/etc/profile` and set $PATH on its own. For this reason, we
# *also* set $PATH in /etc/profile.d/*
ENV PATH=/graalvm/bin:$PATH
