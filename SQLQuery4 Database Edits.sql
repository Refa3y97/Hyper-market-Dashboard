



select *
from Products
where Pro_Name LIKE '%Dettol%'



update Products
set Pro_Name = 'Dettol Cleaner'
where Pro_ID = 66




select *
from Products
where category = 'entertainment'


update OrderDetails
set Quantity= 50
where Order_ID = 12

select *
from OrderDetails
where Pro_ID between 121 and 140 or Pro_ID between 161 and 180



update OrderDetails
set Quantity= 20
where Pro_ID between 21 and 40 or Pro_ID between 81 and 100



select *
from Products
where Pro_Name LIKE '%toothpaste%'


update Products
set Pro_Name = 'Parodontax Toothpaste'
where Pro_ID = 98


select *
from Departments



ALTER TABLE Products ADD Category VARCHAR(50);

UPDATE Products SET Category = 
  CASE 
    WHEN Dept_ID = (SELECT Dept_ID FROM Departments WHERE Dept_Name = 'Grocery') 
      THEN 'Food'
    WHEN Dept_ID IN (
      SELECT Dept_ID FROM Departments 
      WHERE Dept_Name IN ('Household', 'Furniture', 'Tools')
    ) THEN 'Home & Living'
    WHEN Dept_ID IN (
      SELECT Dept_ID FROM Departments 
      WHERE Dept_Name IN ('Health and Beauty', 'Clothes')
    ) THEN 'Personal Care'
    WHEN Dept_ID = (SELECT Dept_ID FROM Departments WHERE Dept_Name = 'Electronics') 
      THEN 'Electronics'
    WHEN Dept_ID IN (
      SELECT Dept_ID FROM Departments 
      WHERE Dept_Name IN ('Toys', 'Books')
    ) THEN 'Entertainment'
  END;




-- METHOD 1: Using a temporary table (most reliable)

-- Step 1: Create temp table with row numbers
SELECT 
    Order_ID,
    ROW_NUMBER() OVER (ORDER BY Order_ID) AS RowNum
INTO #OrderNumbers
FROM Orders;

-- Step 2: Update orders with precise date distribution
UPDATE o
SET Order_Date = 
    CASE
        -- 2022 (10 orders): 1/month for Mar-Dec (months 3-12)
        WHEN onum.RowNum <= 10 THEN 
            DATEADD(month, 2 + (onum.RowNum-1), '2022-01-01')
        
        -- 2023 (20 orders): 1 for Jan/Feb, 0 Mar, 3 for Apr-Dec
        WHEN onum.RowNum <= 30 THEN 
            CASE
                WHEN onum.RowNum <= 12 THEN -- First 2 orders go to Jan/Feb
                    CASE WHEN onum.RowNum = 11 THEN '2023-01-01'
                         WHEN onum.RowNum = 12 THEN '2023-02-01'
                    END
                ELSE -- Remaining 18 orders: 3/month for Apr-Dec
                    DATEADD(month, 3 + FLOOR((onum.RowNum-13)/3), '2023-01-01')
            END
        
        -- 2024 (30 orders): 3 for Jan-Mar/May-Aug, 2 for others
        WHEN onum.RowNum <= 60 THEN 
            CASE
                WHEN onum.RowNum <= 45 THEN -- 15 orders for Jan-Mar (3/month)
                    DATEADD(month, FLOOR((onum.RowNum-31)/5), '2024-01-01')
                ELSE -- 15 orders for May-Aug (3/month)
                    DATEADD(month, 4 + FLOOR((onum.RowNum-46)/5), '2024-01-01')
            END
        
        -- 2025 (40 orders): 3/month except May-Aug (4/month)
        ELSE 
            CASE
                WHEN onum.RowNum <= 96 THEN -- 36 orders (3/month)
                    DATEADD(month, FLOOR((onum.RowNum-61)/3), '2025-01-01')
                ELSE -- 4 extra orders for May-Aug
                    DATEADD(month, 4 + (onum.RowNum-97), '2025-01-01')
            END
    END
FROM Orders o
JOIN #OrderNumbers onum ON o.Order_ID = onum.Order_ID;

-- Add random days to dates
UPDATE Orders
SET Order_Date = DATEADD(day, ABS(CHECKSUM(NEWID())) % 28, Order_Date)
WHERE Order_Date IS NOT NULL;

-- Clean up
DROP TABLE #OrderNumbers;

-- Verification
SELECT 
    YEAR(Order_Date) AS Year,
    MONTH(Order_Date) AS Month,
    COUNT(*) AS Orders
FROM Orders
GROUP BY YEAR(Order_Date), MONTH(Order_Date)
ORDER BY Year, Month;



select*
from Departments

ALTER TABLE Customers 
drop FK__Customers__Branc__412EB0B6
DROP COLUMN branch_id;



select * 
from Payments


update Payments 
set Payment_Method = 'Visa'
where Payment_Method = 'Credit Card'



delete from Branches
where Branch_ID between 11 and 20



UPDATE Employees
SET Emp_Gender = 'Male'
WHERE Emp_Gender = 'male';