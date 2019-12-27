FROM debian:buster
LABEL maintainer="Viktor Taranenko <viktor@samsungnext.com>"

ARG GRAAL_VERSION
ENV GRAAL_VERSION ${GRAAL_VERSION:-19.3.0}
ARG JAVA_VERSION
ENV JAVA_VERSION ${JAVA_VERSION:-11}

RUN set -xeu && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        && \
    mkdir /graalvm && \
    curl -fsSL "https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-${GRAAL_VERSION}/graalvm-ce-java${JAVA_VERSION}-linux-amd64-${GRAAL_VERSION}.tar.gz" \
        | tar -zxC /graalvm --strip-components 1 && \
    find /graalvm -name "*src.zip"  -printf "Deleting %p\n" -exec rm {} + && \
    echo Cleaning up... && \
    apt-get remove -y \
        curl \
        && \
    apt-get autoremove -y && \
    apt-get clean && rm -r "/var/lib/apt/lists"/* && \
    echo 'PATH="/graalvm/bin:$PATH"' | install --mode 0644 /dev/stdin /etc/profile.d/graal-on-path.sh && \
    echo OK

# This applies to all container processes. However, `bash -l` will source `/etc/profile` and set $PATH on its own. For this reason, we
# *also* set $PATH in /etc/profile.d/*
ENV PATH=/graalvm/bin:$PATH
