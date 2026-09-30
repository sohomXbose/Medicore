const dotenv = require('dotenv');
// Load environment variables before any other module imports
dotenv.config();

const express = require('express');
const cors = require('cors');
const database = require('./config/db');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors()); // Allow frontend to communicate with API
app.use(express.json()); // Parse incoming JSON data

const oracledb = require('oracledb');

// Health-check endpoint that confirms DB connectivity (Blueprint Phase 2 requirement)
const healthCheckHandler = async (req, res) => {
    let connection;
    try {
        connection = await oracledb.getConnection();
        await connection.execute('SELECT 1 FROM DUAL');
        res.json({ 
            status: 'UP', 
            database: 'CONNECTED', 
            message: 'MediCore Backend API and Oracle DB are connected and running perfectly.' 
        });
    } catch (err) {
        res.status(503).json({ 
            status: 'DOWN', 
            database: 'DISCONNECTED', 
            error: err.message || 'Database ping failed' 
        });
    } finally {
        if (connection) {
            try { await connection.close(); } catch (cErr) {}
        }
    }
};

app.get('/health', healthCheckHandler);
app.get('/api/health', healthCheckHandler);

// Import and use routes
const authRoutes = require('./routes/authRoutes');
const patientRoutes = require('./routes/patientRoutes');
const appointmentRoutes = require('./routes/appointmentRoutes');
const treatmentRoutes = require('./routes/treatmentRoutes');
const prescriptionRoutes = require('./routes/prescriptionRoutes');
const billRoutes = require('./routes/billRoutes');
const reportRoutes = require('./routes/reportRoutes');

app.use('/api/auth', authRoutes);
app.use('/api/patients', patientRoutes);
app.use('/api/appointments', appointmentRoutes);
app.use('/api/treatments', treatmentRoutes);
app.use('/api/prescriptions', prescriptionRoutes);
app.use('/api/bills', billRoutes);
app.use('/api/reports', reportRoutes);

// 404 Catch-All Handler
app.use((req, res) => {
    res.status(404).json({ error: `Route not found: ${req.method} ${req.originalUrl}` });
});

// Global Error Handler
app.use((err, req, res, next) => {
    const statusCode = err.status || err.statusCode || 500;
    console.error('Unhandled Server Error:', err);
    res.status(statusCode).json({ error: err.message || 'Internal Server Error' });
});

// Start the Database Connection, then Start the Server
async function startup() {
    try {
        console.log('Starting MediCore Backend...');
        
        // 1. Initialize Oracle Connection Pool
        await database.initialize(); 
        
        // 2. Start the Express Server
        const server = app.listen(PORT, () => {
            console.log(`Backend server is listening on http://localhost:${PORT}`);
        });

        // Graceful shutdown handling
        const gracefulShutdown = async () => {
            console.log('\nClosing HTTP server and Oracle DB pool...');
            server.close(async () => {
                await database.close();
                process.exit(0);
            });
        };

        process.on('SIGINT', gracefulShutdown);
        process.on('SIGTERM', gracefulShutdown);

    } catch (err) {
        console.error('Startup Error:', err);
        process.exit(1);
    }
}

// Execute the startup function
startup();
