# travel-database-project

Hotel database / travel project and website.

---

## Database Setup

**1. Install Homebrew** (skip if already installed)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**2. Install MySQL**

```bash
brew install mysql
brew services start mysql
mysql_secure_installation
```

**3. Create the database**

```bash
mysql -u root -p < hotel-reservation-system/database/schema-creator.sql
```

**4. Install Python dependency**

```bash
pip install mysql-connector-python python-dotenv
```

**5. Create a `.env` file** in the project root (./travel-database-project) on local

```bash
echo "DB_PASSWORD=yourpassword" > .env
```

yourpassword = the mysql secure connection password you setup, if any. Otherwise, you may skip this.

**6. Export tables to CSV**

```bash
python hotel-reservation-system/backend/export_db.py
```

CSVs will appear in `hotel-reservation-system/database/exports/`.
