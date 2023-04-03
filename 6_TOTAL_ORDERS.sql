with x as 
(
select supp.supplier_name 
,supp.supp_contact_name 
,count(po_number) po_count
,decode(length(supp_con.contact_number),7,substr(supp_con.contact_number,1,3)||'-'||substr(supp_con.contact_number,4,7), substr(supp_con.contact_number,1,4)||'-'||substr(supp_con.contact_number,5,8)) contact_number
,sum(po_total_amount) po_tot_amt
,row_number() over (partition by supp.supplier_name order by supp_con.contact_number) rn
from XX_PO_HEADERS poh
,XX_SUPPLIERS supp
,XX_SUPPLIER_CONTACTS supp_con
where 1=1
and poh.supplier_id = supp.supplier_id
and supp_con.supplier_id = supp.supplier_id
and po_date between '01-JAN-2017' and '31-AUG-2017'
group by supp.supplier_name 
,supp.supp_contact_name 
,supp_con.contact_number 
)
select x.SUPPLIER_NAME "Supplier Name"
,x.supp_contact_name "Supplier Contact Name"
,max(case when rn = 1 then regexp_replace(x.contact_number, '\s+', '') end) "Supplier Contact No. 1"
,max(case when rn = 2 then regexp_replace(x.contact_number, '\s+', '') end) "Supplier Contact No. 2"
,sum(po_count) "Total Orders"
,to_char(sum(po_tot_amt),'fm999G999G999D00') "Order Total Amount"
from x
group by x.SUPPLIER_NAME, x.SUPP_CONTACT_NAME
order by x.SUPPLIER_NAME, x.SUPP_CONTACT_NAME
;