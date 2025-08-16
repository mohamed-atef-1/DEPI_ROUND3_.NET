using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace test_1
{
    public class Customer
    {
        public Guid CustomerId { get; private set; }
        public string FullName { get; private set; }
        public string NationalId { get; private set; }
        public DateTime DateOfBirth { get; private set; }
        public List<BankAccount> Accounts { get; private set; }

        public Customer(string fullName, string nationalId, DateTime dob)
        {
            CustomerId = Guid.NewGuid();
            FullName = fullName;
            NationalId = nationalId;
            DateOfBirth = dob;
            Accounts = new List<BankAccount>();
        }

        public void UpdateDetails(string name, DateTime dob)
        {
            FullName = name;
            DateOfBirth = dob;
        }

        public decimal GetTotalBalance() => Accounts.Sum(a => a.Balance);

        public void AddAccount(BankAccount account) => Accounts.Add(account);

        public bool CanBeRemoved() => Accounts.All(a => a.Balance == 0);
    }

}
