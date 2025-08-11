const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
});

module.exports = pool;

// postgresql://rent_king_db_user:uj4js5HLenfGOWV0ogPY4L8DfVAXNcMS@dpg-d2crbb9r0fns73e7i05g-a.oregon-postgres.render.com/rent_king_db