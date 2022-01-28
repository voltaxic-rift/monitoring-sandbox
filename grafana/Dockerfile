FROM golang:bullseye

RUN go install -a github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@latest &&\
    go install -a github.com/google/go-jsonnet/cmd/jsonnetfmt@latest &&\
    go install -a github.com/google/go-jsonnet/cmd/jsonnet@latest &&\
    curl -fSL -o "/usr/local/bin/grr" "https://github.com/grafana/grizzly/releases/download/v0.2.0-beta3/grr-linux-amd64" &&\
    chmod a+x "/usr/local/bin/grr" &&\
    apt update -y &&\
    apt install -y python3-pip &&\
    pip install yaml2jsonnet

WORKDIR /workdir
