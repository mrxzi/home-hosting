const express = require('express');
const Docker = require('dockerode');
const router = express.Router();

const docker = new Docker({ socketPath: '/var/run/docker.sock' });

// Get container monitoring data
router.get('/containers', async (req, res) => {
  try {
    const containers = await docker.listContainers({ all: true });
    
    const containerStats = await Promise.all(
      containers.map(async (container) => {
        try {
          const stats = await docker.getContainer(container.Id).stats({ stream: false });
          return {
            id: container.Id,
            name: container.Names[0].replace('/', ''),
            status: container.State,
            cpu: stats.cpu_stats,
            memory: stats.memory_stats,
            network: stats.networks
          };
        } catch (error) {
          return {
            id: container.Id,
            name: container.Names[0].replace('/', ''),
            status: container.State,
            error: 'Stats unavailable'
          };
        }
      })
    );

    res.json(containerStats);
  } catch (error) {
    console.error('Error fetching container stats:', error);
    res.status(500).json({ error: 'Failed to fetch container stats' });
  }
});

// Get system monitoring data
router.get('/system', async (req, res) => {
  try {
    const si = require('systeminformation');
    
    const [cpuLoad, memory, diskIO, networkStats] = await Promise.all([
      si.currentLoad(),
      si.mem(),
      si.disksIO(),
      si.networkStats()
    ]);

    res.json({
      timestamp: new Date().toISOString(),
      cpu: {
        load: cpuLoad.currentload,
        loadAverage: cpuLoad.avgload
      },
      memory: {
        used: memory.used,
        free: memory.free,
        percentage: (memory.used / memory.total) * 100
      },
      disk: diskIO,
      network: networkStats
    });
  } catch (error) {
    console.error('Error fetching system monitoring:', error);
    res.status(500).json({ error: 'Failed to fetch system monitoring' });
  }
});

module.exports = router;
