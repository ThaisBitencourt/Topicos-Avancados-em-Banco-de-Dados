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

	DECLARE cur_historico CURSOR LOCAL FOR
		SELECT i.CustomerID, i.flag, o.flag
		FROM inserted i, deleted o
		WHERE i.CustomerID = o.CustomerID
		AND i.flag <> o.flag
 
    OPEN cur_historico  
    
	FETCH NEXT FROM cur_historico into @CustomerID, @new_flag, @old_flag 

    WHILE @@FETCH_STATUS = 0  
		BEGIN 
			INSERT INTO Northwind.dbo.Flag_historico (CustomerID, new_flag, old_flag, change_date)
			VALUES (@CustomerID, @new_flag, @old_flag, GETDATE())

			FETCH NEXT FROM cur_historico into @CustomerID, @new_flag, @old_flag     
		END 
    CLOSE cur_historico  
    DEALLOCATE cur_historico
END

GO

IF ((SELECT COUNT(*) FROM sys.triggers WHERE name = 'trg_people_popula_historico_flag' AND parent_id = OBJECT_ID('Northwind.dbo.People')) > 0) 
	DROP TRIGGER trg_people_popula_historico_flag
GO

CREATE TRIGGER trg_people_popula_historico_flag
ON dbo.People
AFTER INSERT, UPDATE AS
BEGIN
	SET NOCOUNT ON  

	DECLARE @CustomerID INT,
			@new_flag BIT,
			@old_flag BIT

	DECLARE cur_people_historico CURSOR LOCAL FOR
		SELECT i.CustomerID, i.flag_documento, o.flag_documento
		FROM inserted i, deleted o
		WHERE i.CustomerID = o.CustomerID
		AND i.flag_documento <> o.flag_documento
 
    OPEN cur_people_historico  
    
	FETCH NEXT FROM cur_people_historico into @CustomerID, @new_flag, @old_flag 

    WHILE @@FETCH_STATUS = 0  
		BEGIN 
			INSERT INTO Northwind.dbo.Flag_historico (CustomerID, new_flag, old_flag, change_date)
			VALUES (@CustomerID, @new_flag, @old_flag, GETDATE())

			FETCH NEXT FROM cur_people_historico into @CustomerID, @new_flag, @old_flag     
		END 
    CLOSE cur_people_historico  
    DEALLOCATE cur_people_historico
END

GO

IF ((SELECT COUNT(*) FROM sys.triggers WHERE name = 'trg_company_popula_historico_flag' AND parent_id = OBJECT_ID('Northwind.dbo.Company')) > 0) 
	DROP TRIGGER trg_company_popula_historico_flag
GO

CREATE TRIGGER trg_company_popula_historico_flag
ON dbo.Company
AFTER INSERT, UPDATE AS
BEGIN
	SET NOCOUNT ON  

	DECLARE @CustomerID INT,
			@new_flag BIT,
			@old_flag BIT

	DECLARE cur_company_historico CURSOR LOCAL FOR
		SELECT i.CustomerID, i.flag, o.flag
		FROM inserted i, deleted o
		WHERE i.CustomerID = o.CustomerID
		AND i.flag <> o.flag
 
    OPEN cur_company_historico  
    
	FETCH NEXT FROM cur_company_historico into @CustomerID, @new_flag, @old_flag 

    WHILE @@FETCH_STATUS = 0  
		BEGIN 
			INSERT INTO Northwind.dbo.Flag_historico (CustomerID, new_flag, old_flag, change_date)
			VALUES (@CustomerID, @new_flag, @old_flag, GETDATE())

			FETCH NEXT FROM cur_company_historico into @CustomerID, @new_flag, @old_flag     
		END 
    CLOSE cur_company_historico  
    DEALLOCATE cur_company_historico
END

GO

IF ((SELECT COUNT(*) FROM sys.triggers WHERE name = 'trg_controla_flag_Customer' AND parent_id = OBJECT_ID('Northwind.dbo.Customers')) > 0) 
	DROP TRIGGER trg_controla_flag_Customer
