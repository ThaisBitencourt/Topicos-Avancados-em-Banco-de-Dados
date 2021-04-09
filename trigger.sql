USE Northwind
GO

IF ((SELECT COUNT(*) FROM sys.triggers WHERE name = 'trg_popula_historico_flag' AND parent_id = OBJECT_ID('Northwind.dbo.Customers')) > 0) 
	DROP TRIGGER trg_popula_historico_flag
GO

CREATE TRIGGER trg_popula_historico_flag
ON dbo.Customers
AFTER INSERT, UPDATE AS
BEGIN
	SET NOCOUNT ON  

	DECLARE @CustomerID INT,
			@new_flag BIT,
			@old_flag BIT

	DECLARE cur_dados CURSOR FOR
		SELECT i.CustomerID, i.flag, o.flag
		FROM inserted i, deleted o
		WHERE i.CustomerID = o.CustomerID
		AND i.flag <> o.flag
 
    OPEN cur_dados  
    
	FETCH NEXT FROM cur_dados into @CustomerID, @new_flag, @old_flag 

    WHILE @@FETCH_STATUS = 0  
		BEGIN 
			INSERT INTO Northwind.dbo.Flag_historico (CustomerID, new_flag, old_flag, change_date)
			VALUES (@CustomerID, @new_flag, @old_flag, GETDATE())

			FETCH NEXT FROM cur_dados into @CustomerID, @new_flag, @old_flag     
		END 
    CLOSE cur_dados  
    DEALLOCATE cur_dados
END

GO

SELECT name, object_id, create_date FROM sys.triggers WHERE name = 'trg_popula_historico_flag';