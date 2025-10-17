FROM node:current-alpine

WORKDIR /app

RUN chown -R node:node /app

COPY . .

RUN npm i mintlify && npm i --no-audit --no-fund

# Create a shim to mock localStorage
RUN printf "global.localStorage = { getItem: () => null, setItem: () => {}, removeItem: () => {} };\n" > /app/localstorage-shim.js

ENV NODE_OPTIONS="--require /app/localstorage-shim.js"

# Run Mintlify with the shim preloaded
EXPOSE 3333

USER node

CMD ["npx", "mintlify", "dev", "--port", "3333"]
