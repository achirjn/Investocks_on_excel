
delimiter |

CREATE TRIGGER validate_bid
BEFORE INSERT
ON bid
FOR EACH ROW
BEGIN
	if (select company_id from company_info where company_id = new.company_id) is null then 
		signal SQLSTATE '45000'
        set message_text = 'company not found';
    END if;
    IF new.quantity <= 0 THEN 
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'quantity cannot be zero' ;
	end if;
    IF (select limit_balance from user_info where user_id = new.user_id) < (new.quantity * new.bid_price) Then 
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'insufficient balance'; 
	end if;
    IF new.bid_price <> 0 AND new.bid_price > (select closed_price + (circuit_limit/100)*closed_price from company_info where company_id = new.company_id) THEN 
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'bid price exceeds the limit' ;
	end if;
    IF new.bid_price <> 0 AND new.bid_price < (select closed_price - (circuit_limit/100)*closed_price from company_info where company_id = new.company_id) THEN 
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'bid price preceeds the limit' ;
	end if;
end |
delimiter ;

delimiter |
CREATE TRIGGER validate_ask
BEFORE INSERT
ON ask
FOR EACH ROW
BEGIN
	if (select company_id from company_info where company_id = new.company_id) is null then 
		signal SQLSTATE '45000'
        set message_text = 'company not found';
    END if;
	IF new.quantity <= 0 THEN 
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'quantity cannot be zero' ;
	end if;
    IF new.quantity > (select quantity from share_balance where user_id = new.user_id and company_id = new.company_id) Then 
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'insufficient share balance'; 
	end if;
    IF new.ask_price <> 0 AND new.ask_price > (select closed_price + (circuit_limit/100)*closed_price from company_info where company_id = new.company_id) THEN 
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'ask price exceeds the limit' ;
	end if;
    IF new.ask_price <> 0 AND new.ask_price < (select closed_price - (circuit_limit/100)*closed_price from company_info where company_id = new.company_id) THEN 
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'ask price preceeds the limit' ;
	end if;
end |
delimiter ;
