FROM arm64v8/ubuntu:20.04

ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update && apt install -y curl
RUN curl -sL https://deb.nodesource.com/setup_14.x -o nodesource_setup.sh && bash nodesource_setup.sh

RUN apt -y install git curl build-essential libvips-dev nodejs

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
RUN npm install --global neon-cli
ENV PATH="/root/.cargo/bin:$PATH"


RUN git clone -b v1.14.3 https://github.com/NodeBB/NodeBB.git nodebb
#RUN git clone https://github.com/NodeBB/NodeBB.git nodebb

WORKDIR /nodebb
COPY config.json /nodebb/config.json
RUN ./nodebb start

# -------------------------------------------------
WORKDIR /nodebb/node_modules/benchpressjs/rust/benchpress-rs/native

RUN sed -i 's/neon-build = .*/neon-build = "0.4.0"/g' Cargo.toml && \
    sed -i 's/neon = .*/neon = "0.4.0"/g' Cargo.toml

WORKDIR /nodebb/node_modules/benchpressjs/rust/benchpress-rs
RUN cargo generate-lockfile
RUN neon build --release
RUN cp /nodebb/node_modules/benchpressjs/rust/benchpress-rs/native/index.node ./index.node
# -------------------------------------------------

WORKDIR /nodebb
RUN npm install
RUN npm audit fix

COPY nodebb_startup.sh /nodebb/nodebb_startup.sh

WORKDIR /nodebb
CMD ["./nodebb_startup.sh"]
