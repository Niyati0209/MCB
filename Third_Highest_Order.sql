select a.po_num "Order Reference"
,a.po_date "Order Date"
,a.po_supp "Supplier Name"
,a.po_total "Order Total Amount"
,a.po_status "Order Status"
--,a.invoice_number "INV"
,listagg(a.invoice_reference,', ') 
within group(order by a.po_num)as "Invoice References"
from 
(select distinct to_number(substr(poh.po_number,3,length(poh.po_number))) po_num
,to_char(poh.po_date,'MONTH DD,YYYY') po_date
,upper(supp.supplier_name) po_supp
--,poh.po_total_amount po_total
,to_char(poh.po_total_amount,'fm999G999G999D00') po_total
,poh.po_status
--,ih.invoice_number 
,il.invoice_reference
,dense_rank() over(order by poh.po_total_amount desc) r
from XX_PO_HEADERS poh
,XX_SUPPLIERS supp
,XX_PO_LINES pol
,XX_INVOICE_HEADERS ih
,XX_INVOICE_LINES il
where 1=1
and poh.supplier_id = supp.supplier_id
and poh.po_header_id = pol.po_header_id
and ih.invoice_header_id = il.invoice_header_id
and il.po_line_id = pol.po_line_id
--order by to_number(substr(poh.po_number,3,length(poh.po_number)))
order by il.invoice_reference
) a
where r = 3
group by a.po_num
,a.po_date
,a.po_supp
,a.po_total
,a.po_status
;
