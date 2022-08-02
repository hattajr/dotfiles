# ubuntu 20.04
FROM ubuntu:20.04
ENV TZ=Asia/Seoul
ENV XDG_CONFIG_HOME=/home
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
WORKDIR /home/
COPY . .
RUN chmod +x install.sh && ./install.sh
CMD ["sh", "-c", "zsh"]