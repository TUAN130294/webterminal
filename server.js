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
const crypto = require('crypto');
const QRCode = require('qrcode');

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

// Share Terminal Management
const activeTerminals = new Map(); // socketId -> { sessionId, cwd, ptyProcess }
const shareLinks = new Map();      // token -> { sessionId, socketId, created, expires, readOnly }

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

// API: Create Share Link for Terminal
app.post('/api/terminal/share', (req, res) => {
    const { socketId, sessionId, readOnly } = req.body;

    if (!socketId || !sessionId) {
        return res.status(400).json({ error: 'Missing socketId or sessionId' });
    }

    // Check if terminal exists
    const terminal = activeTerminals.get(socketId);
    if (!terminal) {
        return res.status(404).json({ error: 'Terminal not found' });
    }

    // Generate unique token
    const token = crypto.randomBytes(16).toString('hex');
    const baseUrl = `${req.protocol}://${req.get('host')}`;
    const shareUrl = `${baseUrl}/mobile/${token}`;

    // Store share link
    shareLinks.set(token, {
        sessionId,
        socketId,
        created: Date.now(),
        expires: Date.now() + 3600000, // 1 hour
        readOnly: readOnly || false
    });

    // Generate QR code
    QRCode.toDataURL(shareUrl, (err, qrDataUrl) => {
        if (err) {
            return res.status(500).json({ error: 'Failed to generate QR code' });
        }

        res.json({
            token,
            link: shareUrl,
            qrCode: qrDataUrl,
            expires: new Date(Date.now() + 3600000).toISOString()
        });
    });
});

// API: Get Active Terminals
app.get('/api/terminal/active', (req, res) => {
    const activeList = [];

    for (const [socketId, data] of activeTerminals.entries()) {
        activeList.push({
            socketId: socketId,
            sessionId: data.sessionId,
            cwd: data.cwd,
            createdAt: data.createdAt
        });
    }

    res.json(activeList);
});

// API: Get Active Share Links
app.get('/api/terminal/active-shares', (req, res) => {
    const now = Date.now();
    const activeShares = [];

    // Clean expired links
    for (const [token, data] of shareLinks.entries()) {
        if (data.expires < now) {
            shareLinks.delete(token);
        } else {
            activeShares.push({
                token: token.substring(0, 8) + '...',
                sessionId: data.sessionId.substring(0, 8),
                created: new Date(data.created).toLocaleString(),
                expires: new Date(data.expires).toLocaleString(),
                readOnly: data.readOnly,
                isActive: activeTerminals.has(data.socketId)
            });
        }
    }

    res.json(activeShares);
});

// API: Revoke Share Link
app.delete('/api/terminal/share/:token', (req, res) => {
    const { token } = req.params;

    if (shareLinks.has(token)) {
        shareLinks.delete(token);
        res.json({ success: true, message: 'Share link revoked' });
    } else {
        res.status(404).json({ error: 'Share link not found' });
    }
});

// Route: Mobile Terminal Page
app.get('/mobile/:token', (req, res) => {
    const { token } = req.params;
    const shareData = shareLinks.get(token);

    if (!shareData) {
        return res.status(404).send(`
            <html>
            <head><title>Invalid Link</title></head>
            <body style="background: #0d1117; color: #c9d1d9; font-family: sans-serif; text-align: center; padding: 50px;">
                <h1>❌ Invalid or Expired Link</h1>
                <p>This share link is invalid or has expired.</p>
            </body>
            </html>
        `);
    }

    if (shareData.expires < Date.now()) {
        shareLinks.delete(token);
        return res.status(410).send(`
            <html>
            <head><title>Link Expired</title></head>
            <body style="background: #0d1117; color: #c9d1d9; font-family: sans-serif; text-align: center; padding: 50px;">
                <h1>⏰ Link Expired</h1>
                <p>This share link has expired. Please request a new one.</p>
            </body>
            </html>
        `);
    }

    res.sendFile(path.join(__dirname, 'public', 'mobile.html'));
});

// Socket Logic
io.on('connection', (socket) => {
    console.log('Client connected');
    let ptyProcess = null;
    let currentSessionId = null;

    // Check if connecting via share link
    const shareToken = socket.handshake.auth?.shareToken;
    if (shareToken) {
        const shareData = shareLinks.get(shareToken);

        if (!shareData || shareData.expires < Date.now()) {
            console.log('Invalid or expired share token');
            socket.emit('error', 'Share link invalid or expired');
            socket.disconnect();
            return;
        }

        // Connect to existing terminal
        const existingTerminal = activeTerminals.get(shareData.socketId);
        if (existingTerminal && existingTerminal.ptyProcess) {
            ptyProcess = existingTerminal.ptyProcess;
            currentSessionId = shareData.sessionId;

            console.log(`Shared terminal connected: ${currentSessionId.substring(0, 8)} (read-only: ${shareData.readOnly})`);

            // Send current terminal size
            socket.emit('connected', {
                sessionId: currentSessionId,
                readOnly: shareData.readOnly
            });

            // Forward output to this socket
            const outputHandler = (data) => {
                socket.emit('output', data);
            };
            ptyProcess.onData(outputHandler);

            // Handle input (if not read-only)
            if (!shareData.readOnly) {
                socket.on('input', (data) => {
                    if (ptyProcess) ptyProcess.write(data);
                });
            }

            socket.on('resize', (size) => {
                if (ptyProcess && !shareData.readOnly) {
                    ptyProcess.resize(size.cols, size.rows);
                }
            });

            socket.on('disconnect', () => {
                console.log('Shared terminal client disconnected');
                // Don't kill the ptyProcess, it belongs to the original socket
            });

            return; // Don't continue to normal spawn logic
        } else {
            socket.emit('error', 'Original terminal no longer exists');
            socket.disconnect();
            return;
        }
    }

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
            // Generate session ID for this terminal
            currentSessionId = crypto.randomBytes(8).toString('hex');

            ptyProcess = pty.spawn(SHELL, [], {
                name: 'xterm-color',
                cols: options.cols || 80,
                rows: options.rows || 30,
                cwd: spawnCwd,
                env: CLAUDE_ENV,
                useConpty: false  // Use WinPTY instead of ConPTY (fixes PM2 AttachConsole error)
            });

            // Store in active terminals
            activeTerminals.set(socket.id, {
                sessionId: currentSessionId,
                cwd: spawnCwd,
                ptyProcess: ptyProcess,
                createdAt: Date.now()
            });

            console.log(`Terminal spawned: ${currentSessionId} (socket: ${socket.id})`);

            ptyProcess.onData((data) => {
                socket.emit('output', data);
            });

            ptyProcess.onExit((res) => {
                socket.emit('output', `\r\n\x1b[31mShell exited with code ${res.exitCode}\x1b[0m\r\n`);
                activeTerminals.delete(socket.id);
            });

            // Send session info to client
            socket.emit('session-info', {
                sessionId: currentSessionId,
                socketId: socket.id
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
        console.log('Client disconnected');
        if (ptyProcess) {
            try {
                ptyProcess.kill();
            } catch (e) { }
        }
        activeTerminals.delete(socket.id);
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
