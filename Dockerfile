# ---------- Build stage ----------
FROM node:20-alpine AS build

WORKDIR /app

ARG VITE_GITHUB_TOKEN
ARG VITE_MAX_REPOS

ENV VITE_GITHUB_TOKEN=$VITE_GITHUB_TOKEN
ENV VITE_MAX_REPOS=$VITE_MAX_REPOS

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

# ---------- Runtime stage ----------
FROM nginx:alpine

RUN rm -rf /usr/share/nginx/html/*

COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
