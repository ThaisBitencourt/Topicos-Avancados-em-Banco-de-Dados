USE Northwind
GO

--Alterando flag de autoriza��o em Customer
EXECUTE AS USER = 'app';  
UPDATE dbo.Customers SET flag = 0 WHERE CustomerID = 1
REVERT; 

GO

-- Selecionando os dados com os usuarios (testanto a politica de seguran�a)
EXECUTE AS USER = 'app';  
SELECT * FROM dbo.Customers --WHERE CustomerID = 1;
REVERT; 

GO

-- Testando a visualiza��o na tabela People ap�s altera��o em Customer
EXECUTE AS USER = 'app';  
SELECT * FROM dbo.People --WHERE CustomerID = 1;
REVERT; 

GO

--Testando RLS na tabela Customer, o usuario 1 n�o dever� ser mostrado
EXECUTE AS USER = 'sales1';  
SELECT * FROM dbo.Customers --WHERE CustomerID = 1;
REVERT; 

GO

--Testando RLS na tabela People, o usuario 1 n�o dever� ser mostrado
EXECUTE AS USER = 'sales1';  
SELECT * FROM dbo.People --WHERE CustomerID = 1;
REVERT; 

GO

-- Verificando o hist�rico de altera��o de flag (consentimento de uso dos dados)
SELECT * FROM Flag_historico;

GO

----------------------------------------------------------------------------------------------------------------------------------
-- Testando controle de flags na no relacionamento de Foreing Key na tabela People
----------------------------------------------------------------------------------------------------------------------------------

--Alterando flag de autoriza��o em People na pessoa 10
EXECUTE AS USER = 'app';  
UPDATE dbo.People SET flag_documento = 0 WHERE CustomerID = 10
REVERT; 

GO

-- Selecionando os dados com os usuarios (testanto a politica de seguran�a) 
EXECUTE AS USER = 'app';  
SELECT * FROM dbo.People --WHERE CustomerID = 10;
REVERT; 

GO

-- Selecionando os dados com os usuarios (testanto a politica de seguran�a)
EXECUTE AS USER = 'app';  
SELECT * FROM dbo.Customers --WHERE CustomerID = 10;
REVERT; 

GO

--Testando RLS na tabela People, o usuario 10 n�o dever� ser mostrado
EXECUTE AS USER = 'sales1';  
SELECT * FROM dbo.People --WHERE CustomerID = 10;
REVERT; 

GO

--Testando RLS na tabela Customer, o usuario 10 n�o dever� ser mostrado
EXECUTE AS USER = 'sales1';  
SELECT * FROM dbo.Customers --WHERE CustomerID = 10;
REVERT; 

GO

-- Verificando o hist�rico de altera��o de flag (consentimento de uso dos dados)
SELECT * FROM Flag_historico;

GO

----------------------------------------------------------------------------------------------------------------------------------
-- Testando politica de seguran�a na tabela Company 
----------------------------------------------------------------------------------------------------------------------------------
--Alterando flag de autoriza��o em Company
EXECUTE AS USER = 'app';  
UPDATE Company SET flag = 0 WHERE CustomerID = 71;
REVERT; 

GO

EXECUTE AS USER = 'app';  
SELECT * FROM dbo.Company --WHERE CustomerID = 71;
REVERT; 

GO

EXECUTE AS USER = 'app';  
SELECT * FROM Customers --WHERE CustomerID = 71;
REVERT; 

GO

EXECUTE AS USER = 'sales1';  
SELECT * FROM Customers --WHERE CustomerID = 71;
REVERT; 

GO

EXECUTE AS USER = 'sales1';  
SELECT * FROM Company --WHERE CustomerID = 71;
REVERT; 

-- Verificando o hist�rico de altera��o de flag (consentimento de uso dos dados)
SELECT * FROM Flag_historico;

----------------------------------------------------------------------------------------------------------------------------------
-- Testando politica de seguran�a na tabela People (emancipa��o)
----------------------------------------------------------------------------------------------------------------------------------

--O usuario 46 n�o devera ser visivel pois � menor de idade e n�o tem documento de emancipa��o
EXECUTE AS USER = 'sales1';  
SELECT * FROM dbo.People WHERE CustomerID = 46;
REVERT; 

-- setando altoriza��o do responsavel juntamente com valida��o
EXECUTE AS USER = 'app'; 
UPDATE People SET flag_documento = 1, documento=(
 SELECT BulkColumn FROM OPENROWSET(BULK N'C:\teste.pdf', SINGLE_BLOB) AS Document)
WHERE CustomerID = 46
REVERT; 

GO

-- O usuario ap�s inser��o do documento e altera��o da flag devera estar visivel na table People
EXECUTE AS USER = 'sales1';  
SELECT * FROM dbo.People WHERE CustomerID = 46;
REVERT; 

GO

-- O usuario ap�s inser��o do documento e altera��o da flag devera estar visivel na table Customer
EXECUTE AS USER = 'sales1';  
SELECT * FROM dbo.Customers WHERE CustomerID = 46;
REVERT;

GO

-- inserindo um documento de emancipa��o no entanto sem valida��o com o campo flag_documento
EXECUTE AS USER = 'app'; 
UPDATE People SET documento=(
 SELECT BulkColumn FROM OPENROWSET(BULK N'C:\teste.pdf', SINGLE_BLOB) AS Document)
WHERE CustomerID = 54
REVERT; 

GO

-- Por mais que um documento de emancipa��o esteja inserido, n�o necessariamente foi validado
EXECUTE AS USER = 'sales1';  
SELECT * FROM dbo.People WHERE CustomerID = 54;
REVERT; 

GO

EXECUTE AS USER = 'sales1';  
SELECT * FROM dbo.Customers WHERE CustomerID = 54;
REVERT; 

GO

-- As informa��es somente ser�o acessadas por usuarios credenciados (app, admin, sa)
EXECUTE AS USER = 'app';  
SELECT * FROM dbo.People WHERE CustomerID = 54;
REVERT; 

GO

-- Verificando o hist�rico de altera��o de flag (consentimento de uso dos dados)
SELECT * FROM Flag_historico;

----------------------------------------------------------------------------------------------------------------------------------
-- Pessoas menores de idade no banco
----------------------------------------------------------------------------------------------------------------------------------
GO

--Todas pessoas menores de idade (40, 46, 51, 54)
EXECUTE AS USER = 'app';  
SELECT * FROM Customers c
INNER JOIN People p
ON c.CustomerID = p.CustomerID
WHERE YEAR(GETDATE()) - YEAR(BirthDate) < 18
REVERT; 

GO

-- Pessoas com documento de emancipa��o preenchidos  (46, 54)
EXECUTE AS USER = 'app';  
SELECT * FROM Customers c
INNER JOIN People p ON c.CustomerID = p.CustomerID
WHERE YEAR(GETDATE()) - YEAR(BirthDate) < 18
AND p.documento IS NOT NULL
REVERT; 

GO

-- Pessoas com documento de emancipa��o validos  (46)
EXECUTE AS USER = 'app';  
SELECT * FROM Customers c
INNER JOIN People p ON c.CustomerID = p.CustomerID
WHERE YEAR(GETDATE()) - YEAR(BirthDate) < 18
AND p.documento IS NOT NULL
AND p.flag_documento = 1
REVERT; 

GO

/*
--desabilitar politica de seguran�a
ALTER SECURITY POLICY CustomerFilter  
WITH (STATE = OFF);  

GO

DROP SECURITY POLICY CustomerFilter;
DROP FUNCTION Security.fn_securitypredicate;
DROP SCHEMA Security;
*/



