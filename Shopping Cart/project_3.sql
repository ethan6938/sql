-- =========================================================
-- SHOPPING SYSTEM - FULL POSTGRESQL SCRIPT
-- =========================================================
-- ---------- Tables ----------
-- Products Menu Table
CREATE TABLE Products (
  Id     INT PRIMARY KEY,
  Name   TEXT NOT NULL,
  Price  NUMERIC(10,2) NOT NULL CHECK (Price >= 0)
);

-- Users Table
CREATE TABLE Users (
  User_ID  INT PRIMARY KEY,
  Username TEXT NOT NULL UNIQUE
);

-- Cart (per-user cart; composite PK)
CREATE TABLE Cart (
  User_ID   INT NOT NULL REFERENCES Users(User_ID) ON DELETE CASCADE,
  ProductId INT NOT NULL REFERENCES Products(Id),
  Qty       INT NOT NULL CHECK (Qty > 0),
  PRIMARY KEY (User_ID, ProductId)
);

-- Order header
CREATE TABLE OrderHeader (
  OrderID   BIGSERIAL PRIMARY KEY,
  User_ID   INT NOT NULL REFERENCES Users(User_ID),
  OrderDate TIMESTAMP NOT NULL DEFAULT now()
);

-- Order details (snapshot PriceEach)
CREATE TABLE OrderDetails (
  OrderID   BIGINT NOT NULL REFERENCES OrderHeader(OrderID) ON DELETE CASCADE,
  ProdID    INT NOT NULL REFERENCES Products(Id),
  Qty       INT NOT NULL CHECK (Qty > 0),
  PriceEach NUMERIC(10,2) NOT NULL,
  PRIMARY KEY (OrderID, ProdID)
);

-- ---------- Seed data ----------
INSERT INTO Products (Id,Name,Price) VALUES
  (1,'Coke',10),
  (2,'Chips',5);

INSERT INTO Users (User_ID, Username) VALUES
  (1,'Arnold'),
  (2,'Sheryl');

-- Show initial state
SELECT * FROM Products ORDER BY Id;
SELECT * FROM Users ORDER BY User_ID;

-- =========================================================
-- 3) ADD AN ITEM TO THE CART (IF EXISTS pattern)
-- User 1: Add Coke (new -> qty 1)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM Cart WHERE User_ID=1 AND ProductId=1) THEN
    UPDATE Cart SET Qty = Qty + 1 WHERE User_ID=1 AND ProductId=1;
  ELSE
    INSERT INTO Cart(User_ID, ProductId, Qty) VALUES (1,1,1);
  END IF;
END$$;
SELECT * FROM Cart WHERE User_ID=1 ORDER BY ProductId;

-- User 1: Add Coke again (exists -> +1)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM Cart WHERE User_ID=1 AND ProductId=1) THEN
    UPDATE Cart SET Qty = Qty + 1 WHERE User_ID=1 AND ProductId=1;
  ELSE
    INSERT INTO Cart(User_ID, ProductId, Qty) VALUES (1,1,1);
  END IF;
END$$;
SELECT * FROM Cart WHERE User_ID=1 ORDER BY ProductId;

-- User 1: Add Chips (new -> qty 1)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM Cart WHERE User_ID=1 AND ProductId=2) THEN
    UPDATE Cart SET Qty = Qty + 1 WHERE User_ID=1 AND ProductId=2;
  ELSE
    INSERT INTO Cart(User_ID, ProductId, Qty) VALUES (1,2,1);
  END IF;
END$$;
SELECT * FROM Cart WHERE User_ID=1 ORDER BY ProductId;
SELECT * FROM Products ORDER BY Id;
-- =========================================================
-- 4) REMOVE AN ITEM FROM THE CART
-- Rule: if qty > 1 then -1; if qty = 1 then delete row
DO $$
DECLARE v_qty INT;
BEGIN
  SELECT Qty INTO v_qty FROM Cart WHERE User_ID=1 AND ProductId=1;
  IF v_qty IS NULL THEN
    RAISE NOTICE 'Nothing to remove for user=1 product=1';
  ELSIF v_qty > 1 THEN
    UPDATE Cart SET Qty = Qty - 1 WHERE User_ID=1 AND ProductId=1;
  ELSE
    DELETE FROM Cart WHERE User_ID=1 AND ProductId=1;
  END IF;
END$$;
SELECT * FROM Cart WHERE User_ID=1 ORDER BY ProductId;

-- =========================================================
-- 5) CHECKOUT: create OrderHeader; copy Cart -> OrderDetails; clear Cart
DO $$
DECLARE new_order_id BIGINT;
BEGIN
  -- A: insert order header (User 1, now)
  INSERT INTO OrderHeader(User_ID, OrderDate) VALUES (1, now())
  RETURNING OrderID INTO new_order_id;

  -- B: copy cart lines with price snapshot
  INSERT INTO OrderDetails (OrderID, ProdID, Qty, PriceEach)
  SELECT new_order_id, c.ProductId, c.Qty, p.Price
  FROM Cart c
  JOIN Products p ON p.Id = c.ProductId
  WHERE c.User_ID = 1;

  -- Clear cart
  DELETE FROM Cart WHERE User_ID = 1;

  RAISE NOTICE 'Checked out order % for user %', new_order_id, 1;
