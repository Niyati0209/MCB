CREATE OR REPLACE PACKAGE XX_DATA_MIGRAION_PKG AUTHID CURRENT_USER
IS

PROCEDURE correct_data;
PROCEDURE add_invoice_holds;
PROCEDURE add_suppliers;
PROCEDURE add_supplier_contact;
PROCEDURE add_supp_address;
PROCEDURE add_po_headers;
PROCEDURE add_po_lines;
PROCEDURE add_invoice_headers;
PROCEDURE add_invoice_lines;

END XX_DATA_MIGRAION_PKG;