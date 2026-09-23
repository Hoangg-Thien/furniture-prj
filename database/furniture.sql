CREATE TABLE "users" (
  "id" BIGSERIAL PRIMARY KEY,
  "username" "VARCHAR(50)" UNIQUE NOT NULL,
  "password_hash" "VARCHAR(255)" NOT NULL,
  "role" "VARCHAR(20)" NOT NULL CHECK (role IN ('CUSTOMER', 'STAFF', 'ADMIN')) DEFAULT 'CUSTOMER',
  "is_active" BOOLEAN NOT NULL DEFAULT true,
  "created_at" TIMESTAMP NOT NULL DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "customers" (
  "id" BIGSERIAL PRIMARY KEY,
  "user_id" BIGINT UNIQUE NOT NULL,
  "full_name" "VARCHAR(150)" NOT NULL,
  "email" "VARCHAR(150)" UNIQUE,
  "phone" "VARCHAR(20)",
  "address" TEXT,
  "created_at" TIMESTAMP NOT NULL DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "staff" (
  "id" BIGSERIAL PRIMARY KEY,
  "user_id" BIGINT UNIQUE NOT NULL,
  "full_name" "VARCHAR(150)" NOT NULL,
  "email" "VARCHAR(150)" UNIQUE,
  "phone" "VARCHAR(20)",
  "address" TEXT,
  "created_at" TIMESTAMP NOT NULL DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "categories" (
  "id" BIGSERIAL PRIMARY KEY,
  "name" "VARCHAR(150)" UNIQUE NOT NULL,
  "description" TEXT
);

CREATE TABLE "products" (
  "id" BIGSERIAL PRIMARY KEY,
  "category_id" BIGINT NOT NULL,
  "name" "VARCHAR(200)" NOT NULL,
  "description" TEXT,
  "unit" "VARCHAR(50)" NOT NULL,
  "selling_price" "NUMERIC(15,2)" NOT NULL CHECK (selling_price >= 0),
  "quantity" INTEGER NOT NULL CHECK (quantity >= 0) DEFAULT 0,
  "is_active" BOOLEAN NOT NULL DEFAULT true,
  "created_at" TIMESTAMP NOT NULL DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "orders" (
  "id" BIGSERIAL PRIMARY KEY,
  "customer_id" BIGINT NOT NULL,
  "staff_id" BIGINT NOT NULL,
  "order_date" TIMESTAMP NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "status" "VARCHAR(30)" NOT NULL DEFAULT 'PENDING',
  "total_amount" "NUMERIC(15,2)" NOT NULL CHECK (total_amount >= 0) DEFAULT 0
);

CREATE TABLE "order_items" (
  "order_id" BIGINT NOT NULL,
  "product_id" BIGINT NOT NULL,
  "quantity" INTEGER NOT NULL CHECK (quantity > 0),
  "unit_price" "NUMERIC(15,2)" NOT NULL CHECK (unit_price >= 0),
  "amount" "NUMERIC(15,2)" NOT NULL CHECK (amount >= 0),
  PRIMARY KEY ("order_id", "product_id")
);

CREATE TABLE "suppliers" (
  "id" BIGSERIAL PRIMARY KEY,
  "name" "VARCHAR(200)" NOT NULL,
  "phone" "VARCHAR(20)",
  "email" "VARCHAR(150)",
  "address" TEXT
);

CREATE TABLE "purchase_receipts" (
  "id" BIGSERIAL PRIMARY KEY,
  "supplier_id" BIGINT NOT NULL,
  "staff_id" BIGINT NOT NULL,
  "received_by" BIGINT,
  "receipt_date" TIMESTAMP NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "status" "VARCHAR(30)" NOT NULL DEFAULT 'PENDING',
  "total_amount" "NUMERIC(15,2)" NOT NULL CHECK (total_amount >= 0) DEFAULT 0
);

CREATE TABLE "purchase_receipt_items" (
  "purchase_receipt_id" BIGINT NOT NULL,
  "product_id" BIGINT NOT NULL,
  "quantity" INTEGER NOT NULL CHECK (quantity > 0),
  "unit_price" "NUMERIC(15,2)" NOT NULL CHECK (unit_price >= 0),
  "amount" "NUMERIC(15,2)" NOT NULL CHECK (amount >= 0),
  PRIMARY KEY ("purchase_receipt_id", "product_id")
);

CREATE TABLE "promotion_programs" (
  "id" BIGSERIAL PRIMARY KEY,
  "name" "VARCHAR(200)" NOT NULL,
  "description" TEXT,
  "start_date" TIMESTAMP NOT NULL,
  "end_date" TIMESTAMP NOT NULL,
  "status" "VARCHAR(30)" NOT NULL DEFAULT 'DRAFT',
  CHECK (end_date >= start_date)
);

CREATE TABLE "product_discounts" (
  "id" BIGSERIAL PRIMARY KEY,
  "promotion_program_id" BIGINT NOT NULL,
  "product_id" BIGINT NOT NULL,
  "discount_percent" "NUMERIC(5,2)" NOT NULL CHECK (discount_percent > 0 AND discount_percent <= 100),
  "start_date" TIMESTAMP NOT NULL,
  "end_date" TIMESTAMP NOT NULL,
  CHECK (end_date >= start_date)
);

CREATE TABLE "order_discounts" (
  "id" BIGSERIAL PRIMARY KEY,
  "promotion_program_id" BIGINT NOT NULL,
  "minimum_amount" "NUMERIC(15,2)" NOT NULL CHECK (minimum_amount >= 0),
  "discount_percent" "NUMERIC(5,2)" NOT NULL CHECK (discount_percent > 0 AND discount_percent <= 100),
  "start_date" TIMESTAMP NOT NULL,
  "end_date" TIMESTAMP NOT NULL,
  CHECK (end_date >= start_date)
);

CREATE TABLE "vouchers" (
  "id" BIGSERIAL PRIMARY KEY,
  "promotion_program_id" BIGINT NOT NULL,
  "code" "VARCHAR(50)" UNIQUE NOT NULL,
  "discount_percent" "NUMERIC(5,2)" NOT NULL CHECK (discount_percent > 0 AND discount_percent <= 100),
  "minimum_amount" "NUMERIC(15,2)" NOT NULL CHECK (minimum_amount >= 0) DEFAULT 0,
  "maximum_discount" "NUMERIC(15,2)" CHECK (maximum_discount IS NULL OR maximum_discount >= 0),
  "quantity" INTEGER NOT NULL CHECK (quantity >= 0) DEFAULT 0,
  "used_quantity" INTEGER NOT NULL CHECK (used_quantity >= 0 AND used_quantity <= quantity) DEFAULT 0,
  "start_date" TIMESTAMP NOT NULL,
  "end_date" TIMESTAMP NOT NULL,
  "status" "VARCHAR(30)" NOT NULL DEFAULT 'ACTIVE',
  CHECK (end_date >= start_date)
);

CREATE INDEX "idx_customers_user" ON "customers" ("user_id");

CREATE INDEX "idx_staff_user" ON "staff" ("user_id");

CREATE INDEX "idx_products_category" ON "products" ("category_id");

CREATE INDEX "idx_orders_customer" ON "orders" ("customer_id");

CREATE INDEX "idx_orders_staff_id" ON "orders" ("staff_id");

CREATE INDEX "idx_order_items_product" ON "order_items" ("product_id");

CREATE INDEX "idx_purchase_receipts_supplier" ON "purchase_receipts" ("supplier_id");

CREATE INDEX "idx_purchase_receipts_staff_id" ON "purchase_receipts" ("staff_id");

CREATE INDEX "idx_purchase_receipts_received_by" ON "purchase_receipts" ("received_by");

CREATE INDEX "idx_purchase_receipt_items_product" ON "purchase_receipt_items" ("product_id");

CREATE INDEX "idx_product_discounts_product" ON "product_discounts" ("product_id");

CREATE INDEX "idx_order_discounts_program" ON "order_discounts" ("promotion_program_id");

CREATE INDEX "idx_vouchers_code" ON "vouchers" ("code");

ALTER TABLE "customers" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "staff" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "products" ADD FOREIGN KEY ("category_id") REFERENCES "categories" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "orders" ADD FOREIGN KEY ("customer_id") REFERENCES "customers" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "orders" ADD FOREIGN KEY ("staff_id") REFERENCES "staff" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "order_items" ADD FOREIGN KEY ("order_id") REFERENCES "orders" ("id") ON DELETE CASCADE DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "order_items" ADD FOREIGN KEY ("product_id") REFERENCES "products" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "purchase_receipts" ADD FOREIGN KEY ("supplier_id") REFERENCES "suppliers" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "purchase_receipts" ADD FOREIGN KEY ("staff_id") REFERENCES "staff" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "purchase_receipts" ADD FOREIGN KEY ("received_by") REFERENCES "staff" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "purchase_receipt_items" ADD FOREIGN KEY ("purchase_receipt_id") REFERENCES "purchase_receipts" ("id") ON DELETE CASCADE DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "purchase_receipt_items" ADD FOREIGN KEY ("product_id") REFERENCES "products" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "product_discounts" ADD FOREIGN KEY ("promotion_program_id") REFERENCES "promotion_programs" ("id") ON DELETE CASCADE DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "product_discounts" ADD FOREIGN KEY ("product_id") REFERENCES "products" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "order_discounts" ADD FOREIGN KEY ("promotion_program_id") REFERENCES "promotion_programs" ("id") ON DELETE CASCADE DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "vouchers" ADD FOREIGN KEY ("promotion_program_id") REFERENCES "promotion_programs" ("id") ON DELETE CASCADE DEFERRABLE INITIALLY IMMEDIATE;
