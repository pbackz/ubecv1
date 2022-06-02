
#!/bin/bash

cat << EOF > app_names.txt
tyty
titi
toto
EOF

cat app_names.txt | while read app; do cat << EOF > ${app}.dockerfile
# syntax=docker/dockerfile:1
FROM golang:1.16 as builder
WORKDIR /go/src/github.com/alexellis/href-counter/
RUN go get -d -v golang.org/x/net/html
COPY main.go ./
COPY go.mod ./
COPY go.sum ./
RUN go mod download && \
  CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

FROM ubuntu:latest as post-runner
WORKDIR /root/
COPY --from=builder /go/src/github.com/alexellis/href-counter/main ./
COPY ${app}.entrypoint.sh ./

FROM ubuntu:latest as runner
WORKDIR /root/
COPY --from=post-runner /root/${app}.entrypoint.sh ./
EXPOSE 8080
ENTRYPOINT ["./${app}.entrypoint.sh"]
EOF
done
