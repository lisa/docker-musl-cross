FROM debian:stretch
# Upstream maintainer Andrew Dunham <andrew@du.nham.ca>

# Maintainer of this fork is Lisa Seelye
MAINTAINER Lisa Seelye <lisa@thedoh.com>

# Build this version.
# This is 'magic' for publishing too.

ENV MUSL_VERSION=1.1.20

# Install build tools
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -yy && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yy \
        automake            \
        bison               \
        build-essential     \
        curl                \
        file                \
        flex                \
        git                 \
        libtool             \
        pkg-config          \
        python              \
        texinfo             \
        vim                 \
        wget



# Install musl-cross
RUN mkdir /build &&                                                            \
    cd /build &&                                                               \
    git clone https://github.com/lisa/musl-cross.git &&                        \
    cd musl-cross &&                                                           \
    echo 'GCC_BUILTIN_PREREQS=yes' >> config.sh &&                             \
    sed -i -e "s/^MUSL_VERSION=.*\$/MUSL_VERSION=${MUSL_VERSION}/" defs.sh &&  \
    ./build.sh &&                                                              \
    cd / &&                                                                    \
    apt-get clean &&                                                           \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /build &&                    \
    ln -s $(find /opt/cross -maxdepth 1 -mindepth 1 -type d -print) /opt/cross/musl-${MUSL_VERSION}


ENV PATH $PATH:/opt/cross/musl-${MUSL_VERSION}
CMD /bin/bash