GO

CREATE TRIGGER trg_controla_flag_Customer
ON dbo.Customers
AFTER UPDATE AS
BEGIN
	SET NOCOUNT ON  

	DECLARE @CustomerID INT,
			@flag BIT

	DECLARE cur_customer CURSOR LOCAL FOR
		SELECT CustomerID, flag
		FROM inserted 

    OPEN cur_customer  
    
	FETCH NEXT FROM cur_customer into @CustomerID, @flag

    WHILE @@FETCH_STATUS = 0  
		BEGIN
			IF EXISTS(SELECT CustomerID FROM People WHERE CustomerID = @CustomerID)
			  BEGIN
				UPDATE People SET flag_documento = @flag WHERE CustomerID = @CustomerID
			  END
			ELSE
			  BEGIN
				UPDATE Company SET flag = @flag WHERE CustomerID = @CustomerID
			  END
			FETCH NEXT FROM cur_customer into @CustomerID, @flag
		END 
    CLOSE cur_customer  
    DEALLOCATE cur_customer
END

GO

IF ((SELECT COUNT(*) FROM sys.triggers WHERE name = 'trg_controla_flag_People' AND parent_id = OBJECT_ID('Northwind.dbo.People')) > 0) 
	DROP TRIGGER trg_controla_flag_People
GO

CREATE TRIGGER trg_controla_flag_People
ON dbo.People
AFTER INSERT, UPDATE AS
BEGIN
	SET NOCOUNT ON  

	DECLARE @CustomerID INT,
			@BirthDate DATE,
			@Documento VARBINARY(MAX),
			@flag_documento BIT

	DECLARE cur_people CURSOR LOCAL FOR
		SELECT CustomerID, BirthDate, Documento, flag_documento
		FROM inserted 

    OPEN cur_people
    
	FETCH NEXT FROM cur_people into @CustomerID, @BirthDate, @Documento, @flag_documento

    WHILE @@FETCH_STATUS = 0  
		BEGIN 
			IF (YEAR(GETDATE()) - YEAR(@BirthDate) < 18) AND @Documento IS NULL
			  BEGIN
				UPDATE People SET flag_documento = 0 WHERE CustomerID = @CustomerID;
				UPDATE Customers SET flag = 0 WHERE CustomerID = @CustomerID;
			  END
			ELSE
			  BEGIN
				UPDATE Customers SET flag = @flag_documento WHERE CustomerID = @CustomerID;
			  END

			FETCH NEXT FROM cur_people into @CustomerID, @BirthDate, @Documento, @flag_documento
		END 
    CLOSE cur_people
    DEALLOCATE cur_people
END

GO

IF ((SELECT COUNT(*) FROM sys.triggers WHERE name = 'trg_controla_flag_Company' AND parent_id = OBJECT_ID('Northwind.dbo.Company')) > 0) 
	DROP TRIGGER trg_controla_flag_Company
GO

CREATE TRIGGER trg_controla_flag_Company
ON dbo.Company
AFTER INSERT, UPDATE AS
BEGIN
	SET NOCOUNT ON  

	DECLARE @CustomerID INT,
			@flag BIT

	DECLARE cur_company CURSOR LOCAL FOR
		SELECT CustomerID, flag
		FROM inserted 

    OPEN cur_company  
    
	FETCH NEXT FROM cur_company into @CustomerID, @flag

    WHILE @@FETCH_STATUS = 0  
		BEGIN 
			UPDATE Customers SET flag = @flag WHERE CustomerID = @CustomerID

			FETCH NEXT FROM cur_company into @CustomerID, @flag
		END 
    CLOSE cur_company  
    DEALLOCATE cur_company
END

GO

SELECT name, object_id, create_date FROM sys.triggers WHERE name IN ('trg_popula_historico_flag', 'trg_people_popula_historico_flag', 'trg_company_popula_historico_flag', 'trg_controla_flag_Customer', 'trg_controla_flag_People', 'trg_controla_flag_Company');