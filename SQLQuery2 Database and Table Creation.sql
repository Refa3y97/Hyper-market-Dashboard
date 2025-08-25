-- Create the database
CREATE DATABASE Hyper_market;
GO

-- Use the database
USE Hyper_market;
GO

-- Branches Table
CREATE TABLE Branches (
    Branch_ID INT PRIMARY KEY,
    Branch_Name VARCHAR(50),
    Branch_Location VARCHAR(100),
    Branch_PhoneNumber VARCHAR(15)
);

-- Departments Table
CREATE TABLE Departments (
    Dept_ID INT PRIMARY KEY,
    Dept_Name VARCHAR(20)
    -- Manager_ID will be added after Employees table
);

-- Employees Table
CREATE TABLE Employees (
    Emp_ID INT PRIMARY KEY, 
    Emp_FirstName VARCHAR(20),
    Emp_LastName VARCHAR(20),
    Emp_Age DECIMAL(3,0),
    Emp_Gender VARCHAR(1),
    Emp_MaritalStatus VARCHAR(20),
    Emp_PhoneNumber VARCHAR(11),
    Emp_Address VARCHAR(100),
    Emp_HireDate DATE,
    Emp_Salary INT,
    Dept_ID INT,
    Manager_ID INT,
    Branch_ID INT,
    Title VARCHAR(30),  -- changed from Position to Title
    FOREIGN KEY (Dept_ID) REFERENCES Departments(Dept_ID),
    FOREIGN KEY (Manager_ID) REFERENCES Employees(Emp_ID),
    FOREIGN KEY (Branch_ID) REFERENCES Branches(Branch_ID)
);

-- Add Manager_ID to Departments (after Employees exists)
ALTER TABLE Departments
ADD Manager_ID INT FOREIGN KEY REFERENCES Employees(Emp_ID);

-- Customers Table
CREATE TABLE Customers (
    Cust_ID INT PRIMARY KEY,
    Cust_FirstName VARCHAR(20),
    Cust_LastName VARCHAR(20),
    Cust_PhoneNumber VARCHAR(11),
    Cust_Address VARCHAR(100),
    Gender VARCHAR(1),
    Branch_ID INT,
    FOREIGN KEY (Branch_ID) REFERENCES Branches(Branch_ID)
);

-- Orders Table
CREATE TABLE Orders (
    Order_ID INT PRIMARY KEY,
    Order_Date DATE,
    Order_Status VARCHAR(20),
    Order_TotalAmount DECIMAL(10,2),
    Order_Discount DECIMAL(5,2),
    Order_Tax DECIMAL(5,2),
    Order_NetAmount DECIMAL(10,2),
    Order_ShippingAddress VARCHAR(50),
    Cust_ID INT,
    Branch_ID INT,
    FOREIGN KEY (Cust_ID) REFERENCES Customers(Cust_ID),
    FOREIGN KEY (Branch_ID) REFERENCES Branches(Branch_ID)
);


ALTER TABLE Orders DROP COLUMN Order_TotalAmount
ALTER TABLE Orders DROP COLUMN IF EXISTS Order_NetAmount

ALTER TABLE Orders ADD Order_TotalAmount AS (
    SELECT ISNULL(SUM(od.Quantity * p.Price), 0)
    FROM OrderDetails od
    JOIN Products p ON od.Pro_ID = p.Pro_ID
    WHERE od.Order_ID = Orders.Order_ID

);




-- Products Table
CREATE TABLE Products (
    Pro_ID INT PRIMARY KEY,
    Pro_Name VARCHAR(50),
    Pro_UnitPrice DECIMAL(10,2),
    Pro_Brand VARCHAR(20),
    Dept_ID INT,
    FOREIGN KEY (Dept_ID) REFERENCES Departments(Dept_ID)
);

-- OrderDetails Table
CREATE TABLE OrderDetails (
    Pro_ID INT,
    Order_ID INT,
    Quantity INT,
    PRIMARY KEY (Pro_ID, Order_ID),
    FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID),
    FOREIGN KEY (Pro_ID) REFERENCES Products(Pro_ID)
);

-- Payments Table
CREATE TABLE Payments (
    Payment_ID INT PRIMARY KEY,
    Order_ID INT,
    Payment_Method VARCHAR(20), 
    Amount DECIMAL(10,2),
    Payment_Date DATE,
    FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID)
);

-- Returns Table
CREATE TABLE Returns (
    Return_ID INT PRIMARY KEY,
    Order_ID INT,
    Pro_ID INT,
    Return_Date DATE,
    Quantity INT,
    Reason VARCHAR(100),
    FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID),
    FOREIGN KEY (Pro_ID) REFERENCES Products(Pro_ID)
);

-- Stock Table
CREATE TABLE Stock (
    Pro_ID INT,
    Branch_ID INT,
    Quantity INT,
    PRIMARY KEY (Pro_ID, Branch_ID),
    FOREIGN KEY (Pro_ID) REFERENCES Products(Pro_ID),
    FOREIGN KEY (Branch_ID) REFERENCES Branches(Branch_ID)
);



CREATE VIEW vw_OrderTotals AS
SELECT 
    o.Order_ID,
    o.Order_Date,
    o.Order_Status,
    -- Calculate total from order details (Quantity × UnitPrice)
    ISNULL(SUM(od.Quantity * p.Pro_UnitPrice), 0) AS Order_TotalAmount,
    o.Order_Discount,
    o.Order_Tax,
    -- Calculate net amount (total - discount + tax)
    ISNULL(SUM(od.Quantity * p.Pro_UnitPrice), 0) * 
    (1 - ISNULL(o.Order_Discount, 0)/100) + 
    ISNULL(o.Order_Tax, 0) AS Order_NetAmount,
    o.Order_ShippingAddress,
    o.Cust_ID,
    o.Branch_ID
FROM 
    Orders o
LEFT JOIN 
    OrderDetails od ON o.Order_ID = od.Order_ID
LEFT JOIN 
    Products p ON od.Pro_ID = p.Pro_ID
GROUP BY 
    o.Order_ID, 
    o.Order_Date, 
    o.Order_Status, 
    o.Order_Discount,
    o.Order_Tax,
    o.Order_ShippingAddress,
    o.Cust_ID,
    o.Branch_ID;