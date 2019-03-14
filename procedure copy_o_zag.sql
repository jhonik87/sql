drop procedure copy_o_zag_o_spec(int,int,NCHAR(8));
create procedure copy_o_zag_o_spec(idnn int,priznak int, ownern NCHAR(8));
DEFINE zaknumn NCHAR(9);
DEFINE idnnew int;
DEFINE ndsnew int;
DEFINE resp,post int;
DEFINE data DATETIME YEAR to SECOND;
DEFINE sekt CHAR(2);
--присваиваем новый уникальный номер заказа
SELECT substr(MAX(nomerz),1,1)||substr((substr(MAX(nomerz),2,4)+1),1,4)||'/'||substr(year(today),3,4) into zaknumn FROM o_Zag;
if not EXISTS(select idn from o_zag where idn=idnn) then  
RAISE EXCEPTION  -746, 0, ' нельзя скопировать. Отсутствует заказ! ';  
end if; 

select (current::DATETIME YEAR to SECOND) into data FROM table(SET{1});

if priznak=0 then --не меняем цену и ндс
begin
insert into o_zag --вставка в таблицу заказы
  (viddoc,nomerz,nomers,kodz,kodp,
   dateoz,dateiz,datevs,summaz,summak,
   summan,sumopl,vidcalcnds,vidcalctn,nprod,
   torgn,sposr,sposrstr,fio,dogovor,
   uslovp,sposot,punct1,punct2,punct3,
   kodreg,stanc,nomerd,datevd,nomerpr,
   kurs,summad,svaluta,orgname,dialpsp,
   idn_nastr,sclad,procsk,sumsk,
   editdate,opnum,dopol1,dopol2,
   kpost,sektor,prioritet,przzakrzak,owner,
   paramvipslz,status,idncorpwww,nomerzwww,kredit,
   doknum,igk,datad,idn_o_zagd,idn_o_zagk,
   gosnum,data_gosnum)
select 
   viddoc,zaknumn,'',kodz,kodp,
   data,data,'',summaz,summak,
   summan,sumopl,vidcalcnds,vidcalctn,nprod,
   torgn,1,'','',dogovor,
   uslovp,sposot,punct1,punct2,punct3,
   kodreg,stanc,nomerd,datevd,nomerpr,
   kurs,summad,svaluta,orgname,dialpsp,
   idn_nastr,sclad,procsk,sumsk,
   data,ownern,dopol1,dopol2,
   kpost,sektor,prioritet,0,ownern,
   0,status,idncorpwww,nomerzwww,'',
   '',igk,datad,idn_o_zagd,idn_o_zagk,
   gosnum,data_gosnum
from o_zag where idn=idnn;
SELECT idn into idnnew FROM o_Zag where nomerz=zaknumn; --выбираем последний заказ
--вставка в таблицу спецификации
insert into o_spec(
   orderidn,nomerpp,group,code,tsort,
   tol,dlina,shir,edink,kolz1,
   edin,kolz2,price1,nds,summa,
   summad,nalprod,torgnac,koef,pereobrez,
   pereobrs,procsk,sumsk,editdate,opnum,
   vidis,naznpost,kvc,ki8,rek,
   eir,price_tmc,przzakrzak)
select 
   idnnew,nomerpp,group,code,tsort,
   tol,dlina,shir,edink,kolz1,
   edin,kolz2,price1,nds,summa,
   summad,nalprod,torgnac,koef,pereobrez,
   pereobrs,procsk,sumsk,data,ownern,
   vidis,naznpost,kvc,ki8,rek,
   eir,price_tmc,przzakrzak
from o_spec where orderidn=idnn;
end;
end if;
if priznak=1 then --меняем цену и ндс
begin
select res,postindex,c.sektor into resp,post,sekt from k_corp a,k_vil b,o_zag c where a.vilnum=b.code and a.plant=c.kodp and c.idn=idnn;
if resp=1 then
let ndsnew=20;     --если Россия то НДС 20%
else let ndsnew=0; --иначе 0%
end if;

insert into o_zag  --вставка в таблицу заказы
  (viddoc,nomerz,nomers,kodz,kodp,
   dateoz,dateiz,datevs,summaz,summak,
   summan,sumopl,vidcalcnds,vidcalctn,nprod,
   torgn,sposr,sposrstr,fio,dogovor,
   uslovp,sposot,punct1,punct2,punct3,
   kodreg,stanc,nomerd,datevd,nomerpr,
   kurs,summad,svaluta,orgname,dialpsp,
   idn_nastr,sclad,procsk,sumsk,
   editdate,opnum,dopol1,dopol2,
   kpost,sektor,prioritet,przzakrzak,owner,
   paramvipslz,status,idncorpwww,nomerzwww,kredit,
   doknum,igk,datad,idn_o_zagd,idn_o_zagk,
   gosnum,data_gosnum)
select 
   viddoc,zaknumn,'',kodz,kodp,
   data,data,'',summaz,summak,
   summan,sumopl,vidcalcnds,vidcalctn,nprod,
   torgn,1,'','',dogovor,
   uslovp,sposot,punct1,punct2,punct3,
   kodreg,stanc,nomerd,datevd,nomerpr,
   kurs,summad,svaluta,orgname,dialpsp,
   idn_nastr,sclad,procsk,sumsk,
   data,ownern,dopol1,dopol2,
   kpost,sektor,prioritet,0,ownern,
   0,status,idncorpwww,nomerzwww,'',
   '',igk,datad,idn_o_zagd,idn_o_zagk,
   gosnum,data_gosnum
from o_zag where idn=idnn;
SELECT idn into idnnew FROM o_Zag where nomerz=zaknumn;
--вставка в таблицу спецификации с использование функций actual_price(общая цена),actual_ceno(цена товара),actual_censh(цена штуцера)
insert into o_spec(
   orderidn,nomerpp,group,code,tsort,
   tol,dlina,shir,edink,kolz1,
   edin,kolz2,price1,nds,summa,
   summad,nalprod,torgnac,koef,pereobrez,
   pereobrs,procsk,sumsk,editdate,opnum,
   vidis,naznpost,kvc,ki8,rek,
   eir,price_tmc,przzakrzak)
select 
   idnnew,nomerpp,group,code,tsort,
   tol,dlina,shir,edink,kolz1,
   edin,kolz2,actual_price(code,post,sekt),ndsnew,summa,
   summad,(case when edin=edink then actual_price(code,post,sekt) else actual_price(code,post,sekt)*koef end),torgnac,koef,actual_ceno(code,post,sekt),
   actual_censh(code,post,sekt),procsk,sumsk,data,ownern,
   vidis,naznpost,kvc,ki8,rek,
   eir,actual_price(code,post,sekt),przzakrzak
from o_spec where orderidn=idnn;
update o_spec set summa=price1*kolz2 where orderidn=idnnew; --расчет суммы
--расчет суммы скидки с учетом тары
update o_spec set sumsk=(case when group<>'0T00' then (summa+summa*((100+torgnac)/100)*(nds/100))*procsk/100 else 0 end) where orderidn=idnnew;
-- обновляем итоговую сумму заказа и налогов
update o_zag set 
summaz=(select sum((summa*(100+torgnac)/100)*nds/100)+sum(summa*(100+torgnac)/100) from o_spec where orderidn=idnnew),
summan=(select sum((summa*(100+torgnac)/100)*nds/100) from o_spec where orderidn=idnnew),
nprod=0,
torgn= (select sum(summa*torgnac/100) from o_spec where orderidn=idnnew)
where idn=idnnew;

end;
end if;


end procedure;                                                                                                                                                     


