CREATE OR REPLACE PACKAGE BODY XX_DATA_MIGRAION_PKG
IS
	--Global Valiables
	gd_sysdate      DATE   := SYSDATE;
	--Global Valiables
	
	PROCEDURE correct_data
	IS
	begin
		null;
	end correct_data;
	
	PROCEDURE add_invoice_holds
	IS
	begin
		for inv_hold in (SELECT distinct INVOICE_HOLD_REASON from XXBCM_ORDER_MGT where INVOICE_HOLD_REASON is not null)
		LOOP
			INSERT into XX_INVOICE_HOLDS (invoice_hold_reason) 
			VALUES (inv_hold.invoice_hold_reason);
		END LOOP;
		COMMIT;
	end add_invoice_holds;
	
	PROCEDURE add_supp_address
	IS
	begin
		for supp_add in (select distinct
		regexp_substr(adds,'[^,]+',1,1) as add1,
		regexp_substr(adds,'[^,]+',1,2) as add2,
		regexp_substr(adds,'[^,]+',1,3) as add3,
		regexp_substr(adds,'[^,]+',1,4) as add4,
		regexp_substr(adds,'[^,]+',1,5) as add5
		from
		(
		select regexp_substr(SUPP_ADDRESS,'[^,]+,[^,]+,[^,]+,[^,]+,[^,]+',1, level) adds from XXBCM_ORDER_MGT
		connect by regexp_substr(SUPP_ADDRESS,'[^,]+,[^,]+,[^,]+,[^,]+,[^,]+',1, level) is not null
		))
		LOOP
			INSERT into XX_SUPPLIER_ADDRESS (Address_line1,Address_line2,Address_line3,Address_line4,Address_line5) 
			VALUES (supp_add.add1,supp_add.add2,supp_add.add3,supp_add.add4,supp_add.add5);
		END LOOP;
		COMMIT;
	end add_supp_address;
	
	PROCEDURE add_suppliers
	IS
	begin
		for supp in (select distinct 
		SUPPLIER_NAME,
		SUPP_CONTACT_NAME,
		SUPP_EMAIL,
		(select address_id from XX_SUPPLIER_ADDRESS a
		where replace(x.SUPP_ADDRESS,', ',' ') = a.ADDRESS_LINE1||a.ADDRESS_LINE2||a.ADDRESS_LINE3||a.ADDRESS_LINE4||a.ADDRESS_LINE5) address_id
		from XXBCM_ORDER_MGT x)
		LOOP
			INSERT into XX_SUPPLIERS (supplier_name,supp_contact_name,supp_email,supp_address_id) 
			VALUES (supp.SUPPLIER_NAME,supp.SUPP_CONTACT_NAME,supp.SUPP_EMAIL,supp.address_id);
		END LOOP;
		COMMIT;
	end add_suppliers;
	
	PROCEDURE add_supplier_contact
	IS
	begin
		for supp_con in (select distinct 
		replace(replace(replace(replace(trim(regexp_substr(SUPP_CONTACT_NUMBER,'[^,]+',1,level)),'S','5'),'o','0'),'I','1'),'.','') CONTACT_NUMBER
		,(select supplier_id from XX_SUPPLIERS 
		where SUPPLIER_NAME = x.SUPPLIER_NAME
		and supp_contact_name =x.SUPP_CONTACT_NAME) supplier_id
		from XXBCM_ORDER_MGT x
		connect by regexp_substr(SUPP_CONTACT_NUMBER,'[^,]+',1,level) is not null)
		LOOP
			INSERT into XX_SUPPLIER_CONTACTS (supplier_id,contact_number) 
			VALUES (supp_con.supplier_id,supp_con.CONTACT_NUMBER);
		END LOOP;
		COMMIT;
	end add_supplier_contact;
	
	PROCEDURE add_po_headers
	IS
	begin
		for poh in (select distinct 
		ORDER_REF
		--,ORDER_DATE
		,to_date(ORDER_DATE,'DD-MM-YYYY') ORDER_DATE
		,ORDER_DESCRIPTION
		,to_number(replace(ORDER_TOTAL_AMOUNT,',','')) ORDER_TOTAL_AMOUNT
		,ORDER_STATUS
		,(select supplier_id from XX_SUPPLIERS s
		where s.supplier_name = x.SUPPLIER_NAME) supplier_id 
		from XXBCM_ORDER_MGT x
		where ORDER_REF  not like '%-%'
		order by ORDER_REF)
		LOOP
			INSERT into XX_PO_HEADERS (po_number,po_date,po_desc,po_total_amount,po_status,supplier_id) 
			VALUES (poh.ORDER_REF,poh.ORDER_DATE,poh.ORDER_DESCRIPTION,poh.ORDER_TOTAL_AMOUNT,poh.ORDER_STATUS,poh.supplier_id);
		END LOOP;
		COMMIT;
	end add_po_headers;
	
	PROCEDURE add_po_lines
	IS
	begin
		for pol in (select distinct 
		ORDER_REF
		,(select po_header_id from XX_PO_HEADERS
		where po_number = substr(x.ORDER_REF,1,instr(x.ORDER_REF,'-',1)-1)) po_headet_id
		,row_number() over (partition by substr(ORDER_REF,1,instr(ORDER_REF,'-',1)-1) order by order_ref) ln_num
		,ORDER_DESCRIPTION
		--,to_number(replace(ORDER_LINE_AMOUNT,',','')) ORDER_LINE_AMOUNT
		,replace(replace(replace(replace(ORDER_LINE_AMOUNT,',',''),'I','1'),'S','5'),'o','0') ORDER_LINE_AMOUNT
		,ORDER_STATUS
		from XXBCM_ORDER_MGT x
		where ORDER_REF like '%-%'
		order by ORDER_REF)
		LOOP
			INSERT into XX_PO_LINES (po_reference,po_header_id,po_line_num,po_line_desc,po_line_amount,po_line_status) 
			VALUES (pol.ORDER_REF,pol.po_headet_id,pol.ln_num,pol.ORDER_DESCRIPTION,pol.ORDER_LINE_AMOUNT,pol.ORDER_STATUS);
		END LOOP;
		COMMIT;
	end add_po_lines;
	
	PROCEDURE add_invoice_headers
	IS
	begin
		for invh in (select distinct a.inv from (
		select INVOICE_REFERENCE,
		substr(x.INVOICE_REFERENCE,1,instr(x.INVOICE_REFERENCE,'.',1)-1) INV
		from XXBCM_ORDER_MGT x) a
		where a.inv is not null
		order by a.inv)
		LOOP
			INSERT into XX_INVOICE_HEADERS (invoice_number) 
			VALUES (invh.inv);
		END LOOP;
		COMMIT;
	end add_invoice_headers;
	
	PROCEDURE add_invoice_lines
	IS
	begin
		for invl in (select distinct 
		INVOICE_REFERENCE
		,(select invoice_header_id from XX_INVOICE_HEADERS
		where invoice_number = substr(x.INVOICE_REFERENCE,1,instr(x.INVOICE_REFERENCE,'.',1)-1)) invoice_header_id
		,row_number() over (partition by substr(INVOICE_REFERENCE,1,instr(INVOICE_REFERENCE,'.',1)-1) order by INVOICE_REFERENCE) inv_num
		,p.po_line_id
		,to_date(INVOICE_DATE,'DD-MM-YYYY') INVOICE_DATE
		,INVOICE_DESCRIPTION
		,replace(replace(replace(replace(INVOICE_AMOUNT,',',''),'I','1'),'S','5'),'o','0') INVOICE_AMOUNT
		,INVOICE_STATUS
		,(select invoice_hold_id from XX_INVOICE_HOLDS where INVOICE_HOLD_REASON = x.INVOICE_HOLD_REASON) invoice_hold_id
		from XXBCM_ORDER_MGT x
		,XX_PO_LINES p
		where INVOICE_REFERENCE like '%.%'
		and p.po_reference = x.order_ref
		and p.po_line_desc = x.ORDER_DESCRIPTION
		order by INVOICE_REFERENCE)
		LOOP
			INSERT into XX_INVOICE_LINES (invoice_reference,invoice_header_id,invoice_number,po_line_id,invoice_date,invoice_desc,invoice_amount,invoice_status,invoice_hold_id) 
			VALUES (invl.INVOICE_REFERENCE,invl.invoice_header_id,invl.inv_num,invl.po_line_id,invl.INVOICE_DATE,invl.INVOICE_DESCRIPTION,invl.INVOICE_AMOUNT,invl.INVOICE_STATUS,invl.invoice_hold_id);
		END LOOP;
		COMMIT;
	end add_invoice_lines;
	
END XX_DATA_MIGRAION_PKG;
/