FROM registry.access.redhat.com/ubi9/go-toolset:1.18.4-11 as builder

USER 0
WORKDIR /workspace

ENV PATH="${PATH}:/opt/app-root/src/go/bin"
RUN go env -w GO111MODULE=on

# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum
# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
RUN go mod download

# Copy the go source
COPY main.go main.go
COPY internal/ internal/
COPY config/ config/

# Install Ginkgo CLI to run unit tests inside the container
RUN go install github.com/onsi/ginkgo/v2/ginkgo@v2.5.0

# Build
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GO111MODULE=on go build -mod=mod main.go

ENTRYPOINT ["/workspace/main"]
