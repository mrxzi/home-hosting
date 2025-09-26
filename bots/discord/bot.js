const { Client, GatewayIntentBits, Events } = require('discord.js');
require('dotenv').config();

// Create Discord client
const client = new Client({
  intents: [
    GatewayIntentBits.Guilds,
    GatewayIntentBits.GuildMessages,
    GatewayIntentBits.MessageContent,
    GatewayIntentBits.GuildMembers
  ]
});

// Bot configuration
const config = {
  token: process.env.BOT_TOKEN || process.env.DISCORD_TOKEN,
  prefix: process.env.BOT_PREFIX || '!',
  ownerId: process.env.OWNER_ID
};

// Bot ready event
client.once(Events.ClientReady, (readyClient) => {
  console.log(`🤖 Discord bot ready! Logged in as ${readyClient.user.tag}`);
  console.log(`📊 Serving ${client.guilds.cache.size} servers`);
  
  // Set bot status
  client.user.setActivity('Home Hosting System', { type: 'WATCHING' });
});

// Message handler
client.on(Events.MessageCreate, async (message) => {
  // Ignore bot messages
  if (message.author.bot) return;
  
  // Check for command prefix
  if (!message.content.startsWith(config.prefix)) return;
  
  const args = message.content.slice(config.prefix.length).trim().split(/ +/);
  const command = args.shift().toLowerCase();
  
  try {
    switch (command) {
      case 'ping':
        const sent = await message.reply('Pinging...');
        const timeDiff = sent.createdTimestamp - message.createdTimestamp;
        await sent.edit(`🏓 Pong! Latency: ${timeDiff}ms | API: ${client.ws.ping}ms`);
        break;
        
      case 'help':
        const helpEmbed = {
          color: 0x0099ff,
          title: '🤖 Home Hosting Bot Commands',
          description: 'Available commands for the home hosting system',
          fields: [
            {
              name: `${config.prefix}ping`,
              value: 'Check bot latency',
              inline: true
            },
            {
              name: `${config.prefix}help`,
              value: 'Show this help message',
              inline: true
            },
            {
              name: `${config.prefix}status`,
              value: 'Show system status',
              inline: true
            },
            {
              name: `${config.prefix}info`,
              value: 'Show bot information',
              inline: true
            }
          ],
          timestamp: new Date().toISOString(),
          footer: {
            text: 'Home Hosting System'
          }
        };
        await message.reply({ embeds: [helpEmbed] });
        break;
        
      case 'status':
        const statusEmbed = {
          color: 0x00ff00,
          title: '📊 System Status',
          fields: [
            {
              name: 'Bot Status',
              value: '🟢 Online',
              inline: true
            },
            {
              name: 'Uptime',
              value: formatUptime(process.uptime()),
              inline: true
            },
            {
              name: 'Memory Usage',
              value: `${Math.round(process.memoryUsage().heapUsed / 1024 / 1024)}MB`,
              inline: true
            },
            {
              name: 'Servers',
              value: client.guilds.cache.size.toString(),
              inline: true
            },
            {
              name: 'Users',
              value: client.users.cache.size.toString(),
              inline: true
            }
          ],
          timestamp: new Date().toISOString()
        };
        await message.reply({ embeds: [statusEmbed] });
        break;
        
      case 'info':
        const infoEmbed = {
          color: 0x0099ff,
          title: '🤖 Bot Information',
          fields: [
            {
              name: 'Bot Name',
              value: client.user.username,
              inline: true
            },
            {
              name: 'Bot ID',
              value: client.user.id,
              inline: true
            },
            {
              name: 'Created',
              value: client.user.createdAt.toDateString(),
              inline: true
            },
            {
              name: 'Node.js Version',
              value: process.version,
              inline: true
            },
            {
              name: 'Discord.js Version',
              value: require('discord.js').version,
              inline: true
            }
          ],
          thumbnail: {
            url: client.user.displayAvatarURL()
          },
          timestamp: new Date().toISOString()
        };
        await message.reply({ embeds: [infoEmbed] });
        break;
        
      default:
        await message.reply(`❓ Unknown command. Use \`${config.prefix}help\` to see available commands.`);
    }
  } catch (error) {
    console.error('Command error:', error);
    await message.reply('❌ An error occurred while executing the command.');
  }
});

// Error handling
client.on('error', (error) => {
  console.error('Discord client error:', error);
});

process.on('unhandledRejection', (error) => {
  console.error('Unhandled promise rejection:', error);
});

// Utility function to format uptime
function formatUptime(seconds) {
  const days = Math.floor(seconds / 86400);
  const hours = Math.floor((seconds % 86400) / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  
  if (days > 0) {
    return `${days}d ${hours}h ${minutes}m`;
  } else if (hours > 0) {
    return `${hours}h ${minutes}m`;
  } else {
    return `${minutes}m`;
  }
}

// Start bot
if (!config.token) {
  console.error('❌ Discord bot token not found! Please set BOT_TOKEN or DISCORD_TOKEN environment variable.');
  process.exit(1);
}

client.login(config.token).catch((error) => {
  console.error('❌ Failed to login to Discord:', error);
  process.exit(1);
});
