using System;
using System.Collections.Generic;

namespace BankSystemApp
{
    // ==============================
    // Transaction Class
    // ==============================
    public class Transaction
    {
        public DateTime Date { get; set; }
        public string Type { get; set; }
        public decimal Amount { get; set; }
        public string Description { get; set; }

        public Transaction(string type, decimal amount, string description)
        {
            Date = DateTime.Now;
            Type = type;
            Amount = amount;
            Description = description;
        }

        public override string ToString()
        {
            return $"{Date} | {Type} | {Amount:C} | {Description}";
        }
    }

    // ==============================
    // Account Base Class
    // ==============================
    public abstract class Account
    {
        private static int _accountSeed = 1000;
        public int AccountNumber { get; }
        public decimal Balance { get; protected set; }
        public DateTime DateOpened { get; }
        public List<Transaction> Transactions { get; }

        protected Account()
        {
            AccountNumber = ++_accountSeed;
            DateOpened = DateTime.Now;
            Balance = 0;
            Transactions = new List<Transaction>();
        }

        public virtual void Deposit(decimal amount)
        {
            if (amount <= 0) throw new Exception("Amount must be positive.");
            Balance += amount;
            Transactions.Add(new Transaction("Deposit", amount, $"Deposited {amount:C}"));
        }

        public virtual void Withdraw(decimal amount)
        {
            if (amount <= 0) throw new Exception("Amount must be positive.");
            if (Balance < amount) throw new Exception("Insufficient balance.");
            Balance -= amount;
            Transactions.Add(new Transaction("Withdraw", amount, $"Withdrew {amount:C}"));
        }

        public void TransferTo(Account target, decimal amount)
        {
            if (target == null) throw new Exception("Target account not found.");
            this.Withdraw(amount);
            target.Deposit(amount);
            Transactions.Add(new Transaction("Transfer", amount, $"Transfer to Acc {target.AccountNumber}"));
        }

        public abstract decimal CalculateMonthlyBenefit();
    }

    // ==============================
    // SavingsAccount Class
    // ==============================
    public class SavingsAccount : Account
    {
        public decimal InterestRate { get; set; }
        public SavingsAccount(decimal interestRate)
        {
            InterestRate = interestRate;
        }

        public override decimal CalculateMonthlyBenefit()
        {
            return Balance * (InterestRate / 100 / 12);
        }
    }

    // ==============================
    // CurrentAccount Class
    // ==============================
    public class CurrentAccount : Account
    {
        public decimal OverdraftLimit { get; set; }
        public CurrentAccount(decimal overdraftLimit)
        {
            OverdraftLimit = overdraftLimit;
        }

        public override void Withdraw(decimal amount)
        {
            if (amount <= 0) throw new Exception("Amount must be positive.");
            if (Balance + OverdraftLimit < amount) throw new Exception("Exceeds overdraft limit.");
            Balance -= amount;
            Transactions.Add(new Transaction("Withdraw", amount, $"Withdrew {amount:C}"));
        }

        public override decimal CalculateMonthlyBenefit() => 0;
    }

    // ==============================
    // Customer Class
    // ==============================
    public class Customer
    {
        private static int _idSeed = 0;
        public int CustomerId { get; }
        public string FullName { get; set; }
        public string NationalId { get; }
        public DateTime DateOfBirth { get; set; }
        public List<Account> Accounts { get; }

        public Customer(string fullName, string nationalId, DateTime dob)
        {
            CustomerId = ++_idSeed;
            FullName = fullName;
            NationalId = nationalId;
            DateOfBirth = dob;
            Accounts = new List<Account>();
        }

        public decimal TotalBalance()
        {
            decimal total = 0;
            foreach (var acc in Accounts) total += acc.Balance;
            return total;
        }

        public override string ToString()
        {
            return $"[{CustomerId}] {FullName} | NID: {NationalId} | DOB: {DateOfBirth:d} | Accounts: {Accounts.Count}";
        }
    }

    // ==============================
    // Bank Class
    // ==============================
    public class Bank
    {
        public string Name { get; }
        public string BranchCode { get; }
        public List<Customer> Customers { get; }

        public Bank(string name, string branchCode)
        {
            Name = name;
            BranchCode = branchCode;
            Customers = new List<Customer>();
        }

        public Customer FindCustomerById(int id) => Customers.Find(c => c.CustomerId == id);
        public Customer FindCustomerByNID(string nid) => Customers.Find(c => c.NationalId == nid);
        public Account FindAccount(int accNum)
        {
            foreach (var c in Customers)
                foreach (var a in c.Accounts)
                    if (a.AccountNumber == accNum) return a;
            return null;
        }

        public void PrintReport()
        {
            Console.WriteLine($"\n--- Bank Report: {Name} ({BranchCode}) ---");
            foreach (var c in Customers)
            {
                Console.WriteLine(c);
                foreach (var a in c.Accounts)
                {
                    Console.WriteLine($"   - Acc {a.AccountNumber} | Balance: {a.Balance:C} | Opened: {a.DateOpened:d}");
                }
                Console.WriteLine($"   Total Balance: {c.TotalBalance():C}\n");
            }
        }
    }

