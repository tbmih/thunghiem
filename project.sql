#Câu 1:Trung bình mỗi loại tài sản thế chấp được vay bao nhiêu tiền
CREATE TABLE `banking application`.cau1( 
select `Collateral Type`, round(avg(`Face Value`)) AVGfacevalue,round(avg(Capital)) AVGCapital
from application_banking ab 
group by `Collateral Type`)

#Câu 2:Ngành công nghiệp chiếm tỷ lệ đi vay nhiều nhất
CREATE TABLE `banking application`.cau2(
select b.Industry, sum(a.Capital) khoanvay
from application_banking a
right join customer1 b on a.`Customer ID` = b.`Customer ID` 
group by b.Industry  )

#Câu 3:Tổng khoản vay và lãi của công ty mẹ phải trả qua các năm` 
CREATE TABLE `banking application`.cau3( 
select b.`Group Name`,sum(a.Capital) as total_capital, year (a.`Closed Date`) as year_close, sum(a.`Annual Interest Income`) as total_interest
from application_banking a
right join customer1 b on a.`Group Name ID` = b.`Group ID` 
group by year (a.`Closed Date`) ,b.`Group Name`)


#Câu 4: Khu vực nào có nhiều chi nhánh nhất 
CREATE TABLE `banking application`.cau4 (
select `branch region`, count(`branch name`) as NumBranch
from bankdetails b
group by `Branch region`
order by NumBranch desc)

#Câu 5: Chi nhánh nào có nhiều quản lý nhất
CREATE TABLE `banking application`.cau5(
select `branch name`, `Branch Region`, count(`Relationship Manager ID`) as NumMan, `Relationship Manager`
from bankdetails b
group by `branch name`
order by count(`Relationship Manager ID`) desc)

#Câu 6: Thông tin những quản lí chi nhánh có nhiều yêu cầu xin vay nhất
CREATE TABLE `banking application`.cau6(
select a.`relationship manager id`, a.`relationship manager` as Manager, a.`Branch Region`, a.`branch name`, count(b.`application ID`) as total_app
from bankdetails a
left join application_banking b
on a.`Relationship Manager ID` = b.`RM ID`
group by a.`relationship manager id`
order by total_app desc )


#Câu 7: Chi nhánh nào cho vay nhiều tiền nhất, họ cũng có thu nhập lãi suất cao nhất và tổng giá trị tài sản thế chấp
CREATE TABLE `banking application`.cau7(
with rank_loan as (select a.`branch name`, a.`Branch Region`, sum(b.capital) as total_loan, RANK() OVER(ORDER BY sum(b.capital) DESC) as rank_loan from bankdetails a
   				left join application_banking b on a.`Relationship Manager ID` = b.`RM ID`
   				group by a.`branch name`
   				order by total_loan desc),
     rank_collateral as (select a1.`branch name`, a1.`Branch Region`, sum(b1.`Face value`) as total_collateral, RANK() OVER(ORDER BY sum(b1.`Face value`) DESC) as rank_collateral from bankdetails a1
   			   		  left join application_banking b1 on a1.`Relationship Manager ID` = b1.`RM ID`
   				  	group by a1.`branch name`
   			     	  order by total_collateral desc),
     rank_income as (select a2.`branch name`, a2.`Branch Region`, sum(b2.`Annual Interest Income`) as total_Interest_income, RANK() OVER(ORDER BY sum(b2.`Annual Interest Income`) DESC) as rank_Interest from bankdetails a2
   			  	left join application_banking b2 on a2.`Relationship Manager ID` = b2.`RM ID`
   			  	group by a2.`branch name`
   			  	order by total_Interest_income desc)
select    r.`branch name`, r.`branch region`, r.total_loan, r.rank_loan, i.rank_Interest, c.rank_collateral from rank_loan r
left join rank_income i on r.`branch name` = i.`branch name`
left join rank_collateral c on r.`branch name` = c.`branch name`
order by r.rank_loan asc limit 10)

#Câu 8: Mục đích vay và loại thế chấp phổ biến nhất ở từng vùng
CREATE TABLE `banking application`.cau8(
with BranchApp as (select  b.`branch region`, a.`Application Type`, count(a.`Application Type`) as AppQuantity from application_banking a
   				 left join bankdetails b on a.`RM ID` = b.`Relationship Manager ID`
   				 group by b.`Branch Region` , a.`Application Type`
   				 order by b.`Branch region`asc, count(a.`Application Type`) desc),
     BranchColla as (select  b2.`branch region`, a2.`Collateral Type`, count(a2.`Collateral Type`) as CollateralQuantity from application_banking a2
   				 left join bankdetails b2 on a2.`RM ID` = b2.`Relationship Manager ID`
   				 group by b2.`Branch Region` , a2.`Collateral Type`
   				 order by b2.`Branch region`asc, count(a2.`Collateral Type`) desc)
select a3.`branch region`,a3.`Application Type`, a3.AppQuantity, b3.`Collateral Type`, b3.CollateralQuantity  from branchapp a3
right join branchcolla b3 on a3.`branch region` = b3.`branch region`
group by a3.`branch region`)

#Câu 9: Tổng tiền cho vay ra, lãi phải thu và giá trí của tài sản thế chấp của từng năm
CREATE TABLE `banking application`.cau9(
select year(`Entered Date`) as entered_year, sum(Capital) as total_loan, sum(`Annual Interest Income`) as total_income, sum(`Face Value`) as total_collateral
from application_banking ab
group by entered_year)

#Câu 10: Thay đổi tổng khoản vay tiền mỗi tháng của 2015 và 2016
CREATE TABLE `banking application`.cau10(
with 2015loan as (select month(`Entered Date`) as monthEntered, sum(capital) as 2015loan from application_banking ab
   			   where year(`Entered Date`) = 2015
   			   group by monthEntered
   			   order by monthEntered asc),
     2016loan as (select month(`Entered Date`) as monthEntered, sum(capital) as 2016loan from application_banking ab1
   			   where year(`Entered Date`) = 2016
   			   group by monthEntered
   			   order by monthEntered asc)
select a.monthEntered, a.2015loan, b.2016loan, round(((b.2016loan - a.2015loan)/a.2015loan)*100, 2) as percentage_change from 2015loan as a
join 2016loan as b on a.monthEntered = b.monthEntered)

#Câu 11: Xếp hạng tín dụng cho các khoản vay
CREATE TABLE `banking application`.cau11  (
select b.`Customer ID`,  a.Capital, a.`Collateral Type`, a.`Face Value`, a.Rating,
case
	when a.rating in(1,2) then 'Excelent'
	when a.rating in(3,4) then 'Good'
	else 'Normal'
end as ranking 
from application_banking a
right join customer1 b on a.`Customer ID` = b.`Customer ID` 
)


