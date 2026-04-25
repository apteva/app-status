# Multi-stage Dockerfile for the Apteva Status app.
FROM golang:1.22-alpine AS build
RUN apk add --no-cache build-base
WORKDIR /src
COPY go.mod go.sum* ./
COPY app-sdk/ ../app-sdk/
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /status .

FROM alpine:3.20
RUN apk add --no-cache ca-certificates
COPY --from=build /status /usr/local/bin/status
COPY migrations/ /migrations/
WORKDIR /data
ENV PORT=8080
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/status"]
