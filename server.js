const express = require('express');
const app = express();
const http = require('http').createServer(app);
const io = require('socket.io')(http, {
    cors: {
        origin: "*",
        methods: ["GET", "POST"]
    }
});
const pty = require('node-pty');
const os = require('os');
const fs = require('fs');
const path = require('path');
const readline = require('readline');

// Config
const getClaudeHistoryPath = () => {
    const homeDir = os.homedir();

    // Check multiple possible locations for Claude history
    const possiblePaths = [
        process.env.CLAUDE_HISTORY_PATH, // Custom env var
        'C:\\Users\\15931 - Backend\\.claude\\history.jsonl', // Hardcoded user path
        path.join(homeDir, '.claude', 'history.jsonl'), // Default Linux/Mac
        path.join(homeDir, 'AppData', 'Local', 'Claude', 'history.jsonl'), // Windows AppData
        path.join(homeDir, '.config', 'Claude', 'history.jsonl'), // Alternative config
    ];

    for (const p of possiblePaths) {
        if (p && fs.existsSync(p)) {
            console.log('Found Claude history at:', p);
            return p;
        }
    }

    // Return default if not found
    return path.join(homeDir, '.claude', 'history.jsonl');
};

const CLAUDE_HISTORY_PATH = getClaudeHistoryPath();

// Get shell for Windows
const getShell = () => {
    if (os.platform() !== 'win32') return 'bash';

    // Use PowerShell for better compatibility with npm global commands
    return 'powershell.exe';
};

const SHELL = getShell();

// Set environment for Claude Code - use actual user profile, not Administrator
const ACTUAL_USER_HOME = 'C:\\Users\\15931 - Backend';
const GIT_PATH = 'C:\\Users\\15931 - Backend\\AppData\\Local\\Programs\\Git';
const CLAUDE_ENV = {
    ...process.env,
    HOME: ACTUAL_USER_HOME,
    USERPROFILE: ACTUAL_USER_HOME,
    HOMEPATH: '\\Users\\15931 - Backend',
    CLAUDE_CODE_GIT_BASH_PATH: `${GIT_PATH}\\bin\\bash.exe`,
    PATH: `${GIT_PATH}\\bin;${GIT_PATH}\\usr\\bin;${process.env.PATH || ''}`
};

app.use(express.static('public'));
app.use(express.json());

// Logging Middleware
app.use((req, res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
    next();
});

// API: Get History
app.get('/api/history', async (req, res) => {
    if (!fs.existsSync(CLAUDE_HISTORY_PATH)) {
        return res.json([]);
    }

    const sessions = new Map();
    const fileStream = fs.createReadStream(CLAUDE_HISTORY_PATH);
    const rl = readline.createInterface({
        input: fileStream,
        crlfDelay: Infinity
    });

    for await (const line of rl) {
        try {
            const entry = JSON.parse(line);
            if (entry.sessionId) {
                sessions.set(entry.sessionId, {
                    sessionId: entry.sessionId,
                    timestamp: entry.timestamp,
                    display: entry.display,
                    workspace: entry.workspace,
                    project: entry.project,
                    cwd: entry.cwd
                });
            }
        } catch (e) { }
    }

    const sortedSessions = Array.from(sessions.values()).sort((a, b) => b.timestamp - a.timestamp);
    res.json(sortedSessions);
});

