FROM oven/bun:latest

WORKDIR /app

RUN chown -R bun:bun /app

COPY docs .

RUN bun install mintlify && bun install --no-audit --no-fund

# Create a shim to mock localStorage
RUN printf "global.localStorage = { getItem: () => null, setItem: () => {}, removeItem: () => {} };\n" > /app/localstorage-shim.js

ENV NODE_OPTIONS="--require /app/localstorage-shim.js"

# Run Mintlify with the shim preloaded
EXPOSE 3333

USER bun

CMD ["bunx", "mintlify", "dev", "--port", "3333"]