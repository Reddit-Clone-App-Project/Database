CREATE TABLE app_user(
    id SERIAL PRIMARY KEY,
    email TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    full_name TEXT NOT NULL,
    profile_img TEXT,
    date_of_birth DATE NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('buyer', 'seller')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT true,
    last_login TIMESTAMP DEFAULT NULL,
    phone_number TEXT UNIQUE,
    nationality TEXT CHECK (nationality IN ('AF', 'AL', 'DZ', 'AR', 'AU', 'AT', 'BD', 'BE', 'BR', 'CA', 'CL', 'CN', 'CO', 'CZ', 'DK', 'EG', 'FI', 'FR', 'DE', 'GR', 'HK', 'HU', 'IN', 'ID', 'IE', 'IL', 'IT', 'JP', 'KR', 'MY', 'MX', 'NL', 'NZ', 'NG', 'NO', 'PK', 'PH', 'PL', 'PT', 'RU', 'SA', 'SG', 'ZA', 'ES', 'SE', 'CH', 'TH', 'TR', 'UA', 'AE', 'GB', 'US', 'VN'))
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
    discount_type TEXT NOT NULL CHECK (discount_type IN('percentage', 'fixed', 'shipping', 'category', 'other')),
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
        'recommended',
        'custom'
        )
    ),
    position INTEGER NOT NULL UNIQUE,
    is_active BOOLEAN NOT NULL DEFAULT true
);

CREATE TABLE shipping_method(
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
    app_user_id INTEGER REFERENCES app_user(id) ON DELETE CASCADE,
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
    color TEXT NOT NULL DEFAULT 'default',
    variant TEXT NOT NULL DEFAULT 'default',
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0),
    weight INTEGER CHECK (weight >= 0),
    dimension INTEGER CHECK (dimension >= 0),
    is_available BOOLEAN NOT NULL DEFAULT true,
    sku TEXT NOT NULL UNIQUE,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT true,
    UNIQUE (product_id, color, variant)
);

