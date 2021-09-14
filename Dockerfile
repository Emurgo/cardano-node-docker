FROM debian:stable-slim as build

RUN apt-get update -y \
    && apt-get install -y automake build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 libtool autoconf libsqlite3-dev m4 ca-certificates gcc libc6-dev \
    && apt-get clean

ENV PATH="/root/.cabal/bin:/root/.ghcup/bin:/root/.local/bin:$PATH"
RUN wget https://downloads.haskell.org/~cabal/cabal-install-3.2.0.0/cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz \
    && tar -xf cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz \
    && rm cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz cabal.sig \
    && mkdir -p ~/.local/bin \
    && mv cabal ~/.local/bin/ \
    && cabal update && cabal --version

RUN wget https://downloads.haskell.org/ghc/8.10.2/ghc-8.10.2-x86_64-deb9-linux.tar.xz \
    && tar -xf ghc-8.10.2-x86_64-deb9-linux.tar.xz \
    && rm ghc-8.10.2-x86_64-deb9-linux.tar.xz \
    && cd ghc-8.10.2 \
    && ./configure \
    && make install \
    && cd / \
    && rm -rf /ghc-8.10.2

RUN git clone https://github.com/input-output-hk/libsodium \
    && cd libsodium \
    && git fetch --all --recurse-submodules --tags \
    && git tag \
    && git checkout tags/1.0.16 \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install \
    && cd .. && rm -rf libsodium
ENV LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH" \
    PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"

RUN wget https://github.com/input-output-hk/cardano-node/archive/refs/tags/1.30.0-rc2.tar.gz \
    && tar -zxvf 1.30.0-rc2.tar.gz \
    && cd cardano-node-1.30.0-rc2 \
    && cabal configure --with-compiler=ghc-8.10.2 \
    && echo "package cardano-crypto-praos" >>  cabal.project.local \
    && echo "  flags: -external-libsodium-vrf" >>  cabal.project.local \
    && cabal build all \
    && mkdir -p /root/.local/bin/ \
    && cp -p dist-newstyle/build/x86_64-linux/ghc-8.10.2/cardano-node-*/x/cardano-node/build/cardano-node/cardano-node /root/.local/bin/ \
    && cp -p dist-newstyle/build/x86_64-linux/ghc-8.10.2/cardano-cli-*/x/cardano-cli/build/cardano-cli/cardano-cli /root/.local/bin/


FROM debian:stable-slim
COPY --from=build /root/.local/bin/ /bin/
COPY --from=build /usr/local/lib/ /lib/

SHELL ["/bin/bash", "-c"]
COPY . .
ENTRYPOINT cardano-node run --database-path /data/db --host-addr "$LISTEN_ADDR" --port "$PORT" --socket-path /ipc/node.socket --topology ./"$NETWORK"-topology.json --config ./"$NETWORK"-config.json

