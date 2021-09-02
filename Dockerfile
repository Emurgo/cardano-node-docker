FROM alpine:3.14

WORKDIR /usr/local/cardano-node/bin
RUN apk add wget
RUN wget https://hydra.iohk.io/build/7472719/download/1/cardano-node-1.29.0-linux.tar.gz
RUN tar -zxvf cardano-node-1.29.0-linux.tar.gz
RUN mkdir -p /data/db
RUN mkdir /ipc
RUN wget "https://hydra.iohk.io/build/7370192/download/1/mainnet-config.json"
RUN wget "https://hydra.iohk.io/build/7370192/download/1/mainnet-topology.json"
RUN wget "https://hydra.iohk.io/build/7370192/download/1/mainnet-byron-genesis.json"
RUN wget "https://hydra.iohk.io/build/7370192/download/1/mainnet-shelley-genesis.json"
RUN wget "https://hydra.iohk.io/build/7370192/download/1/mainnet-alonzo-genesis.json"
RUN wget "https://hydra.iohk.io/build/7370192/download/1/testnet-config.json"
RUN wget "https://hydra.iohk.io/build/7370192/download/1/testnet-topology.json"
RUN wget "https://hydra.iohk.io/build/7370192/download/1/testnet-byron-genesis.json"
RUN wget "https://hydra.iohk.io/build/7370192/download/1/testnet-shelley-genesis.json"
RUN wget "https://hydra.iohk.io/build/7370192/download/1/testnet-alonzo-genesis.json"
ENTRYPOINT ./cardano-node run --database-path /data/db --host-addr "$LISTEN_ADDR" --port "$PORT" --socket-path /ipc/node.socket --topology ./"$NETWORK"-topology.json --config ./"$NETWORK"-config.json


