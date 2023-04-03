exec XX_DATA_MIGRAION_PKG.add_invoice_holds;
exec XX_DATA_MIGRAION_PKG.add_supp_address;
exec XX_DATA_MIGRAION_PKG.add_suppliers;
exec XX_DATA_MIGRAION_PKG.add_supplier_contact;
exec XX_DATA_MIGRAION_PKG.add_po_headers;
exec XX_DATA_MIGRAION_PKG.add_po_lines;
exec XX_DATA_MIGRAION_PKG.add_invoice_headers;
exec XX_DATA_MIGRAION_PKG.add_invoice_lines;

select * from XX_INVOICE_HOLDS;
select * from XX_SUPPLIER_ADDRESS;
select * from XX_SUPPLIERS;
select * from XX_SUPPLIER_CONTACTS;
select * from xx_po_headers;
select * from xx_po_lines;
select * from XX_INVOICE_HEADERS;
select * from XX_INVOICE_LINES;