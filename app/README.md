# F1 Driver of the Day - Voting Application

Formula 1 "Driver of the Day" voting application, deployed on Kubernetes.

## 🏎️ Architecture

Multi-Page Application (MPA) with SvelteKit including:
- **Route `/`** : Voting page with the 2025 F1 drivers grid
- **Route `/results`** : Results page with real-time ranking

## 🛠️ Technical Stack

- **Frontend/Backend** : SvelteKit + TypeScript
- **UI** : Shadcn-Svelte + TailwindCSS (FIA theme)
- **Database** : Redis (with ioredis)
- **Container** : Docker (adapter-node)
- **Orchestration** : Kubernetes (K3s)

## 🚀 Quick Start

### Local Development

1. **Install dependencies**
   ```bash
   cd app
   npm install
   ```

2. **Start Redis locally**
   ```bash
   # At the project root
   docker-compose up redis -d
   ```

3. **Launch the application**
   ```bash
   cd app
   npm run dev
   ```

   The application will be available at `http://localhost:5173`

### Docker Compose

```bash
# At the project root
docker-compose up --build
```

The application will be available at `http://localhost:3000`

## 📁 Project Structure

```
app/
├── src/
│   ├── lib/
│   │   ├── redis.ts          # Redis singleton
│   │   ├── drivers.ts        # List of 20 F1 2025 drivers
│   │   └── components/ui/    # Shadcn components
│   └── routes/
│       ├── +page.svelte           # Voting page (/)
│       ├── +page.server.ts        # Server load + vote action
│       └── results/
│           ├── +page.svelte       # Results page (/results)
│           └── +page.server.ts    # Server load scores
├── Dockerfile                 # Optimized Docker image
└── svelte.config.js          # Config adapter-node
```

## 🎯 User Flow

1. **Vote** : User arrives at `/`, sees the 20 drivers and clicks "VOTE"
2. **Processing** : Server increments score in Redis (`ZINCRBY`)
3. **Redirection** : HTTP 303 redirect to `/results`
4. **Results** : Display sorted ranking + Pod hostname

## 🎨 Design

Dark interface inspired by FIA design with:
- Authentic F1 2025 team colors
- Driver cards with numbers and teams
- Progress bars with percentages
- Debug footer displaying Kubernetes Pod

## 🐳 Docker

The `Dockerfile` uses an optimized multi-stage build:
- Build with `node:20-alpine`
- Minimal final image with only production dependencies

## ☸️ Kubernetes Deployment

Environment variables:
- `REDIS_URL` : Redis connection URL (default: `redis://localhost:6379`)
- `PORT` : Application port (default: `3000`)

## 📊 Redis Database

Structure:
- **Key** : `f1:votes` (Sorted Set)
- **Members** : Driver IDs
- **Scores** : Number of votes

Useful Redis commands:
```bash
# View all votes
redis-cli ZREVRANGE f1:votes 0 -1 WITHSCORES

# Reset votes
redis-cli DEL f1:votes
```

## 🏁 F1 2025 Drivers

The application includes the 20 drivers from the 2025 season with their teams:
- Red Bull Racing (Verstappen, Pérez)
- Ferrari (Hamilton, Leclerc)
- McLaren (Norris, Piastri)
- Mercedes (Russell, Antonelli)
- And 6 other teams...

## 📝 License

MIT
npx sv create my-app
```

To recreate this project with the same configuration:

```sh
# recreate this project
npx sv create --template minimal --types ts --add prettier tailwindcss="plugins:none" --install npm app
```

## Developing

Once you've created a project and installed dependencies with `npm install` (or `pnpm install` or `yarn`), start a development server:

```sh
npm run dev

# or start the server and open the app in a new browser tab
npm run dev -- --open
```

## Building

To create a production version of your app:

```sh
npm run build
```

You can preview the production build with `npm run preview`.

> To deploy your app, you may need to install an [adapter](https://svelte.dev/docs/kit/adapters) for your target environment.
