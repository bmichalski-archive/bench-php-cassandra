FROM ubuntu:14.04

RUN \
  apt-get update && \
  locale-gen en_US.UTF-8 && \
  export LANG=en_US.UTF-8 && \
  apt-get install -y software-properties-common \
  && \
  add-apt-repository -y ppa:ondrej/php5-5.6 && \
  apt-get update && \
  apt-get install -y \
    php5-cli \
  && \
  adduser --disabled-password --gecos '' r && \
  usermod -aG sudo r && \
  echo "r ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN \
  apt-get update && \
  apt-get install -y \
    g++ make cmake \
    libuv-dev libssl-dev libgmp-dev

RUN \
  apt-get update && \
  apt-get install -y php5-dev openssl libpcre3-dev

RUN \
  apt-get install -y git

RUN \
  git clone --depth=1 https://github.com/datastax/php-driver.git

RUN \
  git clone --depth=1 https://github.com/datastax/cpp-driver.git

RUN \
  mkdir cpp-driver/build && \
  cd cpp-driver/build && \
  cmake .. && \
  make && make install

RUN \
  cd php-driver && \
  pecl install ext/package.xml

RUN \
  echo "extension=cassandra.so" > /etc/php5/cli/conf.d/cassandra.ini

COPY conf/etc/php5/cli/php.ini /etc/php5/cli/php.ini

ENV HOME /root

WORKDIR /root

CMD bash
