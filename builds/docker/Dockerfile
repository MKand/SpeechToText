FROM golang:1.20-buster as builder

RUN set -x && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    protobuf-compiler ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.30
RUN go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.2

# Create and change to the app directory.
WORKDIR /app

# Retrieve application dependencies.
# This allows the container build to reuse cached dependencies.
# Expecting to copy go.mod and if present go.sum.
COPY go.* ./
RUN go mod download

# Copy local code to the container image.
COPY ./ ./

# Generate the protobuf files
RUN go generate cmd/server/*
# Build the binary.
RUN CGO_ENABLED=0 go build -o server cmd/server/*
# Generate the protobuf files
RUN go generate cmd/client/*
# Build the binary.
RUN CGO_ENABLED=0 go build -o client cmd/client/* 

# Use the scratch base container for a lean production container.
FROM scratch

# Copy the binary to the production image from the builder stage.
COPY --from=builder /app/server /usr/bin/server
COPY --from=builder /app/client /usr/bin/client

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
# Run the web service on container startup.
CMD ["server"]
