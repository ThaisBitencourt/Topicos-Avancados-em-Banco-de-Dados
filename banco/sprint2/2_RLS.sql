USE [master]
GO

-- Apagando O LOGIN caso exista
IF EXISTS(SELECT loginname FROM master.dbo.syslogins WHERE loginname = 'app')
	DROP LOGIN app
GO

--Criando um login de conexão do tipo SQLServer authentication
CREATE LOGIN [app] WITH PASSWORD=N'app', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

USE [Northwind]
GO

-- Apagando o usuario caso exista
IF EXISTS(SELECT name FROM sys.sysusers WHERE name = 'app')
	DROP USER app

-- Criando um usuario vinculado ao login
CREATE USER [app] FOR LOGIN [app]
ALTER ROLE [db_owner] ADD MEMBER [app]
ALTER SERVER ROLE [bulkadmin] ADD MEMBER [app]
GO

-- criando um schema para a implantação da RLS
CREATE SCHEMA Security;  
GO 

-- Adicionando o campo de flag na tabela
ALTER TABLE Customers ADD flag BIT DEFAULT 1 NOT NULL

-- Adicionando o campo de documento na tabela (emancipação)
ALTER TABLE People ADD documento VARBINARY(MAX)

-- Adicionando o campo de flag para doumentos validos na tabela (emancipação)
ALTER TABLE People ADD flag_documento BIT DEFAULT 1 NOT NULL

-- Adicionando o campo de flag para doumentos validos na tabela (emancipação)
ALTER TABLE Company ADD flag BIT DEFAULT 1 NOT NULL

GO

-- Apagando a tabela caso exista
IF OBJECT_ID(N'dbo.Flag_historico') IS NOT NULL
	DROP TABLE Flag_historico
GO

-- Criando a tabela de historico de alteracao da flag
CREATE TABLE Flag_historico (
	CustomerID INT,
	new_flag BIT,
	old_flag BIT,
	change_date datetime,
	CONSTRAINT FK_Flag FOREIGN KEY (CustomerID) REFERENCES dbo.Customers(CustomerID)
)

GO
SET NOCOUNT ON  

DECLARE @CustomerID INT

DECLARE cur_dados CURSOR FOR
	SELECT p.CustomerID FROM Customers c
	INNER JOIN People p
	ON c.CustomerID = p.CustomerID
	WHERE YEAR(GETDATE()) - YEAR(BirthDate) < 18
 
OPEN cur_dados  
    
FETCH NEXT FROM cur_dados into @CustomerID

WHILE @@FETCH_STATUS = 0  
	BEGIN 
		UPDATE People SET flag_documento = 0 WHERE CustomerID = @CustomerID
		UPDATE Customers SET flag = 0 WHERE CustomerID = @CustomerID

		FETCH NEXT FROM cur_dados into @CustomerID 
	END 
CLOSE cur_dados  
DEALLOCATE cur_dados

GO

-- Apagando usuarios caso exista
IF EXISTS(SELECT name FROM sys.sysusers WHERE name = 'admin') DROP USER administrator;
IF EXISTS(SELECT name FROM sys.sysusers WHERE name = 'sales1') DROP USER sales1;
IF EXISTS(SELECT name FROM sys.sysusers WHERE name = 'sales2') DROP USER sales2;

GO

CREATE USER admin WITHOUT LOGIN;  
CREATE USER sales1 WITHOUT LOGIN;  
CREATE USER sales2 WITHOUT LOGIN;  

GO

ALTER ROLE [db_owner] ADD MEMBER [admin]
ALTER ROLE [db_datareader] ADD MEMBER [sales1]
ALTER ROLE [db_datawriter] ADD MEMBER [sales1]
ALTER ROLE [db_datareader] ADD MEMBER [sales2]
ALTER ROLE [db_datawriter] ADD MEMBER [sales2]

GO

-- criação da função com valor de tabela Customer
CREATE OR ALTER FUNCTION Security.fn_securitypredicateCutomer(@flag int)  
    RETURNS TABLE  
WITH SCHEMABINDING
AS  -- retorna 1 quando verdadeiro
    RETURN SELECT 1 AS fn_securitypredicate_result
	WHERE @flag = 1
	OR USER_NAME() IN ('app', 'admin','sa')
GO

-- criacao da politica de segurança (RLS) com a função, como predicado
CREATE SECURITY POLICY CustomerFilter  
ADD FILTER PREDICATE Security.fn_securitypredicateCutomer(flag)
ON dbo.Customers
WITH (STATE = ON);

GO

-- concedendo privilégio a função aos usuarios
GRANT SELECT ON Security.fn_securitypredicateCutomer TO admin;  
GRANT SELECT ON Security.fn_securitypredicateCutomer TO sales1;  
GRANT SELECT ON Security.fn_securitypredicateCutomer TO sales2; 
GRANT SELECT ON Security.fn_securitypredicateCutomer TO app;

GO

-- criação da função com valor de tabela People
CREATE OR ALTER FUNCTION Security.fn_securitypredicatePeople(@flag_documento int)  
    RETURNS TABLE  
WITH SCHEMABINDING
AS  -- retorna 1 quando verdadeiro
    RETURN SELECT 1 AS fn_securitypredicatePeople_result
	WHERE @flag_documento = 1
	OR USER_NAME() IN ('app', 'admin','sa')
GO

-- criacao da politica de segurança (RLS) com a função, como predicado
CREATE SECURITY POLICY PeopleFilter  
ADD FILTER PREDICATE Security.fn_securitypredicatePeople(flag_documento)
ON dbo.People
WITH (STATE = ON);

GO

-- concedendo privilégio a função aos usuarios
GRANT SELECT ON Security.fn_securitypredicatePeople TO admin;  
GRANT SELECT ON Security.fn_securitypredicatePeople TO sales1;  
GRANT SELECT ON Security.fn_securitypredicatePeople TO sales2; 
GRANT SELECT ON Security.fn_securitypredicatePeople TO app

GO

-- criação da função com valor de tabela Company
CREATE OR ALTER FUNCTION Security.fn_securitypredicateCompany(@flag int)  
    RETURNS TABLE  
WITH SCHEMABINDING
AS  -- retorna 1 quando verdadeiro
    RETURN SELECT 1 AS fn_securitypredicateCompany_result
	WHERE @flag = 1
	OR USER_NAME() IN ('app', 'admin','sa')
GO

-- criacao da politica de segurança (RLS) com a função, como predicado
CREATE SECURITY POLICY CompanyFilter  
ADD FILTER PREDICATE Security.fn_securitypredicateCompany(flag)
ON dbo.Company
WITH (STATE = ON);

GO

-- concedendo privilégio a função aos usuarios
GRANT SELECT ON Security.fn_securitypredicateCompany TO admin;  
GRANT SELECT ON Security.fn_securitypredicateCompany TO sales1;  
GRANT SELECT ON Security.fn_securitypredicateCompany TO sales2; 
GRANT SELECT ON Security.fn_securitypredicateCompany TO app
