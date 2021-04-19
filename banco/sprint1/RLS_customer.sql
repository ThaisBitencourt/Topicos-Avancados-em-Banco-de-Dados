USE Northwind
GO

CREATE SCHEMA Security;  
GO 

-- Criando um campo de flag na tabela
ALTER TABLE Customers ADD flag BIT DEFAULT 1 not null


-- Apagando a tabela caso exista
if exists(select name from sys.databases where name = 'Flag_historico')
	drop table Flag_historico

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

SELECT * FROM Flag_historico

GO

CREATE USER Manager WITHOUT LOGIN;  
CREATE USER Sales1 WITHOUT LOGIN;  
CREATE USER Sales2 WITHOUT LOGIN;  
CREATE USER app WITHOUT LOGIN;  

GO

ALTER AUTHORIZATION ON SCHEMA::[db_owner] TO [Manager]
ALTER AUTHORIZATION ON SCHEMA::[db_owner] TO [app]
ALTER AUTHORIZATION ON SCHEMA::[db_datareader] TO [Sales1]
ALTER AUTHORIZATION ON SCHEMA::[db_datawriter] TO [Sales1]
ALTER AUTHORIZATION ON SCHEMA::[db_datareader] TO [Sales2]
ALTER AUTHORIZATION ON SCHEMA::[db_datawriter] TO [Sales2]

GO

-- criação de uma função com valor de tabela embutida
CREATE FUNCTION Security.fn_securitypredicate(@flag int)  
    RETURNS TABLE  
WITH SCHEMABINDING
AS  -- retorna 1 quando verdadeiro
    RETURN SELECT 1 AS fn_securitypredicate_result
	WHERE @Flag = 1
	OR USER_NAME() IN ('app', 'Manager','sa')
GO

-- criando politica de segurança (RLS) com a função, como predicado
CREATE SECURITY POLICY CustomerFilter  
ADD FILTER PREDICATE Security.fn_securitypredicate(flag)
ON dbo.Customers  
WITH (STATE = ON);

GO

-- concedendo privilégio a função
GRANT SELECT ON security.fn_securitypredicate TO Manager;  
GRANT SELECT ON security.fn_securitypredicate TO Sales1;  
GRANT SELECT ON security.fn_securitypredicate TO Sales2; 
GRANT SELECT ON security.fn_securitypredicate TO app

--Alterando alguns dados para popular a tabela de histor
EXECUTE AS USER = 'app';  
UPDATE dbo.Customers SET flag = 0 WHERE CustomerID = 1
REVERT; 

GO

EXECUTE AS USER = 'app';  
UPDATE dbo.Customers SET flag = 1 WHERE CustomerID = 1
REVERT; 

GO

-- Selecionando os dados com os usuarios (testanto a politica)
EXECUTE AS USER = 'app';  
SELECT * FROM dbo.Customers WHERE CustomerID = 1;
REVERT; 

GO

EXECUTE AS USER = 'Sales1';  
SELECT * FROM dbo.Customers WHERE CustomerID = 1;
REVERT; 

GO

EXECUTE AS USER = 'Manager';  
SELECT * FROM dbo.Customers WHERE CustomerID = 1;
REVERT; 

GO

EXECUTE AS USER = 'Sales2';  
SELECT * FROM dbo.Customers WHERE CustomerID = 1;
REVERT; 

/*
DROP USER Manager;
DROP USER Sales1;
DROP USER Sales2;
DROP USER app;

GO

ALTER SECURITY POLICY CustomerFilter  
WITH (STATE = OFF);  

GO

DROP SECURITY POLICY CustomerFilter;
DROP FUNCTION Security.fn_securitypredicate;
DROP SCHEMA Security;

SELECT uid, name  
from sys.sysusers where uid between 5 and 16383
*/

