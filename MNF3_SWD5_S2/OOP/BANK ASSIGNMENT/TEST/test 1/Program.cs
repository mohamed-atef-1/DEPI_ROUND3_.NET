using System;
using System.Collections.Generic;
using System.Linq;

namespace test_1
{
   

    
   
   

  








































































    
    // Program Entry Point

    class Program
    {
        static void Main()
        {
            Console.Write("Enter Bank Name: ");
            string bankName = Console.ReadLine();
            Console.Write("Enter Branch Code: ");
            string branchCode = Console.ReadLine();

            Bank bank = new Bank(bankName, branchCode);

            bool exit = false;
            while (!exit)
            {
                Console.WriteLine("\n--- Bank Menu ---");
                Console.WriteLine("1. Add Customer");
                Console.WriteLine("2. Update Customer");
                Console.WriteLine("3. Remove Customer");
                Console.WriteLine("4. Add Account");
                Console.WriteLine("5. Deposit");
                Console.WriteLine("6. Withdraw");
                Console.WriteLine("7. Transfer");
                Console.WriteLine("8. Show Bank Report");
                Console.WriteLine("9. Exit");
                Console.Write("Select option: ");

                switch (Console.ReadLine())
                {
                    case "1":
                        Console.Write("Full Name: ");
                        string name = Console.ReadLine();
                        Console.Write("National ID: ");
                        string nid = Console.ReadLine();
                        Console.Write("Date of Birth (yyyy-mm-dd): ");
                        DateTime dob = DateTime.Parse(Console.ReadLine());
                        bank.AddCustomer(new Customer(name, nid, dob));
                        Console.WriteLine("Customer added successfully.");
                        break;

                    case "8":
                        bank.GetBankReport();
                        break;

                    case "9":
                        exit = true;
                        break;

                    default:
                        Console.WriteLine("Option not implemented yet.");
                        break;
                }
            }
        }
    }
}