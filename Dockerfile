# Stage 1: build the Jekyll site
FROM ruby:3.3-slim AS build
RUN apt-get update && apt-get install -y --no-install-recommends build-essential git \
    && rm -rf /var/lib/apt/lists/*
RUN gem install jekyll jekyll-sitemap jekyll-feed webrick
WORKDIR /site
COPY . .
RUN jekyll build --destination /out

# Stage 2: serve the static output
FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /out /usr/share/nginx/html
EXPOSE 80
