FROM node:16.17.0-alpine as builder

WORKDIR /app

COPY ./package.json .
COPY ./yarn.lock .

RUN yarn install
COPY . .

# Pass the API key securely during build
ARG TMDB_V3_API_KEY
ENV VITE_APP_TMDB_V3_API_KEY=${TMDB_V3_API_KEY}
ENV VITE_APP_API_ENDPOINT_URL="https://api.themoviedb.org/3"

RUN yarn build

FROM nginx:stable-alpine
WORKDIR /usr/share/nginx/html

# Remove default nginx static assets
RUN rm -rf ./*

# Copy the build output from the builder stage
COPY --from=builder /app/dist .

# --- NEW STEP: Copy the custom Nginx config ---
COPY nginx.conf /etc/nginx/conf.d/default.conf
# ----------------------------------------------

EXPOSE 80
ENTRYPOINT ["nginx", "-g", "daemon off;"]
