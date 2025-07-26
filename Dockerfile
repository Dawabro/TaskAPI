FROM swift:5.10-jammy

WORKDIR /app

# Copy package manifest
COPY Package.swift ./

# Resolve dependencies
RUN swift package resolve

# Copy source code
COPY Sources ./Sources

# Build the application
RUN swift build -c release

# Expose port
EXPOSE 8080

# Run the application
CMD ["swift", "run", "App", "serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
