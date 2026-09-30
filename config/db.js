const oracledb = require('oracledb');
require('dotenv').config();

// Default all query results to JSON objects with column names as keys
oracledb.outFormat = oracledb.OUT_FORMAT_OBJECT;
async function initialize() {
    try {
        await oracledb.createPool({
            user: process.env.DB_USER,
            password: process.env.DB_PASSWORD,
            connectString: process.env.DB_CONNECTION_STRING,
            poolMin: 2,
            poolMax: 10,       // Handles up to 10 simultaneous requests nicely
            poolIncrement: 2
        });
        console.log('Oracle Database Connection Pool Started Successfully.');
    } catch (err) {
        console.error('Error initializing connection pool:', err.message);
        process.exit(1);
    }
}

async function close() {
    try {
        await oracledb.getPool().close(10);
        console.log('Oracle Database Connection Pool Closed.');
    } catch (err) {
        console.error('Error closing connection pool:', err.message);
    }
}

module.exports = {
    initialize,
    close
};
