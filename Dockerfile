# Stage 1: Compile WAT to WASM
FROM ubuntu:22.04 AS compilador
RUN apt-get update && apt-get install -y wabt && rm -rf /var/lib/apt/lists/*
WORKDIR /src
COPY suma.wat .
RUN wat2wasm suma.wat -o suma.wasm

# Step 2: Serve the page using Nginx
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/
COPY --from=compilador /src/suma.wasm /usr/share/nginx/html/
EXPOSE 80