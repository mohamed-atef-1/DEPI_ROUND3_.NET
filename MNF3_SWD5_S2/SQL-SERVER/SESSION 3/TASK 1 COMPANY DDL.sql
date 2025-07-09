
--create database company_db

-- Create Departments table
CREATE TABLE Department (
    Dnum INT PRIMARY KEY,
    Dname VARCHAR(100)
);

-- Create Employees table
CREATE TABLE Employees (
    SSN INT PRIMARY KEY,
    Fname VARCHAR(50),
    Lname VARCHAR(50),
    Gender CHAR(1),
    Birth_Of_Date DATE,
    Dnum INT FOREIGN KEY REFERENCES Department(Dnum),
    Supervise_SSN INT NULL,
    FOREIGN KEY (Supervise_SSN) REFERENCES Employees(SSN)
);

-- Create Projects table
CREATE TABLE Projects (
    PNumber INT PRIMARY KEY,
    Pname VARCHAR(100),
    Location VARCHAR(100),
    City VARCHAR(100),
    Dnum INT FOREIGN KEY REFERENCES Department(Dnum)
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
    Dnum INT FOREIGN KEY REFERENCES Department(Dnum),
    Location VARCHAR(100),
    PRIMARY KEY (Dnum, Location)
);

-- add not null 
ALTER TABLE Employees
ALTER COLUMN Fname VARCHAR(50) NOT NULL;

ALTER TABLE Employees
ALTER COLUMN Lname VARCHAR(50) NOT NULL;

ALTER TABLE Employees
ALTER COLUMN Gender CHAR(1) NOT NULL;

ALTER TABLE Department
ALTER COLUMN Dname VARCHAR(100) NOT NULL;


--add check 
ALTER TABLE Employees
ADD CONSTRAINT CHK_Employee_Gender CHECK (Gender IN ('M', 'F'));

ALTER TABLE Dependents
ADD CONSTRAINT CHK_Dependent_Gender CHECK (Gender IN ('M', 'F'));


--add default values
ALTER TABLE Employees
ADD CONSTRAINT DF_Gender DEFAULT 'M' FOR Gender;

ALTER TABLE Work_On
ADD CONSTRAINT DF_WorkingHours DEFAULT 0 FOR Number_of_Working_Hours;

--add unique
ALTER TABLE Projects
ADD CONSTRAINT UQ_ProjectName UNIQUE (Pname);

-- add columns
ALTER TABLE Department
ADD  SSN INT FOREIGN KEY REFERENCES  Employees(SSN),
     HIRING_DATE DATE ;





