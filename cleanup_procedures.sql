CREATE VIEW oldest_bid AS 
SELECT *
FROM bid 
WHERE bid_status = 'pending' 
ORDER BY placed_at 
LIMIT 1;
CREATE VIEW oldest_ask AS 
SELECT *
FROM ask 
WHERE ask_status = 'pending' 
ORDER BY placed_at 
LIMIT 1;

DELIMITER |
CREATE PROCEDURE cleanup_bidTable()
BEGIN
	DECLARE placing_date date ;
    check_bid_status : LOOP
		set placing_date = (SELECT placed_at FROM oldest_bid);
        IF placing_date is null then 
			leave check_bid_status ;
        ELSEIF DAY(CURRENT_DATE()) > DAY(placing_date) THEN 
			update bid
            set bid_status = 'expired'
            where bid_id = (select bid_id from oldest_bid);
		ELSE 
			leave check_bid_status ;
		END IF;
	END LOOP;
END |
DELIMITER ;

DELIMITER |
CREATE PROCEDURE cleanup_askTable()
BEGIN
	DECLARE placing_date date ;
    check_ask_status : LOOP
		set placing_date = (SELECT placed_at FROM oldest_ask);
        IF placing_date is null then 
			leave check_ask_status ;
        ELSEIF DAY(CURRENT_DATE()) > DAY(placing_date) THEN 
			update ask
            set ask_status = 'expired'
            where ask_id = (select ask_id from oldest_ask);
		ELSE 
			leave check_ask_status ;
		END IF;
	END LOOP;
END |
DELIMITER ;