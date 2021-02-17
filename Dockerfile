FROM golang:1.13-alpine AS builder

WORKDIR /build
ENV CGO_ENABLED=1 \
  GOOS=linux \
  GOARCH=amd64

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build ./cmd/rango

RUN apk add --no-cache curl

# Install Kaigara
ARG KAIGARA_VERSION=0.1.9
RUN curl -Lo /usr/bin/kaigara https://github.com/openware/kaigara/releases/download/${KAIGARA_VERSION}/kaigara \
  && chmod +x /usr/bin/kaigara

FROM alpine:3.9

RUN apk add ca-certificates
WORKDIR app

COPY --from=builder /build/rango ./
COPY --from=builder /usr/bin/kaigara /usr/bin/kaigara

RUN mkdir -p /app/config

CMD ["./rango"]
