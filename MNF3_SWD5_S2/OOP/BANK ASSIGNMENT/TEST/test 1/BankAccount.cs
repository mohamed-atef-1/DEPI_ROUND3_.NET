using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace test_1
{
    public abstract class BankAccount
    {
        
        
            public string AccountNumber { get; private set; }
            public decimal Balance { get; protected set; }
            public DateTime DateOpened { get; private set; }
            public List<Transaction> TransactionHistory { get; private set; }

            public BankAccount()
            {
                AccountNumber = "ACC" + DateTime.Now.Ticks;
                Balance = 0;
                DateOpened = DateTime.Now;
                TransactionHistory = new List<Transaction>();
            }

            public virtual void Deposit(decimal amount)
            {
                if (amount <= 0) throw new Exception("Deposit amount must be positive.");
                Balance += amount;
                AddTransaction(new Transaction("Deposit", amount, $"Deposit to {AccountNumber}"));
            }

            public virtual void Withdraw(decimal amount)
            {
                if (amount <= 0) throw new Exception("Withdrawal amount must be positive.");
                if (Balance < amount) throw new Exception("no enough funds.");
                Balance -= amount;
                AddTransaction(new Transaction("Withdrawal", amount, $"Withdrawal from {AccountNumber}"));
            }

            public void TransferTo(BankAccount target, decimal amount)
            {
                if (target == null) throw new Exception("Target account not found.");
                Withdraw(amount);
                target.Deposit(amount);
                AddTransaction(new Transaction("Transfer", amount, $"Transfer to {target.AccountNumber}"));
            }

            protected void AddTransaction(Transaction t) => TransactionHistory.Add(t);

            public void ShowTransactions()
            {
                Console.WriteLine($"Transaction history for {AccountNumber}:");
                foreach (var t in TransactionHistory)
                {
                    Console.WriteLine($"{t.TransactionDate} - {t.Type} - {t.Amount:C} - {t.Description}");
                }
            }
       
    }
}