// API: List Files for Explorer
app.get('/api/files', (req, res) => {
    let dirPath = req.query.path || os.homedir();

    try {
        // On Windows, list drives if at root or no path specified
        if (os.platform() === 'win32' && (!dirPath || dirPath === '/' || dirPath === '\\')) {
            const drives = [];
            // Common Windows drive letters
            for (let i = 65; i <= 90; i++) {
                const driveLetter = String.fromCharCode(i) + ':';
                const drivePath = driveLetter + '\\';
                try {
                    if (fs.existsSync(drivePath)) {
                        drives.push({
                            name: driveLetter,
                            path: drivePath,
                            type: 'drive'
                        });
                    }
                } catch (e) { }
            }

            return res.json({
                currentPath: 'Drives',
                folders: drives
            });
        }

        const items = fs.readdirSync(dirPath, { withFileTypes: true });
        const result = items
            .filter(item => item.isDirectory())
            .map(item => ({
                name: item.name,
                path: path.join(dirPath, item.name),
                type: 'directory'
            }));

        // Add ".." option if not root
        const parentDir = path.dirname(dirPath);
        if (parentDir !== dirPath) {
            result.unshift({ name: '.. (Up)', path: parentDir, type: 'parent' });
        }

        res.json({
            currentPath: dirPath,
            folders: result
        });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// Socket Logic
io.on('connection', (socket) => {
    console.log('Client connected');
    let ptyProcess = null;

    socket.on('spawn', (options) => {
        console.log('Spawn event received:', options);

        if (ptyProcess) {
            try {
                ptyProcess.kill();
            } catch (e) { }
        }

        let spawnCwd = options.cwd || os.homedir();
        console.log('Spawning PTY with cwd:', spawnCwd);

        try {
            ptyProcess = pty.spawn(SHELL, [], {
                name: 'xterm-color',
                cols: options.cols || 80,
                rows: options.rows || 30,
                cwd: spawnCwd,
                env: CLAUDE_ENV,
                useConpty: false  // Use WinPTY instead of ConPTY (fixes PM2 AttachConsole error)
            });

            ptyProcess.onData((data) => {
                socket.emit('output', data);
            });

            ptyProcess.onExit((res) => {
                socket.emit('output', `\r\n\x1b[31mShell exited with code ${res.exitCode}\x1b[0m\r\n`);
            });

        } catch (err) {
            console.error('Failed to spawn terminal:', err);
            socket.emit('output', `\r\n\x1b[31mError spawning terminal: ${err.message}\x1b[0m\r\n`);
            return;
        }

        // Auto-run CCS command if provided
        if (options.ccsCommand && ptyProcess) {
            setTimeout(() => {
                ptyProcess.write(options.ccsCommand + '\r');

                // Resume session if provided
                if (options.resumeSessionId) {
                    setTimeout(() => {
                        // Type resume command and press enter
                        ptyProcess.write(`/resume ${options.resumeSessionId}`);
                        setTimeout(() => {
                            ptyProcess.write('\r');
                        }, 300);
                    }, 3000); // Increased delay for CCS to load
                }
            }, 1000);
        }
    });

    socket.on('input', (data) => {
        if (ptyProcess) {
            ptyProcess.write(data);
        }
    });

    socket.on('resize', (size) => {
        if (ptyProcess) {
            ptyProcess.resize(size.cols, size.rows);
        }
    });

    socket.on('disconnect', () => {
        if (ptyProcess) {
            try {
                ptyProcess.kill();
            } catch (e) { }
        }
    });
});

// Port Logic
const PORT = process.env.PORT || 9000;

// Graceful shutdown handler
const server = http.listen(PORT, () => {
    console.log(`Web Terminal running on http://localhost:${PORT}`);
});

// Handle graceful shutdown
process.on('SIGTERM', () => {
    console.log('Received SIGTERM, shutting down gracefully...');
    server.close(() => {
        console.log('Server closed');
        process.exit(0);
    });
});

process.on('SIGINT', () => {
    console.log('Received SIGINT, shutting down gracefully...');
    server.close(() => {
        console.log('Server closed');
        process.exit(0);
    });
});

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
    console.error('Uncaught Exception:', err);
    server.close(() => {
        process.exit(1);
    });
});

process.on('unhandledRejection', (reason, promise) => {
    console.error('Unhandled Rejection at:', promise, 'reason:', reason);
    server.close(() => {
        process.exit(1);
    });
});