CREATE TABLE order_table(
    id SERIAL PRIMARY KEY,
    app_user_id INTEGER NOT NULL REFERENCES app_user(id),
    address_id INTEGER NOT NULL REFERENCES address(id),
    status TEXT NOT NULL CHECK (status IN ('pending', 'paid', 'shipped', 'delivered', 'cancelled', 'returned', 'failed')),
    payment_id INTEGER NOT NULL REFERENCES payment(id),
    shipping_method_id INTEGER NOT NULL REFERENCES shipping_method(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_item(
    order_table_id INTEGER REFERENCES order_table(id) ON DELETE CASCADE,
    product_variant_id INTEGER REFERENCES product_variant(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
    price_at_purchase DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (order_table_id, product_variant_id)
);

CREATE TABLE cart(
    id SERIAL PRIMARY KEY,
    app_user_id INTEGER NOT NULL UNIQUE REFERENCES app_user(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP 
);

CREATE TABLE cart_item(
    cart_id INTEGER REFERENCES cart(id) ON DELETE CASCADE,
    product_variant_id INTEGER REFERENCES product_variant(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    price_at_purchase DECIMAL(10, 2) NOT NULL CHECK (price_at_purchase >= 0),
    PRIMARY KEY (cart_id, product_variant_id)
);

CREATE TABLE wishlist(
    id SERIAL PRIMARY KEY,
    app_user_id INTEGER NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    name TEXT NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE wishlist_item(
    wishlist_id INTEGER REFERENCES wishlist(id) ON DELETE CASCADE,
    product_variant_id INTEGER REFERENCES product_variant(id) ON DELETE CASCADE,
    added_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (wishlist_id, product_variant_id)
);

CREATE TABLE homepage_section_item(
    id SERIAL PRIMARY KEY,
    section_id INTEGER NOT NULL REFERENCES homepage_section(id) ON DELETE CASCADE,
    product_variant_id INTEGER REFERENCES product_variant(id),
    category_id INTEGER REFERENCES category(id),
    image_url TEXT,
    link TEXT,
    title TEXT,
    subtitle TEXT,
    position INTEGER NOT NULL CHECK (position >= 0),
    CHECK (
        (product_variant_id IS NOT NULL AND category_id IS NULL)
        OR (product_variant_id IS NULL AND category_id IS NOT NULL)
        OR (product_variant_id IS NULL AND category_id IS NULL AND image_url IS NOT NULL)
    ),
    UNIQUE (section_id, position)
);

CREATE UNIQUE INDEX unique_product_per_section ON homepage_section_item(section_id, product_variant_id) WHERE product_variant_id IS NOT NULL;
CREATE UNIQUE INDEX unique_category_per_section ON homepage_section_item(section_id, category_id) WHERE category_id IS NOT NULL;
CREATE UNIQUE INDEX unique_image_per_section ON homepage_section_item(section_id, image_url) WHERE image_url IS NOT NULL;

CREATE TABLE product_image(
    id SERIAL PRIMARY KEY,
    product_variant_id INTEGER REFERENCES product_variant(id) ON DELETE CASCADE,
    url TEXT NOT NULL,
    alt_text TEXT,
    position INTEGER NOT NULL DEFAULT 0,
    UNIQUE (product_variant_id, position),
    UNIQUE (product_variant_id, url)
);

CREATE TABLE notification(
    id SERIAL PRIMARY KEY,
    app_user_id INTEGER NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    content TEXT,
    is_read BOOLEAN NOT NULL DEFAULT false,
    type TEXT NOT NULL CHECK (type IN ('order_confirmed', 'order_shipped', 'order_delivered', 'promotion', 'system_alert')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE product_discount(
    discount_id INT REFERENCES discount(id) ON DELETE CASCADE,
    product_variant_id INT REFERENCES product_variant(id) ON DELETE CASCADE,
    PRIMARY KEY (discount_id, product_variant_id)
);

CREATE TABLE review(
    id SERIAL PRIMARY KEY,
    app_user_id INTEGER NOT NULL REFERENCES app_user(id),
    product_id INTEGER REFERENCES product(id) ON DELETE CASCADE,
    store_id INTEGER REFERENCES store(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (    
        (product_id IS NOT NULL AND store_id IS NULL) OR 
        (product_id IS NULL AND store_id IS NOT NULL)  
    )
);

CREATE UNIQUE INDEX unique_product_review_per_user ON review(app_user_id, product_id) WHERE store_id IS NULL;
CREATE UNIQUE INDEX unique_store_review_per_user ON review(app_user_id, store_id) WHERE product_id IS NULL;

CREATE TABLE report(
    id SERIAL PRIMARY KEY,
    type TEXT NOT NULL CHECK(type IN ('product_issue', 'user_behavior', 'store_issue', 'order_issue', 'review_issue', 'technical_issue', 'other')),
    target_type TEXT NOT NULL CHECK(target_type IN ('user', 'store', 'product')),
    target_id INTEGER NOT NULL,
    reported_by_type TEXT NOT NULL CHECK(reported_by_type IN ('user', 'seller')),
    reported_by_id INTEGER NOT NULL,
    priority TEXT NOT NULL CHECK(priority IN ('low', 'medium', 'high')),
    status TEXT NOT NULL CHECK(status IN ('pending', 'in_review', 'resolved', 'dismissed')),
    title TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE TICKET(
    id SERIAL PRIMARY KEY,
    type TEXT NOT NULL CHECK(type IN ('store_approval', 'product_approval', 'refund_request', 'account_verification', 'strike_appeal', 'moderation_review', 'other')),
    open_by_type TEXT NOT NULL CHECK(reported_by_type IN ('user', 'seller')),
    open_by_id INTEGER NOT NULL,
    priority TEXT NOT NULL CHECK(priority IN ('low', 'medium', 'high')),
    status TEXT NOT NULL CHECK(status IN ('pending', 'in_review', 'resolved', 'dismissed')),
    title TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP    
);

/* 
ALTER TABLE discount
ADD COLUMN status TEXT NOT NULL CHECK(status IN ('active', 'paused', 'ended', 'upcoming'));

ALTER TABLE discount
ADD COLUMN scope TEXT NOT NULL CHECK(scope IN ('forced', 'optional'));

ALTER TABLE discount
ADD COLUMN description TEXT;
*/


CREATE TABLE ADMIN(
    id SERIAL PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    full_name TEXT NOT NULL,
    employee_img TEXT,
    date_of_birth DATE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT true,
    last_login TIMESTAMP DEFAULT NULL
);

CREATE TABLE STORAGE(
    id SERIAL PRIMARY KEY,
    email TEXT NOT NULL,
    password TEXT NOT NULL,
    shipping_unit TEXT NOT NULL CHECK (shipping_unit IN ('Fast Express', 'Airline Post', 'American Post', 'Europe Express')),
    location TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT true,
    last_login TIMESTAMP DEFAULT NULL
);
    
CREATE TABLE SHIPPER(
    id SERIAL PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    full_name TEXT NOT NULL,
    employee_img TEXT,
    date_of_birth DATE NOT NULL,
    shipping_unit TEXT NOT NULL CHECK (shipping_unit IN ('Fast Express', 'Airline Post', 'American Post', 'Europe Express')),
    storage_id SERIAL REFERENCES STORAGE(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT true,
    last_login TIMESTAMP DEFAULT NULL
);
