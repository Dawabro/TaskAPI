FROM swift:5.10-jammy as builder

WORKDIR /build
COPY Package.swift ./
RUN swift package resolve
COPY Sources ./Sources
RUN swift build -c release --static-swift-stdlib

FROM ubuntu:22.04
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=builder /build/.build/release/App /app/

# Use Railway's PORT environment variable
EXPOSE $PORT
CMD ["sh", "-c", "./App serve --env production --hostname 0.0.0.0 --port $PORT"]