END$$;

-- Show the order we just created
SELECT * FROM OrderHeader WHERE User_ID=1 ORDER BY OrderID DESC LIMIT 1;
SELECT * FROM OrderDetails WHERE OrderID = (SELECT MAX(OrderID) FROM OrderHeader WHERE User_ID=1) ORDER BY ProdID;
SELECT * FROM Cart WHERE User_ID=1;  -- should be empty

-- =========================================================
-- DEMO: Multiple orders + deletes in between
-- Refill cart for User 1: Coke x2 and Chips x1 using upserts
INSERT INTO Cart(User_ID, ProductId, Qty) VALUES (1,1,1)
ON CONFLICT (User_ID, ProductId) DO UPDATE SET Qty = Cart.Qty + 1;

INSERT INTO Cart(User_ID, ProductId, Qty) VALUES (1,1,1)
ON CONFLICT (User_ID, ProductId) DO UPDATE SET Qty = Cart.Qty + 1;

INSERT INTO Cart(User_ID, ProductId, Qty) VALUES (1,2,1)
ON CONFLICT (User_ID, ProductId) DO UPDATE SET Qty = Cart.Qty + 1;

SELECT * FROM Cart WHERE User_ID=1 ORDER BY ProductId;

-- Delete Chips explicitly (hard-coded ProductId=2)
DELETE FROM Cart WHERE User_ID=1 AND ProductId=2;
SELECT * FROM Cart WHERE User_ID=1 ORDER BY ProductId;


-- =========================================================
-- PRINTING ORDERS (joins)
-- Single order example: earliest order
SELECT oh.OrderID, oh.OrderDate, u.Username,
       od.ProdID, p.Name, od.Qty, od.PriceEach, od.Qty*od.PriceEach AS LineTotal
FROM OrderHeader oh
JOIN Users u ON u.User_ID = oh.User_ID
JOIN OrderDetails od ON od.OrderID = oh.OrderID
JOIN Products p ON p.Id = od.ProdID
WHERE oh.OrderID = (SELECT MIN(OrderID) FROM OrderHeader)
ORDER BY od.ProdID;

-- All orders for today (change date as needed)
SELECT oh.OrderID,
       oh.OrderDate::date AS OrderDay,
       u.Username,
       SUM(od.Qty*od.PriceEach) AS OrderTotal
FROM OrderHeader oh
JOIN Users u ON u.User_ID = oh.User_ID
JOIN OrderDetails od ON od.OrderID = oh.OrderID
GROUP BY oh.OrderID, OrderDay, u.Username
HAVING oh.OrderDate::date = CURRENT_DATE
ORDER BY oh.OrderID;

-- =========================================================
-- BONUS: Functions for add/remove and checkout
CREATE OR REPLACE FUNCTION fn_add_to_cart(p_user INT, p_prod INT, p_qty INT DEFAULT 1)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM Cart WHERE User_ID=p_user AND ProductId=p_prod) THEN
    UPDATE Cart SET Qty = Qty + p_qty WHERE User_ID=p_user AND ProductId=p_prod;
  ELSE
    INSERT INTO Cart(User_ID, ProductId, Qty) VALUES (p_user, p_prod, p_qty);
  END IF;
END$$;

CREATE OR REPLACE FUNCTION fn_remove_from_cart(p_user INT, p_prod INT, p_qty INT DEFAULT 1)
RETURNS VOID LANGUAGE plpgsql AS $$
DECLARE v_qty INT;
BEGIN
  SELECT Qty INTO v_qty FROM Cart WHERE User_ID=p_user AND ProductId=p_prod;
  IF v_qty IS NULL THEN
    RETURN;
  ELSIF v_qty > p_qty THEN
    UPDATE Cart SET Qty = Qty - p_qty WHERE User_ID=p_user AND ProductId=p_prod;
  ELSE
    DELETE FROM Cart WHERE User_ID=p_user AND ProductId=p_prod;
  END IF;
END$$;

CREATE OR REPLACE FUNCTION fn_checkout(p_user INT)
RETURNS BIGINT LANGUAGE plpgsql AS $$
DECLARE new_order_id BIGINT;
BEGIN
  INSERT INTO OrderHeader(User_ID, OrderDate) VALUES (p_user, now())
  RETURNING OrderID INTO new_order_id;

  INSERT INTO OrderDetails (OrderID, ProdID, Qty, PriceEach)
  SELECT new_order_id, c.ProductId, c.Qty, p.Price
  FROM Cart c
  JOIN Products p ON p.Id = c.ProductId
  WHERE c.User_ID = p_user;

  DELETE FROM Cart WHERE User_ID = p_user;

  RETURN new_order_id;
END$$;

-- Quick examples using functions (optional):
-- SELECT fn_add_to_cart(1,1,1); SELECT * FROM Cart WHERE User_ID=1;
-- SELECT fn_remove_from_cart(1,1,1); SELECT * FROM Cart WHERE User_ID=1;
-- SELECT fn_checkout(1) AS new_order_id;

