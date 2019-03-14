drop function actual_price(NCHAR(20),INTEGER,CHAR(2));
create function actual_price(coden NCHAR(20),postindexn INTEGER,sektorn CHAR(2)) returning DECIMAL(32,5);
--функция расчета цены товара на текущую дату
define price,cenon,censhn,k DECIMAL(32,5);
define matn CHAR(15);
define vin NCHAR(1);
define kvcn VARCHAR(2);
define price1n,price2n decimal(32,2);
DEFINE data,dtvocn DATETIME YEAR to SECOND;
define eirn smallint;
define recn CHAR(8);
select (current::DATETIME YEAR to SECOND) into data FROM table(SET{1});

LET price  = 0;
let cenon=0;
let censhn=0;
let recn=1;
select mat,vi,kvc,price1,price2,eir,rec into matn,vin,kvcn,price1n,price2n,eirn,recn from k_tmc where codetmc=coden;
if price1n is not null then
let price=price1n;
end if;
-- находим цену товара и штуцера в зависимости от покупателя
if ((price1n=0) and (price2n=0)) then
  begin
    select max(dtvoc) into dtvocn from k_cetmc where ki8=matn and VI=vin and KVC=kvcn and date(dtvoc)<=date(data) and postindex=postindexn;
    if dtvocn is not NULL then
      begin
        select ceno,censh into cenon,censhn from k_cetmc where ki8=matn and VI=vin and KVC=kvcn and date(dtvoc)=date(dtvocn) and postindex=postindexn;     
      end;              
    else 
      begin
        select max(dtvoc) into dtvocn from k_cetmc where ki8=matn and VI=vin and KVC=kvcn and date(dtvoc)<=date(data) and postindex=0;
          if dtvocn is not NULL then
            begin
              select ceno,censh into cenon,censhn from k_cetmc where ki8=matn and VI=vin and KVC=kvcn and date(dtvoc)=date(dtvocn) and postindex=0;            
            end;
          else 
            begin
              let cenon=0;
              let censhn=0;
            end;
          end if;        
      end;  
    end if;    
  end;
end if;
--некондиция
if sektorn='56' then
  begin
    let cenon=cenon*0.6;
    let censhn=censhn*0.6;
  end; 
end if;

--расчет цены штуцера в зависимости от единиц измерения
if censhn>0 then
  begin
    let k=1;
    if eirn=3 then let k=0.001; end if;
    if eirn=4 then let k=0.01; end if;
    if eirn=5 then let k=0.1; end if;
    {if substr(recn,5,4)=0 then
    let recn=substr(recn,1,4)||'0001';
    end if;}
    let price=(censhn/(substr(recn,5,4)))/k+cenon;
  end
else
  begin
    let price=cenon;
  end;
end if; 


return price;
end function;                                                                                                                                                     
