CREATE TABLE app_user(
    id SERIAL PRIMARY KEY,
    email TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    full_name TEXT NOT NULL,
    profile_img TEXT,
    date_of_birth DATE NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('buyer', 'seller', 'admin')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT true,
    last_login TIMESTAMP DEFAULT NULL
);

CREATE TABLE product(
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    image_id INTEGER REFERENCES product_image(id) ON DELETE SET NULL,
    description TEXT,
    store_id INTEGER NOT NULL REFERENCES store(id) ON DELETE CASCADE,
    category_id INTEGER REFERENCES category(id) ON DELETE SET NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_published BOOLEAN NOT NULL DEFAULT false,
    is_active BOOLEAN NOT NULL DEFAULT true
);

CREATE TABLE store(
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    address_id INTEGER NOT NULL REFERENCES address(id) ON DELETE SET NULL,
    profile_img TEXT,
    phone_number TEXT NOT NULL,
    email TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT true
);

CREATE TABLE store_user(
    store_id INTEGER NOT NULL REFERENCES store(id) ON DELETE CASCADE,
    app_user_id INTEGER NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('owner', 'manager', 'editor')),
    PRIMARY KEY (store_id, app_user_id)
);

CREATE TABLE category(
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    slug TEXT UNIQUE,
    parent_id INTEGER REFERENCES category(id) ON DELETE SET NULL,
    description TEXT,
    image_url TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT true
);

CREATE TABLE discount(
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    discount_type TEXT NOT NULL CHECK (discount_type IN('percentage', 'fixed')),
    discount_value DECIMAL(10, 2) NOT NULL,
    start_at TIMESTAMP NOT NULL,
    end_at TIMESTAMP NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true
);

CREATE TABLE homepage_section(
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN(
        'banner',
        'featured_products',
        'best_sellers',
        'new_arrivals',
        'on_sale',
        'categories',
        'brands',
        'wishlist_picks',
        'reccomended',
        'custom'
        )
    ),
    position INTEGER NOT NULL UNIQUE,
    is_active BOOLEAN NOT NULL DEFAULT true
);

CREATE TABLE shipping_metod(
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    price DECIMAL(6, 2) NOT NULL,
    shipping_days INTEGER NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true   
);

CREATE TABLE saved_payment(
    id SERIAL PRIMARY KEY,
    app_user_id INTEGER NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    card_brand TEXT,
    last_4_digit INTEGER,
    exp_month INTEGER,
    exp_year INTEGER,
    token TEXT NOT NULL UNIQUE,
    is_default BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE payment(
    id SERIAL PRIMARY KEY,
    app_user_id INTEGER NOT NULL REFERENCES app_user(id),
    order_id INTEGER NOT NULL REFERENCES order_table(id),
    saved_payment_id INTEGER REFERENCES saved_payment(id),
    total DECIMAL(10, 2) NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'cancelled', 'refunded')),
    provider TEXT NOT NULL,
    transaction_id TEXT NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (id, app_user_id, order_id)
);

CREATE TABLE address(
    id SERIAL PRIMARY KEY,
    app_user_id INTEGER NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    address_line1 TEXT NOT NULL,
    address_line2 TEXT NOT NULL,
    city TEXT NOT NULL,
    province TEXT,
    postal_code TEXT NOT NULL,
    country TEXT NOT NULL,
    phone_number TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_default BOOLEAN NOT NULL DEFAULT false
);

CREATE TABLE product_variant(
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES product(id) ON DELETE CASCADE,
    color TEXT NOT NULL DEFAULT 'defualt',
    variant TEXT NOT NULL DEFAULT 'defualt',
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0),
    weight INTEGER CHECK (weight >= 0),
    dimension INTEGER CHECK (dimension >= 0),
    is_available BOOLEAN NOT NULL,
    sku TEXT NOT NULL UNIQUE,
    updated_at TIMESTAMP NOT NULL DEFAULT true,
    is_active BOOLEAN NOT NULL DEFAULT true,
    UNIQUE (product_id, color, variant)
);

CREATE TABLE order_table(
    id SERIAL PRIMARY KEY,
    app_user_id INTEGER NOT NULL REFERENCES app_user(id),
    address_id INTEGER NOT NULL REFERENCES address(id),
    status TEXT NOT NULL CHECK (status IN ('pending', 'paid', 'shipped', 'delivered', 'cancelled')),
    payment_id INTEGER NOT NULL REFERENCES payment(id),
    shipping_metod_id INTEGER NOT NULL REFERENCES shipping_metod(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_item(
    order_table_id INTEGER NOT NULL REFERENCES order_table(id) ON DELETE CASCADE,
    variant_id INTEGER REFERENCES product_variant(id),
    product_id INTEGER REFERENCES product(id),
    quantity INTEGER NOT NULL DEFAULT 1,
    price_at_purchase DECIMAL(10, 2) NOT NULL,
    CHECK (
        (product_id IS NOT NULL AND variant_id IS NULL) OR
        (product_id IS NULL AND variant_id IS NOT NULL)
    )
);

CREATE UNIQUE INDEX unique_product_order ON order_item(order_table_id, product_id) WHERE variant_id IS NULL;
CREATE UNIQUE INDEX unique_variant_order ON order_item(order_table_id, variant_id) WHERE product_id IS NULL;
