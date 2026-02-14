


CREATE TABLE IF NOT EXISTS customers (
	customer_id SERIAL PRIMARY KEY
	,first_name VARCHAR(100) NOT NULL
	,last_name VARCHAR(100) NOT NULL
	,email VARCHAR(255) UNIQUE NOT NULL
	,phone_number VARCHAR(20) UNIQUE NOT NULL
	,created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



CREATE TABLE IF NOT EXISTS stores (
	store_id SERIAL PRIMARY KEY
	,address VARCHAR(255) NOT NULL
	,city VARCHAR(100) NOT NULL
	,postal_code VARCHAR(10) NOT NULL
	,phone_number VARCHAR(20) UNIQUE NOT NULL
	,opened_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS ingredients (
	ingredient_id SERIAL PRIMARY KEY
	,ingredient_name VARCHAR(100) UNIQUE NOT NULL
	,unit VARCHAR(20) NOT NULL
);




CREATE TABLE IF NOT EXISTS menu_items (
	item_id SERIAL PRIMARY KEY
	,name VARCHAR(150) UNIQUE NOT NULL
	,category VARCHAR(50) NOT NULL
	,size VARCHAR(20) NOT NULL
);




CREATE TABLE IF NOT EXISTS orders (
    order_id SERIAL PRIMARY KEY
    ,customer_id INTEGER NOT NULL
    ,store_id INTEGER NOT NULL
    ,order_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    ,total_amount NUMERIC(10,2) DEFAULT 0

	,FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE SET NULL
    ,FOREIGN KEY (store_id) REFERENCES stores(store_id) ON DELETE RESTRICT
);





CREATE TABLE IF NOT EXISTS order_items (
    order_item_id SERIAL PRIMARY KEY
    ,order_id INTEGER NOT NULL
    ,item_id INTEGER NOT NULL
    ,quantity INTEGER NOT NULL CHECK (quantity > 0)
    ,unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0)

    ,FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
    ,FOREIGN KEY (item_id) REFERENCES menu_items(item_id)
);




CREATE TABLE IF NOT EXISTS store_ingredients (
    ingredient_id INTEGER NOT NULL
    ,store_id INTEGER NOT NULL
    ,stock_quantity NUMERIC(10,2) NOT NULL DEFAULT 0

    ,PRIMARY KEY (store_id, ingredient_id)
	,FOREIGN KEY (store_id) REFERENCES stores(store_id) ON DELETE CASCADE
	,FOREIGN KEY (ingredient_id) REFERENCES ingredients(ingredient_id) ON DELETE CASCADE
);




CREATE TABLE IF NOT EXISTS menu_ingredients (
    item_id INTEGER NOT NULL
    ,ingredient_id INTEGER NOT NULL
    ,quantity_required NUMERIC(10,2) NOT NULL DEFAULT 0
	
	,PRIMARY KEY (item_id, ingredient_id)
	,FOREIGN KEY (item_id) REFERENCES menu_items(item_id) ON DELETE CASCADE
	,FOREIGN KEY (ingredient_id) REFERENCES ingredients(ingredient_id) ON DELETE CASCADE
);




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


CREATE OR REPLACE TRIGGER trg_update_order_total
AFTER INSERT OR UPDATE OR DELETE
ON order_items
FOR EACH ROW
EXECUTE FUNCTION update_order_total();







-- DROP TABLE IF EXISTS  customers CASCADE;
-- DROP TABLE IF EXISTS  stores CASCADE;
-- DROP TABLE IF EXISTS  ingredients CASCADE;
-- DROP TABLE IF EXISTS  menu_items CASCADE;
-- DROP TABLE IF EXISTS  orders CASCADE;
-- DROP TABLE IF EXISTS  order_items CASCADE;
-- DROP TABLE IF EXISTS  store_ingredients CASCADE;
-- DROP TABLE IF EXISTS  menu_ingredients CASCADE;




