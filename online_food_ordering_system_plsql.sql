
-- Table: customers
CREATE TABLE customers (
    customer_id NUMBER PRIMARY KEY,
    name VARCHAR2(50)
);

-- Table: menu_items
CREATE TABLE menu_items (
    item_id NUMBER PRIMARY KEY,
    item_name VARCHAR2(50),
    price NUMBER
);

-- Table: orders (with status column)
CREATE TABLE orders (
    order_id NUMBER PRIMARY KEY,
    customer_id NUMBER REFERENCES customers(customer_id),
    item_id NUMBER REFERENCES menu_items(item_id),
    quantity NUMBER,
    order_date DATE,
    status VARCHAR2(30)
);

-- Table: bills
CREATE TABLE bills (
    bill_id NUMBER PRIMARY KEY,
    order_id NUMBER REFERENCES orders(order_id),
    total_amount NUMBER,
    bill_date DATE
);

-- Procedure: place_order (includes status 'Placed')
CREATE OR REPLACE PROCEDURE place_order (
    p_order_id NUMBER,
    p_customer_id NUMBER,
    p_item_id NUMBER,
    p_quantity NUMBER
)
IS
BEGIN
    INSERT INTO orders
    VALUES (p_order_id, p_customer_id, p_item_id, p_quantity, SYSDATE, 'Placed');

    DBMS_OUTPUT.PUT_LINE('Order placed successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error placing order: ' || SQLERRM);
END;
/

-- Procedure: generate_bill using cursor
CREATE OR REPLACE PROCEDURE generate_bill (
    p_order_id NUMBER
)
IS
    CURSOR c1 IS
        SELECT o.quantity, m.price
        FROM orders o JOIN menu_items m
        ON o.item_id = m.item_id
        WHERE o.order_id = p_order_id;

    v_qty NUMBER;
    v_price NUMBER;
    v_total NUMBER := 0;
BEGIN
    OPEN c1;
    LOOP
        FETCH c1 INTO v_qty, v_price;
        EXIT WHEN c1%NOTFOUND;
        v_total := v_total + (v_qty * v_price);
    END LOOP;
    CLOSE c1;

    INSERT INTO bills
    VALUES (p_order_id, p_order_id, v_total, SYSDATE);

    DBMS_OUTPUT.PUT_LINE('Total Bill: ₹' || v_total);
END;
/

-- Procedure: update_order_status
CREATE OR REPLACE PROCEDURE update_order_status (
    p_order_id NUMBER,
    p_status VARCHAR2
)
IS
BEGIN
    UPDATE orders
    SET status = p_status
    WHERE order_id = p_order_id;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Order ID not found.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Order status updated to: ' || p_status);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

-- Trigger: trg_order_message
CREATE OR REPLACE TRIGGER trg_order_message
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('Trigger: New order received. Order ID: ' || :NEW.order_id);
END;
/

-- Sample data (optional)
INSERT INTO customers VALUES (1, 'John Doe');
INSERT INTO menu_items VALUES (101, 'Pizza', 250);
INSERT INTO menu_items VALUES (102, 'Burger', 150);
