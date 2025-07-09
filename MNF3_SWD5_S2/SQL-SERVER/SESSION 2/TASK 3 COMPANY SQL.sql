

-- Create Departments table
CREATE TABLE Departments (
    Dnum INT PRIMARY KEY,
    Dname VARCHAR(100)
);

ALTER TABLE Departments
ADD  SSN INT FOREIGN KEY REFERENCES  Employees(SSN),
     HIRING_DATE DATE ;

-- Create Employees table
CREATE TABLE Employees (
    SSN INT PRIMARY KEY,
    Fname VARCHAR(50),
    Lname VARCHAR(50),
    Gender CHAR(1),
    Birth_Of_Date DATE,
    Dnum INT FOREIGN KEY REFERENCES Departments(Dnum),
    Supervise_SSN INT NULL,
    FOREIGN KEY (Supervise_SSN) REFERENCES Employees(SSN)
);

-- Create Projects table
CREATE TABLE Projects (
    PNumber INT PRIMARY KEY,
    Pname VARCHAR(100),
    Location VARCHAR(100),
    City VARCHAR(100),
    Dnum INT FOREIGN KEY REFERENCES Departments(Dnum)
);

-- Create Work_On table (relationship between Employees and Projects)
CREATE TABLE Work_On (
    SSN INT FOREIGN KEY REFERENCES Employees(SSN),
    PNumber INT FOREIGN KEY REFERENCES Projects(PNumber),
    Number_of_Working_Hours FLOAT,
    PRIMARY KEY (SSN, PNumber)
);

-- Create Dependents table
CREATE TABLE Dependents (
    Dependent_Name VARCHAR(100),
    SSN INT ,
    Gender CHAR(1),
    Birthdate DATE,
    PRIMARY KEY (Dependent_Name, SSN),
	FOREIGN KEY (SSN) REFERENCES Employees(SSN) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Create Departments_Locations table (multi-valued locations for departments)
CREATE TABLE Departments_Locations (
    Dnum INT FOREIGN KEY REFERENCES Departments(Dnum),
    Location VARCHAR(100),
    PRIMARY KEY (Dnum, Location)
);

---------------------------------------------------------------------------------------------------
--Insert sample data into EMPLOYEE table (at least 5 employees)
INSERT INTO EmployeeS (SSN, Fname, Lname, Gender, Birth_Of_Date, Dnum, Supervise_SSN)
VALUES 
(1001, 'Ali', 'Ahmed', 'M', '1990-01-01', 1, NULL),
(1002, 'Sara', 'Ibrahim', 'F', '1992-05-03', 2, 1001),
(1003, 'Youssef', 'Hassan', 'M', '1988-11-15', 2, 1001),
(1004, 'Nora', 'Fahmy', 'F', '1995-07-20', 3, 1002),
(1005, 'Omar', 'Tarek', 'M', '1985-03-30', 1, 1001);


--Insert sample data into DEPARTMENT table (at least 3 departments)
INSERT INTO Departments (Dnum, Dname)
VALUES 
(1, 'Human Resources'),
(2, 'IT'),
(3, 'Finance');

--Update an employee's department
UPDATE Employees
SET Dnum = 3
WHERE SSN = 1003;


--Delete a dependent record
-- Insert dependents for employees
INSERT INTO Dependents (Dependent_Name, SSN, Gender, Birthdate)
VALUES 
('Lina', 1001, 'F', '2015-06-12'),
('Mona', 1002, 'F', '2018-09-25'),
('Omar Jr.', 1005, 'M', '2020-02-10');

-- Delete one dependent (example: Mona)
DELETE FROM Dependents
WHERE Dependent_Name = 'Mona' AND SSN = 1002;


--Retrieve all employees working in a specific department
SELECT *
FROM Employees
WHERE Dnum = (
    SELECT Dnum FROM Departments WHERE Dname = 'Finance'
);


--Find all employees and their project assignments with working hours
-- Insert projects
INSERT INTO Projects (PNumber, Pname, Location, City, Dnum)
VALUES
(201, 'HR System', 'Cairo', 'Cairo', 1),
(202, 'Finance Tracker', 'Alexandria', 'Alex', 3),
(203, 'Intranet Setup', 'Cairo', 'Cairo', 2);

-- Insert work assignments
INSERT INTO Work_On (SSN, PNumber, Number_of_Working_Hours)
VALUES 
(1001, 201, 20),
(1002, 203, 35),
(1003, 202, 25),
(1004, 203, 30),
(1005, 201, 15);

--Find all employees and their project assignments with working hours
SELECT 
    E.Fname + ' ' + E.Lname AS EmployeeName,
    P.Pname AS ProjectName,
    W.Number_of_Working_Hours
FROM 
    Employees E
JOIN 
    Work_On W ON E.SSN = W.SSN
JOIN 
    Projects P ON P.PNumber = W.PNumber;
