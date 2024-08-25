# Start from the official Golang image
FROM golang:alpine AS build

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

# Copy the source code from the current directory to the Working Directory inside the container
COPY . .

RUN go test ./... \
  && go build -ldflags='-s -w' -o main .

# End from the latest alpine image
# hadolint ignore=DL3007
FROM alpine:latest

# add bash and timezone data
# hadolint ignore=DL3008
RUN apk --no-cache add tzdata

# set the current workdir
WORKDIR /app

# copy in our compiled GO app
COPY --from=build /app/main /app/

# the containers entrypoint
ENTRYPOINT [ "/app/main" ]
