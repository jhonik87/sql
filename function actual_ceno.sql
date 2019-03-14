drop function actual_ceno(NCHAR(20),INTEGER,CHAR(2));
create function actual_ceno(coden NCHAR(20),postindexn INTEGER,sektorn CHAR(2)) returning DECIMAL(32,5);
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

if sektorn='56' then
  begin
    let cenon=cenon*0.6;
    let censhn=censhn*0.6;
  end; 
end if;

if cenon>0 then
    let price=cenon;
else
    let price=0;
end if; 


return price;
end function;