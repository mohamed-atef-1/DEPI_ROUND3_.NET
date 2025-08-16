using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace test_1
{
    
    public class Transaction
    {
            public DateTime TransactionDate { get; set; }
            public string Type { get; set; } // Deposit or  Withdrawal or Transfer
            public decimal Amount { get; set; }
            public string Description { get; set; }

            public Transaction(string type, decimal amount, string description)   // constructor 
            {
                TransactionDate = DateTime.Now;
                Type = type;
                Amount = amount;
                Description = description;
            }
       
    }
    

}

