
# 1. Use an official Node image to build the React app
FROM node:16-alpine AS build

# Create app directory
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the project files
COPY . .

# Build the React app for production
RUN npm run build

# 2. Use an NGINX image to serve the build output
FROM nginx:alpine

# Copy compiled build from the 'build' stage
COPY --from=build /app/build /usr/share/nginx/html

# Expose port 80 and run NGINX
EXPOSE 3000

# Use Node.js for building React
FROM node:20 AS builder
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

# Use Nginx for serving the app
FROM nginx:alpine
COPY --from=builder /app/build /usr/share/nginx/html
EXPOSE 3000
CMD ["nginx", "-g", "daemon off;"]
