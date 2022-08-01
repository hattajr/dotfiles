# ubuntu 20.04
FROM ubuntu:20.04

WORKDIR /home

COPY . .

RUN chmod +x install.sh && ./install.sh
CMD ["sh", "-c", "echo Hello dot"]