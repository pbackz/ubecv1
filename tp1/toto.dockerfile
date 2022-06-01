# syntax=docker/dockerfile:1
FROM golang:1.16
WORKDIR /go/src/github.com/alexellis/href-counter/
RUN go get -d -v golang.org/x/net/html  
COPY main.go ./
COPY go.mod ./
COPY go.sum ./
RUN go mod download && \
  CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

FROM ubuntu:latest  
WORKDIR /root/
COPY --from=0 /go/src/github.com/alexellis/href-counter/main ./
COPY entrypoint.sh ./
RUN chmod +x ./entrypoint.sh 
EXPOSE 8080
ENTRYPOINT ["./entrypoint.sh"]
