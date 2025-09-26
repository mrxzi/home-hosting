const express = require('express');
const Docker = require('dockerode');
const { body, validationResult } = require('express-validator');
const router = express.Router();

const docker = new Docker({ socketPath: '/var/run/docker.sock' });

// Mock bot database
let bots = [
  {
    id: 1,
    name: 'Discord Bot',
    type: 'discord',
    status: 'running',
    containerId: 'bot-discord-1',
    port: 3001,
    createdAt: new Date(),
    config: {
      token: 'your-discord-token',
      prefix: '!',
      commands: ['ping', 'help', 'status']
    }
  },
  {
    id: 2,
    name: 'Telegram Bot',
    type: 'telegram',
    status: 'stopped',
    containerId: 'bot-telegram-1',
    port: 3002,
    createdAt: new Date(),
    config: {
      token: 'your-telegram-token',
      commands: ['start', 'help', 'info']
    }
  }
];

// Get all bots
router.get('/', async (req, res) => {
  try {
    // Get container status from Docker
    const containers = await docker.listContainers({ all: true });
    
    bots.forEach(bot => {
      const container = containers.find(c => c.Names.includes(bot.containerId));
      if (container) {
        bot.status = container.State === 'running' ? 'running' : 'stopped';
        bot.uptime = container.Status;
      }
    });

    res.json(bots);
  } catch (error) {
    console.error('Error fetching bots:', error);
    res.status(500).json({ error: 'Failed to fetch bots' });
  }
});

// Get bot by ID
router.get('/:id', async (req, res) => {
  try {
    const bot = bots.find(b => b.id === parseInt(req.params.id));
    if (!bot) {
      return res.status(404).json({ error: 'Bot not found' });
    }

    // Get container details
    try {
      const container = docker.getContainer(bot.containerId);
      const stats = await container.stats({ stream: false });
      bot.stats = {
        cpu: stats.cpu_stats,
        memory: stats.memory_stats,
        network: stats.networks
      };
    } catch (error) {
      console.log('Container not found or not running');
    }

    res.json(bot);
  } catch (error) {
    console.error('Error fetching bot:', error);
    res.status(500).json({ error: 'Failed to fetch bot' });
  }
});

// Create new bot
router.post('/', [
  body('name').notEmpty().withMessage('Bot name is required'),
  body('type').isIn(['discord', 'telegram', 'slack', 'custom']).withMessage('Invalid bot type'),
  body('config').isObject().withMessage('Config is required')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { name, type, config } = req.body;

    // Generate unique container name and port
    const containerId = `bot-${type}-${Date.now()}`;
    const port = 3000 + bots.length + 1;

    const newBot = {
      id: bots.length + 1,
      name,
      type,
      status: 'stopped',
      containerId,
      port,
      createdAt: new Date(),
      config
    };

    bots.push(newBot);

    // Create Docker container
    const container = await docker.createContainer({
      Image: 'node:18-alpine',
      name: containerId,
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

    res.status(201).json(newBot);

  } catch (error) {
    console.error('Error creating bot:', error);
    res.status(500).json({ error: 'Failed to create bot' });
  }
});

// Start bot
router.post('/:id/start', async (req, res) => {
  try {
    const bot = bots.find(b => b.id === parseInt(req.params.id));
    if (!bot) {
      return res.status(404).json({ error: 'Bot not found' });
    }

    const container = docker.getContainer(bot.containerId);
    await container.start();

    bot.status = 'running';
    
    // Emit real-time update
    req.app.get('io').emit('bot-status-update', {
      botId: bot.id,
      status: 'running'
    });

    res.json({ message: 'Bot started successfully', bot });

  } catch (error) {
    console.error('Error starting bot:', error);
    res.status(500).json({ error: 'Failed to start bot' });
  }
});

// Stop bot
router.post('/:id/stop', async (req, res) => {
  try {
    const bot = bots.find(b => b.id === parseInt(req.params.id));
    if (!bot) {
      return res.status(404).json({ error: 'Bot not found' });
    }

    const container = docker.getContainer(bot.containerId);
    await container.stop();

    bot.status = 'stopped';
    
    // Emit real-time update
    req.app.get('io').emit('bot-status-update', {
      botId: bot.id,
      status: 'stopped'
    });

    res.json({ message: 'Bot stopped successfully', bot });

  } catch (error) {
    console.error('Error stopping bot:', error);
    res.status(500).json({ error: 'Failed to stop bot' });
  }
});

// Restart bot
router.post('/:id/restart', async (req, res) => {
  try {
    const bot = bots.find(b => b.id === parseInt(req.params.id));
    if (!bot) {
      return res.status(404).json({ error: 'Bot not found' });
    }

    const container = docker.getContainer(bot.containerId);
    await container.restart();

    bot.status = 'running';
    
    // Emit real-time update
    req.app.get('io').emit('bot-status-update', {
      botId: bot.id,
      status: 'running'
    });

    res.json({ message: 'Bot restarted successfully', bot });

  } catch (error) {
    console.error('Error restarting bot:', error);
    res.status(500).json({ error: 'Failed to restart bot' });
  }
});

// Delete bot
router.delete('/:id', async (req, res) => {
  try {
    const botIndex = bots.findIndex(b => b.id === parseInt(req.params.id));
    if (botIndex === -1) {
      return res.status(404).json({ error: 'Bot not found' });
    }

    const bot = bots[botIndex];

    // Stop and remove container
    try {
      const container = docker.getContainer(bot.containerId);
      await container.stop();
      await container.remove();
    } catch (error) {
      console.log('Container already removed or not found');
    }

    bots.splice(botIndex, 1);

    res.json({ message: 'Bot deleted successfully' });

  } catch (error) {
    console.error('Error deleting bot:', error);
    res.status(500).json({ error: 'Failed to delete bot' });
  }
});

// Get bot logs
router.get('/:id/logs', async (req, res) => {
  try {
    const bot = bots.find(b => b.id === parseInt(req.params.id));
    if (!bot) {
      return res.status(404).json({ error: 'Bot not found' });
    }

    const container = docker.getContainer(bot.containerId);
    const logs = await container.logs({
      stdout: true,
      stderr: true,
      timestamps: true,
      tail: 100
    });

    res.json({ logs: logs.toString() });

  } catch (error) {
    console.error('Error fetching bot logs:', error);
    res.status(500).json({ error: 'Failed to fetch bot logs' });
  }
});

module.exports = router;
