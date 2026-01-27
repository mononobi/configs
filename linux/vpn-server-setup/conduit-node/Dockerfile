# Use a lightweight Linux base (Debian Slim is reliable for binaries)
FROM debian:stable-slim

# Install wget so we can download the file
RUN apt-get update && apt-get install -y wget ca-certificates && rm -rf /var/lib/apt/lists/*

# Set the working folder inside the container
WORKDIR /app

# Download the OFFICIAL binary directly from Psiphon's GitHub
RUN wget -O conduit https://github.com/Psiphon-Inc/conduit/releases/download/release-cli-1.1.0/conduit-linux-amd64

# Make it executable
RUN chmod +x conduit

# Create the data folder
RUN mkdir data

# Set the startup command
ENTRYPOINT ["./conduit"]
