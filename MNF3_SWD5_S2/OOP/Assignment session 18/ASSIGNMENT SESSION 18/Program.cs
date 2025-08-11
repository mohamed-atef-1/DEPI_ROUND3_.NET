using System;
using System.Collections.Generic;

namespace BankSystem
{
    // Base class
    public class BankAccount
    {
        public const string BankCode = "BNK001";
        public readonly DateTime CreatedDate;
        private int _accountNumber;
        private string _fullName;
        private decimal _balance;

        public int AccountNumber
        {
            get => _accountNumber;
            set => _accountNumber = value;
        }

        public string FullName
        {
            get => _fullName;
            set => _fullName = value;
        }

        public decimal Balance
        {
            get => _balance;
            set => _balance = value;
        }

        public BankAccount(int accountNumber, string fullName, decimal balance)
        {
            CreatedDate = DateTime.Now;
            _accountNumber = accountNumber;
            _fullName = fullName;
            _balance = balance;
        }

        public virtual decimal CalculateInterest()
        {
            return 0;
        }

        public virtual void ShowAccountDetails()
        {
            Console.WriteLine($"Bank Code: {BankCode}");
            Console.WriteLine($"Account Number: {_accountNumber}");
            Console.WriteLine($"Full Name: {_fullName}");
            Console.WriteLine($"Balance: {_balance:C}");
            Console.WriteLine($"Created Date: {CreatedDate}");
        }
    }

    // Derived class: SavingAccount
    public class SavingAccount : BankAccount
    {
        public decimal InterestRate { get; set; }

        public SavingAccount(int accountNumber, string fullName, decimal balance, decimal interestRate)
            : base(accountNumber, fullName, balance)
        {
            InterestRate = interestRate;
        }

        public override decimal CalculateInterest()
        {
            return Balance * InterestRate / 100;
        }

        public override void ShowAccountDetails()
        {
            base.ShowAccountDetails();
            Console.WriteLine($"Interest Rate: {InterestRate}%");
        }
    }

    // Derived class: CurrentAccount
    public class CurrentAccount : BankAccount
    {
        public decimal OverdraftLimit { get; set; }

        public CurrentAccount(int accountNumber, string fullName, decimal balance, decimal overdraftLimit)
            : base(accountNumber, fullName, balance)
        {
            OverdraftLimit = overdraftLimit;
        }

        public override decimal CalculateInterest()
        {
            return 0; // Always 0
        }

        public override void ShowAccountDetails()
        {
            base.ShowAccountDetails();
            Console.WriteLine($"Overdraft Limit: {OverdraftLimit:C}");
        }
    }

    class Program
    {
        static void Main(string[] args)
        {
            // Create objects
            var savingAcc = new SavingAccount(1001, "MOHAMED ATEF", 10000m, 5m);
            var currentAcc = new CurrentAccount(2001, "SARA ATEF", 5000m, 2000m);

            // Add to list
            List<BankAccount> accounts = new List<BankAccount> { savingAcc, currentAcc };

            // Loop & demonstrate polymorphism
            foreach (var account in accounts)
            {
                account.ShowAccountDetails();
                Console.WriteLine($"Calculated Interest: {account.CalculateInterest():C}");
                Console.WriteLine(new string('-', 40));
            }
        }
    }
}
