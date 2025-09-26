const express = require('express');
const Docker = require('dockerode');
const cron = require('node-cron');
const winston = require('winston');
require('dotenv').config();

const app = express();
const docker = new Docker({ socketPath: '/var/run/docker.sock' });

// Configure logger
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' }),
    new winston.transports.Console({
      format: winston.format.simple()
    })
  ]
});

// Bot management functions
class BotManager {
  constructor() {
    this.bots = new Map();
    this.loadBots();
  }

  async loadBots() {
    try {
      const containers = await docker.listContainers({ all: true });
      const botContainers = containers.filter(c => 
        c.Names.some(name => name.includes('bot-'))
      );

      for (const container of botContainers) {
        const containerName = container.Names[0].replace('/', '');
        this.bots.set(containerName, {
          id: container.Id,
          name: containerName,
          status: container.State,
          image: container.Image,
          created: container.Created
        });
      }

      logger.info(`Loaded ${this.bots.size} bot containers`);
    } catch (error) {
      logger.error('Error loading bots:', error);
    }
  }

  async createBot(type, config) {
    try {
      const containerName = `bot-${type}-${Date.now()}`;
      const port = 3000 + this.bots.size + 1;

      const container = await docker.createContainer({
        Image: 'node:18-alpine',
        name: containerName,
        Cmd: ['node', 'bot.js'],
        Env: [
          `BOT_TYPE=${type}`,
          `BOT_TOKEN=${config.token}`,
          `BOT_PREFIX=${config.prefix || '!'}`
        ],
        ExposedPorts: {
          [`${port}/tcp`]: {}
        },
        HostConfig: {
          PortBindings: {
            [`${port}/tcp`]: [{ HostPort: port.toString() }]
          },
          Binds: [
            `./bots/${type}:/app`
          ]
        },
        WorkingDir: '/app'
      });

      this.bots.set(containerName, {
        id: container.id,
        name: containerName,
        status: 'created',
        type,
        port,
        config
      });

      logger.info(`Created bot container: ${containerName}`);
      return containerName;
    } catch (error) {
      logger.error('Error creating bot:', error);
      throw error;
    }
  }

  async startBot(containerName) {
    try {
      const container = docker.getContainer(containerName);
      await container.start();
      
      if (this.bots.has(containerName)) {
        this.bots.get(containerName).status = 'running';
      }
      
      logger.info(`Started bot: ${containerName}`);
    } catch (error) {
      logger.error(`Error starting bot ${containerName}:`, error);
      throw error;
    }
  }

  async stopBot(containerName) {
    try {
      const container = docker.getContainer(containerName);
      await container.stop();
      
      if (this.bots.has(containerName)) {
        this.bots.get(containerName).status = 'stopped';
      }
      
      logger.info(`Stopped bot: ${containerName}`);
    } catch (error) {
      logger.error(`Error stopping bot ${containerName}:`, error);
      throw error;
    }
  }

  async restartBot(containerName) {
    try {
      const container = docker.getContainer(containerName);
      await container.restart();
      
      if (this.bots.has(containerName)) {
        this.bots.get(containerName).status = 'running';
      }
      
      logger.info(`Restarted bot: ${containerName}`);
    } catch (error) {
      logger.error(`Error restarting bot ${containerName}:`, error);
      throw error;
    }
  }

  async deleteBot(containerName) {
    try {
      const container = docker.getContainer(containerName);
      await container.stop();
      await container.remove();
      
      this.bots.delete(containerName);
      logger.info(`Deleted bot: ${containerName}`);
    } catch (error) {
      logger.error(`Error deleting bot ${containerName}:`, error);
      throw error;
    }
  }

  getBots() {
    return Array.from(this.bots.values());
  }

  getBot(containerName) {
    return this.bots.get(containerName);
  }
}

const botManager = new BotManager();

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    bots: botManager.getBots().length
  });
});

// Get all bots
app.get('/bots', (req, res) => {
  try {
    const bots = botManager.getBots();
    res.json(bots);
  } catch (error) {
    logger.error('Error fetching bots:', error);
    res.status(500).json({ error: 'Failed to fetch bots' });
  }
});

// Create bot
app.post('/bots', express.json(), async (req, res) => {
  try {
    const { type, config } = req.body;
    const containerName = await botManager.createBot(type, config);
    res.json({ 
      message: 'Bot created successfully',
      containerName 
    });
  } catch (error) {
    logger.error('Error creating bot:', error);
    res.status(500).json({ error: 'Failed to create bot' });
  }
});

// Start bot
app.post('/bots/:name/start', async (req, res) => {
  try {
    await botManager.startBot(req.params.name);
    res.json({ message: 'Bot started successfully' });
  } catch (error) {
    logger.error('Error starting bot:', error);
    res.status(500).json({ error: 'Failed to start bot' });
  }
});

// Stop bot
app.post('/bots/:name/stop', async (req, res) => {
  try {
    await botManager.stopBot(req.params.name);
    res.json({ message: 'Bot stopped successfully' });
  } catch (error) {
    logger.error('Error stopping bot:', error);
    res.status(500).json({ error: 'Failed to stop bot' });
  }
});

// Restart bot
app.post('/bots/:name/restart', async (req, res) => {
  try {
    await botManager.restartBot(req.params.name);
    res.json({ message: 'Bot restarted successfully' });
  } catch (error) {
    logger.error('Error restarting bot:', error);
    res.status(500).json({ error: 'Failed to restart bot' });
  }
});

// Delete bot
app.delete('/bots/:name', async (req, res) => {
  try {
    await botManager.deleteBot(req.params.name);
    res.json({ message: 'Bot deleted successfully' });
  } catch (error) {
    logger.error('Error deleting bot:', error);
    res.status(500).json({ error: 'Failed to delete bot' });
  }
});

// Cron job to update bot status
cron.schedule('*/30 * * * * *', async () => {
  try {
    await botManager.loadBots();
    logger.debug('Updated bot statuses');
  } catch (error) {
    logger.error('Error updating bot statuses:', error);
  }
});

const PORT = process.env.PORT || 4000;

app.listen(PORT, '0.0.0.0', () => {
  logger.info(`🤖 Bot Manager running on port ${PORT}`);
});

module.exports = app;
