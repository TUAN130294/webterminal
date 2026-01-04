module.exports = {
    apps: [{
        name: 'web-terminal',
        script: 'server.js',
        instances: 1,
        exec_mode: 'fork', // Force fork mode, not cluster
        autorestart: true,
        watch: false,
        max_memory_restart: '1G',
        restart_delay: 5000, // Wait 5 seconds before restart
        max_restarts: 10, // Limit restarts to prevent infinite loop
        min_uptime: '10s', // Must run for 10s to be considered stable
        env: {
            NODE_ENV: 'production',
            PORT: 9000
        },
        error_file: 'logs/error.log',
        out_file: 'logs/out.log',
        log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
        merge_logs: true,
        kill_timeout: 5000 // Give 5 seconds to gracefully shutdown
    }]
};
