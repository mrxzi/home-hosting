const TelegramBot = require('node-telegram-bot-api');
require('dotenv').config();

// Bot configuration
const config = {
  token: process.env.BOT_TOKEN || process.env.TELEGRAM_TOKEN,
  ownerId: process.env.OWNER_ID
};

if (!config.token) {
  console.error('❌ Telegram bot token not found! Please set BOT_TOKEN or TELEGRAM_TOKEN environment variable.');
  process.exit(1);
}

// Create bot instance
const bot = new TelegramBot(config.token, { polling: true });

console.log('🤖 Telegram bot started!');

// Start command
bot.onText(/\/start/, (msg) => {
  const chatId = msg.chat.id;
  const welcomeMessage = `
🤖 *Home Hosting Bot*

Welcome to the Home Hosting System bot!

Available commands:
/help - Show help message
/status - Show system status
/info - Show bot information
/ping - Check bot response time

This bot helps you manage your home hosting system remotely.
  `;
  
  bot.sendMessage(chatId, welcomeMessage, { parse_mode: 'Markdown' });
});

// Help command
bot.onText(/\/help/, (msg) => {
  const chatId = msg.chat.id;
  const helpMessage = `
📋 *Available Commands:*

/start - Start the bot
/help - Show this help message
/status - Show system status
/info - Show bot information
/ping - Check bot response time

🔧 *System Management:*
This bot is part of your home hosting system and can help you monitor and manage your servers remotely.
  `;
  
  bot.sendMessage(chatId, helpMessage, { parse_mode: 'Markdown' });
});

// Status command
bot.onText(/\/status/, (msg) => {
  const chatId = msg.chat.id;
  
  const statusMessage = `
📊 *System Status*

🟢 Bot Status: Online
⏱️ Uptime: ${formatUptime(process.uptime())}
💾 Memory: ${Math.round(process.memoryUsage().heapUsed / 1024 / 1024)}MB
🖥️ Platform: ${process.platform}
📅 Started: ${new Date().toLocaleString()}

*Home Hosting System is running smoothly!*
  `;
  
  bot.sendMessage(chatId, statusMessage, { parse_mode: 'Markdown' });
});

// Info command
bot.onText(/\/info/, (msg) => {
  const chatId = msg.chat.id;
  
  const infoMessage = `
🤖 *Bot Information*

📛 Name: Home Hosting Bot
🆔 ID: ${bot.options.username || 'N/A'}
📅 Created: ${new Date().toLocaleString()}
🔧 Node.js: ${process.version}
📦 Version: 1.0.0

*Part of the Home Hosting System*
  `;
  
  bot.sendMessage(chatId, infoMessage, { parse_mode: 'Markdown' });
});

// Ping command
bot.onText(/\/ping/, (msg) => {
  const chatId = msg.chat.id;
  const startTime = Date.now();
  
  bot.sendMessage(chatId, '🏓 Pong!').then(() => {
    const endTime = Date.now();
    const responseTime = endTime - startTime;
    
    bot.sendMessage(chatId, `⚡ Response time: ${responseTime}ms`);
  });
});

// Error handling
bot.on('error', (error) => {
  console.error('Telegram bot error:', error);
});

bot.on('polling_error', (error) => {
  console.error('Telegram polling error:', error);
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

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('🛑 Shutting down Telegram bot...');
  bot.stopPolling();
  process.exit(0);
});

process.on('SIGTERM', () => {
  console.log('🛑 Shutting down Telegram bot...');
  bot.stopPolling();
  process.exit(0);
});
