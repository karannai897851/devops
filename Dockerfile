FROM node:18-alpine

# Create working directory
WORKDIR /app

# Copy server file
COPY server.js .

# Initialize a package.json
RUN npm init -y

# Expose the port your app listens on
EXPOSE 8081

# Start the server
CMD ["node", "server.js"]
