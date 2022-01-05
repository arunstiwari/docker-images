# Start from the latest golang parent
FROM golang:1.14.2-alpine AS builder
# Set the working directory
WORKDIR /myapp
# Copy source file from current directory to container
COPY main.go .
# Build the application
RUN go env -w GO111MODULE=off && go build -o main .

# Start from latest alpine parent image
FROM alpine:latest AS runtime
# Set the working directory
WORKDIR /myapp

#Copy welcome app from current directory to container
COPY --from=builder /myapp/main .
# RUN the application
ENTRYPOINT ["./main"]
EXPOSE 8080