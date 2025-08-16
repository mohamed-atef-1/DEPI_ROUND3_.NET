using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace test_1
{
    public class CurrentAccount : BankAccount
    {
            public decimal OverdraftLimit { get; set; }

            public CurrentAccount(decimal overdraftLimit) 
            {
                OverdraftLimit = overdraftLimit;
            }

            public override void Withdraw(decimal amount)
            {
                if (amount <= 0) throw new Exception("Withdrawal amount must be positive.");
                if (Balance + OverdraftLimit < amount) throw new Exception("Overdraft limit exceeded.");
                Balance -= amount;
                AddTransaction(new Transaction("Withdrawal", amount, $"Withdrawal from {AccountNumber} (Overdraft allowed)"));
            }
        
    }
}
