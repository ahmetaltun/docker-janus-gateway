#Base image
FROM ubuntu:22.04

#Copy packages folder
COPY ./dependencies /tmp/dependencies

#Update and install packages
RUN apt update -y && \
    apt install --no-install-recommends \
    libmicrohttpd-dev libjansson-dev \
	libssl-dev libsrtp2-dev libglib2.0-dev \
	libopus-dev libogg-dev libcurl4-openssl-dev liblua5.3-dev \
	libconfig-dev pkg-config gengetopt libtool automake cmake -y

RUN apt install wget -y && \
    apt install python3 python3-pip python3-setuptools -y && \
    pip3 install meson ninja

#Pull dependencies
WORKDIR /tmp/dependencies/
RUN tar xfv libnice-master.tar.gz && \
    tar xfv libsrtp-2.2.0.tar.gz && \
    tar xfv usrsctp-0.9.5.0.tar.gz && \
    tar xfv libwebsockets-4.3.2.tar.gz && \
    tar xfv janus-gateway-0.13.0.tar.gz

#Change dir for libnice installation
WORKDIR /tmp/dependencies/libnice-master/
#Install libnice
RUN meson --prefix=/usr build && \
    ninja -C build && \
    ninja -C build install

#Change dir for libsrtp installation
WORKDIR /tmp/dependencies/libsrtp-2.2.0/
#Install libsrtp
RUN ./configure --prefix=/usr --enable-openssl && \
    make shared_library && \
    make install

#Change dir for usrsctp installation
WORKDIR /tmp/dependencies/usrsctp-0.9.5.0/
#Install usrsctp
RUN ./bootstrap && \
    ./configure --prefix=/usr --disable-programs --disable-inet --disable-inet6 && \
    make && \
    make install

#Change dir for libwebsockets installation
RUN mkdir /tmp/dependencies/libwebsockets-4.3.2/build/
WORKDIR /tmp/dependencies/libwebsockets-4.3.2/build/
#Install libwebsockets
RUN cmake -DLWS_MAX_SMP=1 -DLWS_WITHOUT_EXTENSIONS=0 -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" .. && \
    make && \
    make install

#Change dir for janus installation
WORKDIR /tmp/dependencies/janus-gateway-0.13.0/
#Install janus-gateway
RUN sh autogen.sh && \
    ./configure --prefix=/opt/janus --disable-rabbitmq --disable-mqtt && \
    make && \
    make install && \
    make configs

#Remove unnecessary packages and folders
WORKDIR /
RUN pip3 uninstall meson ninja -y &&  \
    apt remove aptitude python3-pip python3 gengetopt libtool automake git wget cmake -y && \
    rm -rf /tmp/* && rm -rf /var/cache/* && \
    apt autoremove -y && \
    apt clean -y && \
    apt purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false;

#Ports
EXPOSE 7000 7088 7089 8000 8088 8089 8188 8889 10000-10200/udp

#Run janus-gateway
CMD ["/opt/janus/bin/janus"]