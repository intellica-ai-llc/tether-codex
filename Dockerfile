FROM node:20-slim
WORKDIR /app
RUN npm install -g pnpm@9
COPY . .
RUN pnpm install --frozen-lockfile && pnpm build
EXPOSE 3000 8787
CMD ["pnpm", "dev"]
