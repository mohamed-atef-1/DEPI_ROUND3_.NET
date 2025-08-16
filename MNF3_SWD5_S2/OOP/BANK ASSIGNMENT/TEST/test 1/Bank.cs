using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace test_1
{
    public class Bank
    {
        public string Name { get; private set; }
        public string BranchCode { get; private set; }
        public List<Customer> Customers { get; private set; }

        public Bank(string name, string branchCode)
        {
            Name = name;
            BranchCode = branchCode;
            Customers = new List<Customer>();
        }

        public void AddCustomer(Customer c) => Customers.Add(c);

        public Customer FindCustomerByName(string name) =>
            Customers.FirstOrDefault(c => c.FullName.Equals(name, StringComparison.OrdinalIgnoreCase));

        public Customer FindCustomerByNationalId(string nid) =>
            Customers.FirstOrDefault(c => c.NationalId == nid);

        public void RemoveCustomer(Guid customerId)
        {
            var customer = Customers.FirstOrDefault(c => c.CustomerId == customerId);
            if (customer != null && customer.CanBeRemoved())
                Customers.Remove(customer);
            else
                throw new Exception("Cannot remove customer. Accounts must have zero balance.");
        }

        public void GetBankReport()
        {
            Console.WriteLine($"Bank: {Name} - Branch: {BranchCode}");
            foreach (var c in Customers)
            {
                Console.WriteLine($"Customer: {c.FullName} (ID: {c.CustomerId})");
                foreach (var acc in c.Accounts)
                {
                    Console.WriteLine($"  Account: {acc.AccountNumber} | Balance: {acc.Balance:C}");
                }
                Console.WriteLine($"Total Balance: {c.GetTotalBalance():C}");
                Console.WriteLine();
            }
        }
    }

}
