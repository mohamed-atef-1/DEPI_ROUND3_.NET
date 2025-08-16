using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace test_1
{
    public class SavingsAccount : BankAccount
    {
            public decimal InterestRate { get; set; }

            public SavingsAccount(decimal interestRate)
            {
                InterestRate = interestRate;
            }

            public decimal CalculateMonthlyInterest() => Balance * (InterestRate / 12);
    }
}
