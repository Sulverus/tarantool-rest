from tarantool/tarantool:ubuntu
RUN apt-get update
RUN apt-get install -y tarantool tarantool-http

ADD fx-app.lua /usr/share/tarantool/
ADD forex.lua /usr/share/tarantool/
EXPOSE 3301

WORKDIR /usr/share/tarantool/
CMD /usr/bin/tarantool fx-app.lua
