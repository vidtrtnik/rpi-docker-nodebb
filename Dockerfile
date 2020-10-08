FROM ubuntu:latest

ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update
RUN apt -y install git curl build-essential libvips-dev libvips-tools

RUN curl -sL https://deb.nodesource.com/setup_14.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt -y install nodejs

RUN git clone -b v1.14.x https://github.com/NodeBB/NodeBB.git nodebb

WORKDIR /nodebb

COPY config.json /nodebb/config.json
RUN ./nodebb start

# -------------------------------------------------
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
RUN npm install --global neon-cli
WORKDIR /nodebb/node_modules/benchpressjs/rust/benchpress-rs
ENV PATH="/root/.cargo/bin:$PATH"
RUN neon build --release
# -------------------------------------------------

WORKDIR /nodebb

RUN npm install -g supervisor
RUN npm audit fix

RUN apt purge -y build-essential libvips-dev libvips-tools
RUN apt autoremove -y

COPY nodebb_startup.sh /nodebb/nodebb_startup.sh
CMD ["./nodebb_startup.sh"]
