Janus WebRTC Server
=
Janus is an open source, general purpose, WebRTC server designed and developed by [Meetecho](http://www.meetecho.com).

[Google Group](https://groups.google.com/forum/#!forum/meetecho-janus)

[GitHub](https://github.com/meetecho/janus-gateway)

## Usage

Download image

    docker pull ahmetaltun/janus-gateway:0.10.10

Create container example

    docker container run -d --name janus-test -p 8088:8088 ahmetaltun/janus-gateway:0.10.10

Check

    http://127.0.0.1:8088/janus/info