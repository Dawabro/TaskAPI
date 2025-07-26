FROM swift:5.10-jammy as builder

WORKDIR /build

# Copy package files
COPY Package.swift ./

# Resolve dependencies
RUN swift package resolve

# Copy source code
COPY Sources ./Sources

# Build with optimizations and less memory usage
RUN swift build -c release --static-swift-stdlib

# Production image
FROM ubuntu:22.04

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the built binary
COPY --from=builder /build/.build/release/App /app/

# Expose port
EXPOSE 8080

# Run the application
CMD ["./App", "serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
