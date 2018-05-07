FROM debian:9

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -qq update

# Install dependencies, note that ca-certificates is needed for the git clone to work
RUN apt-get -qq install -y --no-install-recommends \
ca-certificates \
curl \
git \
clang \
cmake \
make \
gcc \
g++ \
libmariadbclient-dev \
libssl1.0-dev \
libbz2-dev \
libreadline-dev \
libncurses-dev \
libboost-all-dev \
mysql-client \
p7zip

RUN update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100
RUN update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang 100

# Create the trinity user to manage all components
RUN useradd -ms /bin/bash trinity 
USER trinity

# Clone the server repository
WORKDIR /home/trinity
RUN mkdir -p TrinityCore/build

# Generate Makefiles with CMAKE, build and install to the trinity user's home directory
WORKDIR /home/trinity/TrinityCore/build
RUN cmake ../ -DCMAKE_INSTALL_PREFIX=/home/trinity/server
RUN make -j4
RUN make -j4 install

# Populate the server's directory with the generated map data
RUN mkdir -p /home/trinity/server/data
WORKDIR /home/trinity/server/data

# Copy the sql file to the worldserver binary directory
WORKDIR /home/trinity/server/bin
#COPY ADB_world_735.00.sql .
#COPY ADB_hotfixes_735.00.sql .