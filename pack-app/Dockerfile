# Stage 1: Build Go backend
FROM golang:1.21-alpine AS backend-builder
WORKDIR /build
COPY app1-server .
RUN go mod tidy
RUN CGO_ENABLED=0 GOOS=linux go build -o server .

# Stage 2: Build React frontend
FROM node:20-alpine AS frontend-builder
WORKDIR /build
COPY app-web .
RUN npm install
RUN npm run build

# Stage 3: Final image
FROM alpine:3.18
RUN apk add --no-cache nginx

# Copy built artifacts
COPY --from=backend-builder /build/server /app/server
COPY --from=frontend-builder /build/dist /app/web

# Configure nginx
RUN mkdir -p /run/nginx
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

# Start nginx and the Go server
CMD ["sh", "-c", "/app/server & nginx -g 'daemon off;'"]
