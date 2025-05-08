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

