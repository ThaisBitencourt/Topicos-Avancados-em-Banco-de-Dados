USE Northwind
GO

--Alterando flag de autorização em Customer
EXECUTE AS USER = 'app';  
UPDATE dbo.Customers SET flag = 0 WHERE CustomerID = 1
REVERT; 

GO

-- Selecionando os dados com os usuarios (testanto a politica de segurança)
EXECUTE AS USER = 'app';  
SELECT * FROM dbo.Customers --WHERE CustomerID = 1;
REVERT; 

GO

-- Testando a visualização na tabela People após alteração em Customer
EXECUTE AS USER = 'app';  
SELECT * FROM dbo.People --WHERE CustomerID = 1;
REVERT; 

GO

--Testando RLS na tabela Customer, o usuario 1 não deverá ser mostrado
EXECUTE AS USER = 'sales1';  
SELECT * FROM dbo.Customers --WHERE CustomerID = 1;
REVERT; 

GO

--Testando RLS na tabela People, o usuario 1 não deverá ser mostrado
EXECUTE AS USER = 'sales1';  
SELECT * FROM dbo.People --WHERE CustomerID = 1;
REVERT; 

GO

-- Verificando o histórico de alteração de flag (consentimento de uso dos dados)
SELECT * FROM Flag_historico;

GO

----------------------------------------------------------------------------------------------------------------------------------
-- Testando controle de flags na no relacionamento de Foreing Key na tabela People
----------------------------------------------------------------------------------------------------------------------------------

--Alterando flag de autorização em People na pessoa 10
EXECUTE AS USER = 'app';  
UPDATE dbo.People SET flag_documento = 0 WHERE CustomerID = 10
REVERT; 

GO

-- Selecionando os dados com os usuarios (testanto a politica de segurança) 
EXECUTE AS USER = 'app';  
SELECT * FROM dbo.People --WHERE CustomerID = 10;
REVERT; 

GO

-- Selecionando os dados com os usuarios (testanto a politica de segurança)
EXECUTE AS USER = 'app';  
SELECT * FROM dbo.Customers --WHERE CustomerID = 10;
REVERT; 

GO

--Testando RLS na tabela People, o usuario 10 não deverá ser mostrado
EXECUTE AS USER = 'sales1';  
SELECT * FROM dbo.People --WHERE CustomerID = 10;
REVERT; 

GO

--Testando RLS na tabela Customer, o usuario 10 não deverá ser mostrado
EXECUTE AS USER = 'sales1';  
SELECT * FROM dbo.Customers --WHERE CustomerID = 10;
REVERT; 

GO

-- Verificando o histórico de alteração de flag (consentimento de uso dos dados)
SELECT * FROM Flag_historico;

GO

----------------------------------------------------------------------------------------------------------------------------------
-- Testando politica de segurança na tabela Company 
----------------------------------------------------------------------------------------------------------------------------------
--Alterando flag de autorização em Company
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

-- Verificando o histórico de alteração de flag (consentimento de uso dos dados)
SELECT * FROM Flag_historico;

----------------------------------------------------------------------------------------------------------------------------------
-- Testando politica de segurança na tabela People (emancipação)
----------------------------------------------------------------------------------------------------------------------------------

--O usuario 46 não devera ser visivel pois é menor de idade e não tem documento de emancipação
EXECUTE AS USER = 'sales1';  
SELECT * FROM dbo.People WHERE CustomerID = 46;
REVERT; 

-- setando altorização do responsavel juntamente com validação
EXECUTE AS USER = 'app'; 
UPDATE People SET flag_documento = 1, documento=(
 SELECT BulkColumn FROM OPENROWSET(BULK N'C:\teste.pdf', SINGLE_BLOB) AS Document)
WHERE CustomerID = 46
REVERT; 

GO

-- O usuario após inserção do documento e alteração da flag devera estar visivel na table People
EXECUTE AS USER = 'sales1';  
SELECT * FROM dbo.People WHERE CustomerID = 46;
REVERT; 

GO

-- O usuario após inserção do documento e alteração da flag devera estar visivel na table Customer
EXECUTE AS USER = 'sales1';  
SELECT * FROM dbo.Customers WHERE CustomerID = 46;
REVERT;

GO

-- inserindo um documento de emancipação no entanto sem validação com o campo flag_documento
EXECUTE AS USER = 'app'; 
UPDATE People SET documento=(
 SELECT BulkColumn FROM OPENROWSET(BULK N'C:\teste.pdf', SINGLE_BLOB) AS Document)
WHERE CustomerID = 54
REVERT; 

GO

-- Por mais que um documento de emancipação esteja inserido, não necessariamente foi validado
EXECUTE AS USER = 'sales1';  
SELECT * FROM dbo.People WHERE CustomerID = 54;
REVERT; 

GO

EXECUTE AS USER = 'sales1';  
SELECT * FROM dbo.Customers WHERE CustomerID = 54;
REVERT; 

GO

-- As informações somente serão acessadas por usuarios credenciados (app, admin, sa)
EXECUTE AS USER = 'app';  
SELECT * FROM dbo.People WHERE CustomerID = 54;
REVERT; 

GO

-- Verificando o histórico de alteração de flag (consentimento de uso dos dados)
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

-- Pessoas com documento de emancipação preenchidos  (46, 54)
EXECUTE AS USER = 'app';  
SELECT * FROM Customers c
INNER JOIN People p ON c.CustomerID = p.CustomerID
WHERE YEAR(GETDATE()) - YEAR(BirthDate) < 18
AND p.documento IS NOT NULL
REVERT; 

GO

-- Pessoas com documento de emancipação validos  (46)
EXECUTE AS USER = 'app';  
SELECT * FROM Customers c
INNER JOIN People p ON c.CustomerID = p.CustomerID
WHERE YEAR(GETDATE()) - YEAR(BirthDate) < 18
AND p.documento IS NOT NULL
AND p.flag_documento = 1
REVERT; 

GO

/*
--desabilitar politica de segurança
ALTER SECURITY POLICY CustomerFilter  
WITH (STATE = OFF);  

GO

DROP SECURITY POLICY CustomerFilter;
DROP FUNCTION Security.fn_securitypredicate;
DROP SCHEMA Security;
*/



