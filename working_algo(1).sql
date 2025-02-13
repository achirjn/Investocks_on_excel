
delimiter |
create function calculate_price(
	cid int ,
	b_price int ,
	a_price int
)
returns int
deterministic
begin 
	if b_price = 0 and a_price = 0 then 
		return (select closed_price from company_info where company_id = cid);
	elseif b_price = 0 and a_price <> 0 then
		return a_price;
	elseif b_price <> 0 and a_price = 0 then
		return b_price;
	else 
		return a_price;
	end if;
end |
delimiter ;


delimiter |
create procedure tcheck(
	in cid int
)
begin 
	DECLARE done INT DEFAULT FALSE;
    declare bid int ;
    declare bpx int;
    declare bqty int;
    declare aid int ;
    declare apx int;
    declare aqty int;
    declare cpx int ;
    declare beq int ;
    declare aeq int ;
    
	declare cbid cursor for
    select bid_id, bid_price, quantity from (
	select 1 as rnk, bid_id,  quantity, placed_at, bid_price from bid where bid_status = 'pending' and company_id = cid and bid_price = 0  
	union all
	select 2 as rnk, bid_id, quantity, placed_at, bid_price from bid where bid_status = 'pending' and company_id = cid and bid_price > 0 order by bid_price desc) a
	order by rnk ;
    
    declare cask cursor for
    select ask_id, ask_price , quantity from ask where ask_status = 'pending' and company_id = cid order by ask_price asc , placed_at asc ;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    open cbid ;
    open cask;
    fetch cbid into bid,bpx,bqty;
	fetch cask into aid,apx,aqty;
    check_t: loop
        if (bpx = 0 or apx = 0 or bpx >= apx) and done=false then
			set cpx = calculate_price( cid , bpx , apx);
            -- select 'trade price',cpx;
            if (select count(*) from exec_bid where bid_id = bid ) = 0 then
				set beq = 0;
			else 
				set beq = (select sum(qty) from exec_bid where bid_id = bid);
			end if;
            if (select count(*) from exec_ask where ask_id = aid ) = 0 then
				set aeq = 0;
			else 
				set aeq = (select sum(qty) from exec_ask where ask_id = aid);
			end if;
            if (bqty-beq) = (aqty-aeq) then
				call trade(cid, bid, aid , cpx , bqty-beq);
                insert into exec_bid 
                values(default , bid , bqty-beq);
                insert into exec_ask 
                values(default , aid , bqty-beq);
                update bid 
                set bid_status = 'executed'
                where bid_id = bid;
                update ask 
                set ask_status = 'executed'
                where ask_id = aid;
				-- select 'equal quantity';
                fetch cbid into bid,bpx,bqty;
				fetch cask into aid,apx,aqty;
			elseif (bqty-beq) > (aqty-aeq) then
				call trade(cid, bid, aid , cpx , aqty-aeq);
                insert into exec_bid 
                values(default , bid , aqty-aeq);
                insert into exec_ask 
                values(default , aid , aqty-aeq);
                update ask 
                set ask_status = 'executed'
                where ask_id = aid;
				-- select 'less ask';
                fetch cask into aid,apx,aqty;
			else
				call trade(cid, bid, aid , cpx , bqty-beq);
                insert into exec_bid 
                values(default , bid , bqty-beq);
                insert into exec_ask 
                values(default , aid , bqty-beq);
				-- select 'more ask';
                update bid 
                set bid_status = 'executed'
                where bid_id = bid;
                fetch cbid into bid,bpx,bqty;
			end if;
		else	
			leave check_t;
		end if;
	end loop;
end |
delimiter ;


delimiter |
create procedure trade(
	in cid int ,
    in bid int,
    in aid int,
    in px int,
    in qty int
)
begin
	insert into trade_info 
    values(default , cid, bid, aid, qty , px , default );
    if (select count(*) from share_balance where user_id = (select user_id from bid where bid_id = bid ) and company_id = cid ) =0 then
		insert into share_balance 
        values((select user_id from bid where bid_id = bid ) , cid , qty);
	else 
		update share_balance 
        set quantity = qty + quantity
        where user_id = (select user_id from bid where bid_id = bid ) and company_id = cid;
	end if;
	if (select quantity from share_balance where user_id = (select user_id from ask where ask_id = aid ) and company_id = cid) - qty = 0 then
		delete from share_balance where user_id = (select user_id from ask where ask_id = aid ) and company_id = cid;
	else
		update share_balance 
        set quantity = quantity - qty
        where user_id = (select user_id from ask where ask_id = aid ) and company_id = cid;
	end if;
	update user_info 
    set limit_balance = limit_balance - (px*qty)
    where user_id = (select user_id from bid where bid_id = bid );
    update user_info 
    set limit_balance = limit_balance + (px*qty)
    where user_id = (select user_id from ask where ask_id = aid ) ;
end |
delimiter ;




-- to make the cursors:
-- select bid_id,  quantity, placed_at, bid_price from (
-- select 1 as rnk, bid_id,  quantity, placed_at, bid_price from bid where bid_status = 'pending' and company_id = 1 and bid_price = 0  
-- union all
-- select 2 as rnk, bid_id, quantity, placed_at, bid_price from bid where bid_status = 'pending' and company_id = 1 and bid_price > 0 order by bid_price desc) a
-- order by rnk ;
--     