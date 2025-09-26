const express = require('express');
const si = require('systeminformation');
const router = express.Router();

// Get system information
router.get('/info', async (req, res) => {
  try {
    const [cpu, memory, disk, network] = await Promise.all([
      si.cpu(),
      si.mem(),
      si.diskLayout(),
      si.networkInterfaces()
    ]);

    res.json({
      cpu: {
        manufacturer: cpu.manufacturer,
        brand: cpu.brand,
        cores: cpu.cores,
        physicalCores: cpu.physicalCores,
        speed: cpu.speed
      },
      memory: {
        total: memory.total,
        free: memory.free,
        used: memory.used,
        available: memory.available
      },
      disk: disk.map(d => ({
        name: d.name,
        size: d.size,
        type: d.type
      })),
      network: network.map(n => ({
        iface: n.iface,
        ip4: n.ip4,
        ip6: n.ip6
      }))
    });
  } catch (error) {
    console.error('Error fetching system info:', error);
    res.status(500).json({ error: 'Failed to fetch system information' });
  }
});

// Get system stats
router.get('/stats', async (req, res) => {
  try {
    const [cpuLoad, memory, diskIO, networkStats] = await Promise.all([
      si.currentLoad(),
      si.mem(),
      si.disksIO(),
      si.networkStats()
    ]);

    res.json({
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
    console.error('Error fetching system stats:', error);
    res.status(500).json({ error: 'Failed to fetch system stats' });
  }
});

module.exports = router;
