# Start from the latest golang parent
FROM golang:latest
# Set the working directory
WORKDIR /myapp
# Copy source file from current directory to container
COPY helloworld.go .
# Build the application
RUN go env -w GO111MODULE=off && go build -o helloworld .
# RUN the application
ENTRYPOINT ["./helloworld"]