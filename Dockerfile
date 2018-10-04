FROM debian:stretch
LABEL maintainer="Viktor Taranenko <viktor@whisk.com>"

ARG GRAAL_VERSION
ENV GRAAL_VERSION ${GRAAL_VERSION:-1.0.0-rc7}

RUN set -xeu && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates `# stays, not having this is just not useful` \
        curl \
        && \
    mkdir /graalvm && \
    curl -fsSL "https://github.com/oracle/graal/releases/download/vm-${GRAAL_VERSION}/graalvm-ce-${GRAAL_VERSION}-linux-amd64.tar.gz" \
        | tar -zxC /graalvm --strip-components 1 && \
    echo 'HOTFIX for missing certificates: https://github.com/oracle/graal/issues/378' && \
    ORACLE_JRE_URL='http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/jdk-8u181-linux-x64.tar.gz' && \
    curl -jkL -H 'Cookie: oraclelicense=accept-securebackup-cookie' $ORACLE_JRE_URL | tar -zxvf - --directory /graalvm --wildcards "*/jre/lib/security/cacerts" --strip-components 1 && \
    find /graalvm -name "*src.zip"  -printf "Deleting %p\n" -exec rm {} + && \
    rm -r /graalvm/man && \
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
