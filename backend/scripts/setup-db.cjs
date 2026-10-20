const { Client } = require('pg');

async function main() {
  const client = new Client({ connectionString: 'postgresql://postgres@localhost:5432/postgres' });
  await client.connect();
  
  try {
    await client.query('CREATE DATABASE agri_insight;');
    console.log('Database agri_insight created');
  } catch (e) {
    console.log('Database agri_insight:', e.message);
  }

  try {
    await client.query("CREATE ROLE agri_user WITH LOGIN PASSWORD 'agri_password' SUPERUSER;");
    console.log('Role agri_user created');
  } catch (e) {
    console.log('Role agri_user:', e.message);
  }

  try {
    await client.query("GRANT ALL PRIVILEGES ON DATABASE agri_insight TO agri_user;");
    console.log('Privileges granted');
  } catch (e) {
    console.log('Grant:', e.message);
  }

  await client.end();
}

main().catch(console.error);
