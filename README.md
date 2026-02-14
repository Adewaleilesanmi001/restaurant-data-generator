# 🍕 Restaurant Data Generator

A Python-based synthetic data generation tool for restaurant management systems. This project generates realistic test data for a multi-store restaurant chain and loads it into a PostgreSQL database, complete with customers, orders, menu items, ingredients, and inventory tracking.

![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-13+-green.svg)
![Faker](https://img.shields.io/badge/Faker-20.0+-orange.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Database Schema](#database-schema)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Data Models](#data-models)
- [Project Structure](#project-structure)
- [Logging](#logging)

---

## 🎯 Overview

This tool generates comprehensive synthetic datasets for testing and development of restaurant management applications. It creates realistic relationships between customers, stores, menu items, ingredients, and orders using the Faker library with specialized food data providers.

**Generated Data Volume:**
- 1,500 customers
- 5 store locations
- 50 ingredients
- 30 menu items
- 5,000 orders
- 20,000+ order items
- Store-ingredient inventory mappings
- Menu-ingredient recipe mappings

---

## ✨ Features

- **Realistic Data Generation**: Uses Faker with FoodProvider for authentic restaurant data
- **Relational Integrity**: Maintains proper foreign key relationships across all tables
- **Automatic Order Total Calculation**: PostgreSQL trigger updates order totals automatically
- **Duplicate Prevention**: Handles uniqueness constraints with exception handling
- **Comprehensive Logging**: Dual logging to console and file for monitoring
- **Batch Loading**: Efficient chunked data loading to PostgreSQL via SQLAlchemy
- **UK Address Format**: Store locations use British address formatting
- **Flexible Configuration**: Environment-based database configuration

---

## 🗄️ Database Schema

### Entity Relationship Diagram

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│    customers    │     │     orders      │     │   order_items   │
├─────────────────┤     ├─────────────────┤     ├─────────────────┤
│ PK customer_id  │◄────┤ PK order_id     │◄────┤ PK order_item_id│
│    first_name   │     │ FK customer_id  │     │ FK order_id     │
│    last_name    │     │ FK store_id     │     │ FK item_id      │
│    email (UQ)   │     │    order_timestamp    │    quantity     │
│    phone (UQ)   │     │    total_amount │     │    unit_price   │
│    created_at   │     └────────┬────────┘     └─────────────────┘
└─────────────────┘              │
                                 │
┌─────────────────┐              │        ┌─────────────────┐
│  store_ingreds  │              │        │   menu_items    │
├─────────────────┤              │        ├─────────────────┤
│ PK store_id     │◄─────────────┘        │ PK item_id      │◄────┐
│ PK ingredient_id│     ┌─────────────────┤    name (UQ)    │     │
│    stock_qty    │     │     stores      │    category     │     │
└────────┬────────┘     ├─────────────────┤    size         │     │
         │              │ PK store_id     │     └─────────────────┘     │
         │              │    address      │                               │
         │              │    city         │     ┌─────────────────┐     │
         │              │    postal_code  │     │ menu_ingredients│     │
         │              │    phone (UQ)   │     ├─────────────────┤     │
         │              │    opened_at    │     │ PK item_id      │─────┘
         │              └─────────────────┘     │ PK ingredient_id│
         │                                        │    qty_required │
         │              ┌─────────────────┐     └─────────────────┘
         └─────────────►│   ingredients   │
                        ├─────────────────┤
                        │ PK ingredient_id│
                        │    name (UQ)    │
                        │    unit         │
                        └─────────────────┘
```

### Tables

| Table | Description | Records |
|-------|-------------|---------|
| `customers` | Customer profiles with contact info | 1,500 |
| `stores` | Restaurant branch locations | 5 |
| `ingredients` | Raw ingredients with units | 50 |
| `menu_items` | Food and beverage items | 30 |
| `orders` | Customer order headers | 5,000 |
| `order_items` | Individual items per order | ~15,000 |
| `store_ingredients` | Inventory per store | 100 |
| `menu_ingredients` | Recipe ingredients per menu item | ~150 |

---

## 🚀 Installation

### Prerequisites

- Python 3.8 or higher
- PostgreSQL 13 or higher
- pip package manager

### Step 1: Clone the Repository

```bash
git clone https://github.com/yourusername/restaurant-data-generator.git
cd restaurant-data-generator
```

### Step 2: Create Virtual Environment

```bash
python -m venv venv

# Windows
venv\Scripts\activate

# macOS/Linux
source venv/bin/activate
```

### Step 3: Install Dependencies

```bash
pip install -r requirements.txt
```

**Required Packages:**
```
faker>=20.0.0
faker-food>=0.1.0
psycopg2-binary>=2.9.0
sqlalchemy>=2.0.0
pandas>=2.0.0
python-dotenv>=1.0.0
```

### Step 4: Set Up PostgreSQL Database

Execute the SQL schema in your PostgreSQL database:

```bash
psql -h your-host -U your-username -d your-database -f schema.sql
```

---

## ⚙️ Configuration

Create a `.env` file in the project root:

```env
# Database Configuration
hostname=your-azure-postgres-server.postgres.database.azure.com
database=restaurant_db
username=your_username
password=your_password
port=5432
```

> **Note:** This project is configured for Azure PostgreSQL but works with any PostgreSQL instance.

---

## 🎮 Usage

### Generate and Load All Data

```bash
python data_generator.py
```

This will:
1. Connect to the configured PostgreSQL database
2. Generate synthetic data for all tables
3. Load data in the correct order to maintain referential integrity
4. Log progress to console and `app.log`

### Expected Output

```
2024-01-15 10:30:45,123 | INFO | __main__ | customers loaded to database
2024-01-15 10:30:46,456 | INFO | __main__ | stores loaded to database
2024-01-15 10:30:47,789 | INFO | __main__ | ingredients loaded to database
2024-01-15 10:30:48,012 | INFO | __main__ | menu_items loaded to database
2024-01-15 10:30:49,345 | INFO | __main__ | store_ingredent loaded to database
2024-01-15 10:30:50,678 | INFO | __main__ | menu_ingredients loaded to database
2024-01-15 10:30:55,901 | INFO | __main__ | orders loaded to database
2024-01-15 10:31:02,234 | INFO | __main__ | order_items loaded to database
```

---

## 📊 Data Models

### Customers
```python
{
    'first_name': 'John',
    'last_name': 'Smith',
    'email': 'john.smith@email.com',
    'phone_number': '07700900001',
    'created_at': datetime(2024, 3, 15, 14, 30)
}
```

### Stores (UK Format)
```python
{
    'address': '123 High Street, London',
    'city': 'London',
    'postal_code': 'SW1A1AA',
    'phone_number': '02079460001',
    'opened_at': datetime(2024, 1, 10, 9, 0)
}
```

### Menu Items
```python
{
    'name': 'Margherita Pizza',
    'category': 'Pizza',  # One of 10 categories
    'size': 'Large'       # Small, Medium, Large, 500ml, N/A
}
```

### Categories
- Pizza
- Main Course
- Sides
- Fast Food
- Snacks & Appetizers
- Desserts
- Beverages
- Breakfast
- Healthy Options
- Combo Meals

---

## 📁 Project Structure

```
restaurant-data-generator/
│
├── data_generator.py      # Main data generation script
├── logger_setup.py        # Logging configuration
├── schema.sql            # Database schema with triggers
├── requirements.txt      # Python dependencies
├── .env                  # Environment variables (not in git)
├── .env.example          # Example environment file
├── app.log               # Generated log file
└── README.md             # This file
```

### File Descriptions

| File | Purpose |
|------|---------|
| `data_generator.py` | Core script with data generation functions for each table |
| `logger_setup.py` | Configures dual logging (console + file) with timestamps |
| `schema.sql` | Complete PostgreSQL schema including tables, constraints, and triggers |
| `requirements.txt` | Python package dependencies |

---

## 📝 Logging

The project uses a custom logger that writes to both console and file:

**Log Format:**
```
YYYY-MM-DD HH:MM:SS,mmm | LEVEL | module_name | message
```

**Log Levels:**
- `INFO`: Successful operations (data loaded, records inserted)
- `WARNING`: Non-critical issues (uniqueness exceptions, value errors)

**Log Files:**
- Console output for real-time monitoring
- `app.log` for persistent records

---

## 🔧 Database Triggers

### Automatic Order Total Calculation

The database includes a trigger that automatically recalculates order totals when order items are inserted, updated, or deleted:

```sql
CREATE OR REPLACE FUNCTION update_order_total()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE orders
    SET total_amount = (
        SELECT COALESCE(SUM(quantity * unit_price), 0)
        FROM order_items
        WHERE order_id = COALESCE(NEW.order_id, OLD.order_id)
    )
    WHERE order_id = COALESCE(NEW.order_id, OLD.order_id);
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;
```

---

## 🛡️ Error Handling

The generator handles common data generation issues:

- **UniquenessException**: When unique constraints (email, phone) would be violated
- **ValueError**: When random sampling operations fail
- All errors are logged without stopping the generation process

---

## 🔗 Sample Queries

After data generation, try these queries:

```sql
-- Top 5 customers by order value
SELECT c.first_name, c.last_name, SUM(o.total_amount) as total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC
LIMIT 5;

-- Store sales summary
SELECT s.city, COUNT(o.order_id) as order_count, SUM(o.total_amount) as revenue
FROM stores s
JOIN orders o ON s.store_id = o.store_id
GROUP BY s.store_id, s.city;

-- Most popular menu items
SELECT mi.name, mi.category, COUNT(oi.order_item_id) as times_ordered
FROM menu_items mi
JOIN order_items oi ON mi.item_id = oi.item_id
GROUP BY mi.item_id, mi.name, mi.category
ORDER BY times_ordered DESC
LIMIT 10;
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📧 Contact

For questions or support, please open an issue on GitHub.

---

<p align="center">Built with ❤️ for data engineers and developers</p>
