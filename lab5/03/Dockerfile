# Start from the latest golang parent
FROM golang:latest
# Set the working directory
WORKDIR /myapp
# Copy source file from current directory to container
COPY welcome.go .
# Build the application
RUN go env -w GO111MODULE=off && go build -o welcome .

# Start from latest alpine parent image
FROM alpine:latest
# Set the working directory
WORKDIR /myapp

#Copy welcome app from current directory to container
COPY --from=0 /myapp/welcome .
# RUN the application
ENTRYPOINT ["./welcome"]