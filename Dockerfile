FROM node:20-alpine

# Install build dependencies for node-pty
RUN apk add --no-cache python3 make g++

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --omit=dev

# Copy application files
COPY . .

EXPOSE 3003

CMD ["node", "server.js"]
