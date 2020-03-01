-- this is a comment

SELECT * FROM tuna_t; -- tuna comments
SELECT col1, col2 FROM tuna_t;

/*
block comments
*/

--
-- empty comment

		  SELECT * FROM tuna_t;

	 

-- this weird spaces is to count lines and cols of the file

SELECT DISTINCT Country FROM Customers;
SELECT COUNT(DISTINCT Country) FROM Customers;

SELECT Count(*) AS DistinctCountries
FROM (SELECT DISTINCT Country FROM Customers);

SELECT * FROM Customers
WHERE Country='Mexico';

SELECT * FROM Customers
WHERE CustomerID=1;

SELECT * FROM Customers
WHERE Country='Germany' AND City='Berlin';

SELECT * FROM Customers
WHERE City='Berlin' OR City='München';

SELECT * FROM Customers
WHERE NOT Country='Germany';

-- Mixed logical operators
SELECT * FROM Customers
WHERE Country='Germany' AND (City='Berlin' OR City='München');

-- Mixed logical operators (with NOT)
SELECT * FROM Customers
WHERE NOT Country='Germany' AND NOT Country='USA';

-- ORDER BY 1
SELECT * FROM Customers
ORDER BY Country;

-- ORDER BY 2 (with DESC)
SELECT * FROM Customers
ORDER BY Country DESC;

-- ORDER BY Several Columns 1
SELECT * FROM Customers
ORDER BY Country, CustomerName;

-- ORDER BY Several Columns 2
SELECT * FROM Customers
ORDER BY Country ASC, CustomerName DESC;

-- INSERT INTO
INSERT INTO Customers (CustomerName, ContactName, Address, City, PostalCode, Country)
VALUES ('Cardinal', 'Tom B. Erichsen', 'Skagen 21', 'Stavanger', '4006', 'Norway');

-- IS NULL
SELECT CustomerName, ContactName, Address
FROM Customers
WHERE Address IS NULL;

-- IS NOT NULL
SELECT CustomerName, ContactName, Address
FROM Customers
WHERE Address IS NOT NULL;

-- UPDATE
UPDATE Customers
SET ContactName = 'Alfred Schmidt', City= 'Frankfurt'
WHERE CustomerID = 1;

-- UPDATE without WHERE (update all)
UPDATE Customers
SET ContactName='Juan';

-- DELETE
DELETE FROM Customers WHERE CustomerName='Alfreds Futterkiste';

-- DELETE all
DELETE FROM Customers;