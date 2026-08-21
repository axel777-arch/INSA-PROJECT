FROM node:20-alpine

# Set working directory for the entire monorepo
WORKDIR /app

# Copy package.json from the root
COPY package.json package-lock.json* ./

# Copy backend package.json
COPY backend/package.json backend/package-lock.json* ./backend/

# Install root dependencies (including drizzle-orm which the backend relies on)
RUN npm install

# Install backend dependencies
WORKDIR /app/backend
RUN npm install

# Copy all the source code (backend and database schema)
WORKDIR /app
COPY backend ./backend
COPY database ./database

# We expose the backend port
EXPOSE 3000

# Start the application using tsx directly from backend folder
WORKDIR /app/backend
CMD ["npm", "run", "dev"]
