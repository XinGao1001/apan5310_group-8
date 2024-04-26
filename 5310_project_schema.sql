-- Address Info Table
CREATE TABLE address_info (
    address_id SERIAL PRIMARY KEY,
    address_street VARCHAR(255),
    address_city VARCHAR(255),
    address_state VARCHAR(255),
    address_country VARCHAR(255),
    postal_code VARCHAR(20),
    region_name VARCHAR(255)
);

-- Store Info Table
CREATE TABLE store_info (
    store_id SERIAL PRIMARY KEY,
    address_id INT REFERENCES address_info(address_id),
    phone_number VARCHAR(20),
    unique(address_id)
);

-- Employee Contact Table
CREATE TABLE employee_contact (
	employee_id SERIAL NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    department_name VARCHAR(255) NOT NULL,
    position_title VARCHAR(255) NOT NULL,
   	hire_date DATE NOT NULL,
    store_id INT REFERENCES store_info(store_id) NOT NULL,
    address_id INT REFERENCES address_info(address_id) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    gender VARCHAR(50),
    education_level VARCHAR(255) NOT NULL,
    marital_status VARCHAR(50),
    birth_date DATE NOT NULL,
    primary key(employee_id)
);

-- Staffing Shift Table
CREATE TABLE staffing_shift (
    employee_id INT REFERENCES employee_contact(employee_id) NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    PRIMARY KEY (employee_id, start_time),
    Constraint shift_timestamp
    CHECK (date(end_time) = date(start_time) and end_time >= start_time)
);

-- Salary Info Table
CREATE TABLE salary_info (
	employee_id INT REFERENCES employee_contact(employee_id),
	department_name VARCHAR(255),
	hourly_wage DECIMAL NOT NULL,
	pay_date DATE,
	primary key(employee_id, pay_date),
	Constraint minimum_wage
	CHECK (hourly_wage > 0)
);

-- Customer Info Table
CREATE TABLE customer_info (
    customer_id SERIAL PRIMARY KEY NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    address_id INT REFERENCES address_info(address_id) NOT NULL,
    birth_date DATE NOT NULL,
    gender VARCHAR(50),
    date_id_opened DATE NOT NULL,
    occupation VARCHAR(255),
    account_balance DECIMAL NOT NULL,
    unique(address_id)
);

-- Vendor Contact Table
CREATE TABLE vendor_contact (
    vendor_id SERIAL PRIMARY KEY,
    vendor_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(255) NOT NULL
);

-- Product lookup Table
CREATE TABLE product_lookup (
    product_id int,
    category VARCHAR(255) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    unit VARCHAR(50) NOT NULL,
    unit_price DECIMAL NOT NULL,
    expire_date DATE NOT NULL,
	primary key(product_id),
    Constraint product_price
    CHECK (unit_price > 0)
);

-- Vendor Order Table
CREATE TABLE vendor_order (
    order_id SERIAL PRIMARY KEY,
    vendor_id INT REFERENCES vendor_contact(vendor_id) NOT NULL,
    product_id INT REFERENCES product_lookup(product_id) NOT NULL,
    vendor_date DATE NOT NULL,
    vendor_quantity INT NOT NULL,
    vendor_price DECIMAL NOT NULL,
    CONSTRAINT vendor_quantity_check CHECK (vendor_quantity > 0),
    CONSTRAINT vendor_price_check CHECK (vendor_price > 0)
);

-- store_management
CREATE TABLE store_inventory(
	store_id int references store_info(store_id),
	product_id int references product_lookup(product_id),
	store_quantity int not null,
	primary key(store_id, product_id),
	constraint store_quantity
	check(store_quantity >= 0)
);

-- import info Table
CREATE TABLE import_info (
    vendor_id INT references vendor_contact(vendor_id),
	product_id int references product_lookup(product_id), 
    store_id int references store_info(store_id),
    import_date DATE,
    import_quantity INT NOT NULL,
    PRIMARY KEY (vendor_id, import_date, product_id, store_id),
    Constraint import_quantity
    CHECK (import_quantity > 0)
);

-- discount info Table
CREATE TABLE discount_info (
    product_id INT references product_lookup(product_id),
    store_id INT references store_info(store_id),
    discount_rate DECIMAL NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    PRIMARY KEY (product_id, store_id),
    Constraint discount_rate
    CHECK (discount_rate > 0 and discount_rate < 1),
    Constraint discount_date
    CHECK (end_date > start_date)
);

-- other expense Table
CREATE TABLE other_expense (
    date DATE NOT NULL,
    store_id INT REFERENCES store_info(store_id) NOT NULL,
    rent DECIMAL NOT NULL,
    PRIMARY KEY (date, store_id),
    Constraint rent
    CHECK (rent > 0)
);

-- sale Table
CREATE TABLE sale (
    transaction_id SERIAL NOT NULL,
    store_id INT references store_info(store_id),
    customer_id INT REFERENCES customer_info(customer_id) NOT NULL,
    employee_id INT REFERENCES employee_contact(employee_id),
    date DATE NOT NULL,
	primary key(transaction_id)

);

-- receipt Table
CREATE TABLE receipt (
    transaction_id int references sale(transaction_id),
    store_id INT references store_info(store_id),
    product_id INT references product_lookup(product_id),
    quantity int NOT NULL,
    date DATE NOT NULL,
    primary key(transaction_id, store_id, product_id),
    Constraint quantity
    CHECK (quantity > 0)
);


