    // ==============================
    // Program (Main Menu)
    // ==============================
    public class Program
    {
        public static void Main(string[] args)
        {
            Console.Write("Enter Bank Name: ");
            string bankName = Console.ReadLine();
            Console.Write("Enter Branch Code: ");
            string branchCode = Console.ReadLine();

            Bank bank = new Bank(bankName, branchCode);

            while (true)
            {
                Console.WriteLine("\n--- Bank System Menu ---");
                Console.WriteLine("1. Add Customer");
                Console.WriteLine("2. Update Customer");
                Console.WriteLine("3. Remove Customer");
                Console.WriteLine("4. Search Customer");
                Console.WriteLine("5. Open Account");
                Console.WriteLine("6. Deposit");
                Console.WriteLine("7. Withdraw");
                Console.WriteLine("8. Transfer");
                Console.WriteLine("9. Customer Total Balance");
                Console.WriteLine("10. Bank Report");
                Console.WriteLine("11. Show Transactions for Account");
                Console.WriteLine("0. Exit");
                Console.Write("Choose: ");
                string choice = Console.ReadLine();

                try
                {
                    switch (choice)
                    {
                        case "1":
                            Console.Write("Name: "); string name = Console.ReadLine();
                            Console.Write("National ID: "); string nid = Console.ReadLine();
                            Console.Write("DOB (yyyy-mm-dd): "); DateTime dob = DateTime.Parse(Console.ReadLine());
                            bank.Customers.Add(new Customer(name, nid, dob));
                            Console.WriteLine("Customer added.");
                            break;

                        case "2":
                            Console.Write("Customer ID: "); int cid = int.Parse(Console.ReadLine());
                            var cust = bank.FindCustomerById(cid);
                            if (cust != null)
                            {
                                Console.Write("New Name: "); cust.FullName = Console.ReadLine();
                                Console.Write("New DOB (yyyy-mm-dd): "); cust.DateOfBirth = DateTime.Parse(Console.ReadLine());
                                Console.WriteLine("Updated.");
                            }
                            else Console.WriteLine("Not found.");
                            break;

                        case "3":
                            Console.Write("Customer ID: "); cid = int.Parse(Console.ReadLine());
                            cust = bank.FindCustomerById(cid);
                            if (cust != null && cust.TotalBalance() == 0)
                            {
                                bank.Customers.Remove(cust);
                                Console.WriteLine("Customer removed.");
                            }
                            else Console.WriteLine("Cannot remove (nonzero balance or not found).");
                            break;

                        case "4":
                            Console.Write("Enter National ID: "); nid = Console.ReadLine();
                            cust = bank.FindCustomerByNID(nid);
                            Console.WriteLine(cust != null ? cust.ToString() : "Not found.");
                            break;

                        case "5":
                            Console.Write("Customer ID: "); cid = int.Parse(Console.ReadLine());
                            cust = bank.FindCustomerById(cid);
                            if (cust != null)
                            {
                                Console.Write("1-Savings  2-Current: ");
                                string t = Console.ReadLine();
                                if (t == "1")
                                {
                                    Console.Write("Interest rate: ");
                                    decimal ir = decimal.Parse(Console.ReadLine());
                                    cust.Accounts.Add(new SavingsAccount(ir));
                                }
                                else
                                {
                                    Console.Write("Overdraft: ");
                                    decimal od = decimal.Parse(Console.ReadLine());
                                    cust.Accounts.Add(new CurrentAccount(od));
                                }
                                Console.WriteLine("Account created.");
                            }
                            break;

                        case "6":
                            Console.Write("Acc Num: "); int accNum = int.Parse(Console.ReadLine());
                            Console.Write("Amount: "); decimal amt = decimal.Parse(Console.ReadLine());
                            var acc = bank.FindAccount(accNum);
                            acc?.Deposit(amt);
                            Console.WriteLine("Deposited.");
                            break;

                        case "7":
                            Console.Write("Acc Num: "); accNum = int.Parse(Console.ReadLine());
                            Console.Write("Amount: "); amt = decimal.Parse(Console.ReadLine());
                            acc = bank.FindAccount(accNum);
                            acc?.Withdraw(amt);
                            Console.WriteLine("Withdrawn.");
                            break;

                        case "8":
                            Console.Write("From Acc: "); int from = int.Parse(Console.ReadLine());
                            Console.Write("To Acc: "); int to = int.Parse(Console.ReadLine());
                            Console.Write("Amount: "); amt = decimal.Parse(Console.ReadLine());
                            var a1 = bank.FindAccount(from);
                            var a2 = bank.FindAccount(to);
                            a1?.TransferTo(a2, amt);
                            Console.WriteLine("Transferred.");
                            break;

                        case "9":
                            Console.Write("Customer ID: "); cid = int.Parse(Console.ReadLine());
                            cust = bank.FindCustomerById(cid);
                            if (cust != null) Console.WriteLine($"Total Balance: {cust.TotalBalance():C}");
                            break;

                        case "10":
                            bank.PrintReport();
                            break;

                        case "11":
                            Console.Write("Enter Account Number: ");
                            accNum = int.Parse(Console.ReadLine());
                            acc = bank.FindAccount(accNum);
                            if (acc != null)
                            {
                                Console.WriteLine($"--- Transactions for Account {acc.AccountNumber} ---");
                                foreach (var t in acc.Transactions)
                                    Console.WriteLine(t);
                            }
                            else Console.WriteLine("Account not found.");
                            break;

                        case "0":
                            return;

                        default:
                            Console.WriteLine("Invalid choice.");
                            break;
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error: {ex.Message}");
                }
            }
        }
    }
}
