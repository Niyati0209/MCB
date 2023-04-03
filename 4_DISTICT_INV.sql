select to_number(substr(poh.po_number,3,length(poh.po_number))) "Order Reference"
,to_char(poh.po_date,'MON-YY') "Order Period"
,initcap(supp.supplier_name) "Supplier Name"
,to_char(poh.po_total_amount,'fm999G999G999D00') "Order Total Amount"
,poh.po_status "Order Status"
,ih.invoice_number "Invoice Reference"
,to_char(sum(il.invoice_amount),'fm999G999G999D00') "Invoice Total Amount"
,decode(sum(decode(il.INVOICE_STATUS,'Paid','0','1')),'0','OK','To follow up') "Action"
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
group by poh.po_number
,to_char(poh.po_date,'MON-YY')
,supp.supplier_name
,to_char(poh.po_total_amount,'fm999G999G999D00')
,poh.po_status
,ih.invoice_number
order by poh.po_number
;