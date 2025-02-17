# Use a base image with Node.js installed
FROM node:18-alpine AS build
 
# Set working directory
WORKDIR /app
 
# Install required tools
RUN apk add --no-cache bash
 
# Copy package files first for better caching
COPY package.json package-lock.json ./
 
# Set NPM to allow unsafe operations
ENV NPM_CONFIG_UNSAFE_PERM=true
 
# Install dependencies with fallback
RUN npm ci || npm install --legacy-peer-deps
 
# Copy the rest of the application
COPY . .
 
# Ensure the build directory exists
RUN mkdir -p /app/build
 
# Build the React app
ENV PUBLIC_URL=/
RUN npm run build
 
# Use a lightweight production image
FROM node:18-alpine
 
# Set working directory
WORKDIR /app
 
# Copy built app
COPY --from=build /app/build /app/build
COPY --from=build /app/package.json /app/
COPY --from=build /app/node_modules /app/node_modules
 
# Install a lightweight HTTP server
RUN npm install -g serve
 
# Expose the application port
EXPOSE 3000
 
# Start the React app
CMD ["serve", "-s", "build", "-l", "3000"]