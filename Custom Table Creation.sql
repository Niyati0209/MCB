CREATE TABLE XX_INVOICE_HOLDS(
	invoice_hold_id number generated always as identity(start with 1 INCREMENT BY 1)  PRIMARY KEY,
	invoice_hold_reason VARCHAR(200)
    );


CREATE TABLE XX_SUPPLIER_ADDRESS(
    address_id number generated always as identity(start with 1 INCREMENT BY 1)  PRIMARY KEY,
	Address_line1 VARCHAR(200),
    Address_line2 VARCHAR(200),
    Address_line3 VARCHAR(200),
    Address_line4 VARCHAR(200),
    Address_line5 VARCHAR(200)
);


CREATE TABLE XX_SUPPLIERS(
    supplier_id number generated always as identity(start with 1 INCREMENT BY 1)  PRIMARY KEY,
	supplier_name VARCHAR(200),
    supp_contact_name VARCHAR(200),
    supp_address_id NUMBER,
    --supp_contact_id NUMBER,
    supp_email VARCHAR(200)
);
ALTER table XX_SUPPLIERS add CONSTRAINT fk_address_id FOREIGN KEY(supp_address_id) REFERENCES XX_SUPPLIER_ADDRESS(address_id);


CREATE TABLE XX_SUPPLIER_CONTACTS(
    contact_id number generated always as identity(start with 1 INCREMENT BY 1)  PRIMARY KEY,
	supplier_id NUMBER,
    contact_number VARCHAR(200)
);
ALTER table XX_SUPPLIER_CONTACTS add CONSTRAINT fk_con_supplier_id FOREIGN KEY(supplier_id) REFERENCES xx_suppliers(supplier_id);


CREATE TABLE XX_PO_HEADERS(
    po_header_id number generated always as identity(start with 1 INCREMENT BY 1)  PRIMARY KEY,
    po_number VARCHAR(100),
    po_date DATE,
    po_desc VARCHAR(500),
    po_total_amount NUMBER,
    po_status VARCHAR(100),
    supplier_id NUMBER
);
ALTER table XX_PO_HEADERS add CONSTRAINT fk_supplier_id FOREIGN KEY(supplier_id) REFERENCES xx_suppliers(supplier_id);


CREATE TABLE XX_PO_LINES(
	po_reference VARCHAR(100),
	po_header_id NUMBER,
    po_line_id number generated always as identity(start with 1 INCREMENT BY 1)  PRIMARY KEY,
    po_line_num VARCHAR(100),
    po_line_desc VARCHAR(500),
    po_line_amount NUMBER,
    po_line_status VARCHAR(100)
);
ALTER table XX_PO_LINES add CONSTRAINT fk_po_header_id FOREIGN KEY (po_header_id) REFERENCES XX_PO_HEADERS(po_header_id);


CREATE TABLE XX_INVOICE_HEADERS(
    invoice_header_id number generated always as identity(start with 1 INCREMENT BY 1)  PRIMARY KEY,
    invoice_number VARCHAR(100)
);


CREATE TABLE XX_INVOICE_LINES(
	invoice_header_id NUMBER,
    invoice_line_id number generated always as identity(start with 1 INCREMENT BY 1)  PRIMARY KEY,
	invoice_number NUMBER,
	invoice_reference VARCHAR2(100),
    po_line_id NUMBER,
    invoice_date DATE,
    invoice_desc VARCHAR(500),
    invoice_amount NUMBER,
    invoice_status VARCHAR(100), 
    invoice_hold_id NUMBER
);
ALTER table XX_INVOICE_LINES add CONSTRAINT fk_invoice_header_id FOREIGN KEY (invoice_header_id) REFERENCES XX_INVOICE_HEADERS(invoice_header_id);
ALTER table XX_INVOICE_LINES add CONSTRAINT fk_po_line_id FOREIGN KEY (po_line_id) REFERENCES XX_PO_LINES(po_line_id);
ALTER table XX_INVOICE_LINES add CONSTRAINT fk_invoice_hold_id FOREIGN KEY (invoice_hold_id) REFERENCES XX_INVOICE_HOLDS(invoice_hold_id); 
