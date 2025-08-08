using System;

public class BankAccount
{
    // Fields
    public const string BankCode = "BNK001"; // Constant value - never changes
    public readonly DateTime CreatedDate;    // Set only once in constructor

    private int _accountNumber;
    private string _fullName;
    private string _nationalID;
    private string _phoneNumber;
    private string _address;
    private decimal _balance;

    // Properties with validation
    public string FullName
    {
        get => _fullName;
        set
        {
            if (string.IsNullOrWhiteSpace(value))
                throw new ArgumentException("Full name cannot be empty.");
            _fullName = value;
        }
    }

    public string NationalID
    {
        get => _nationalID;
        set
        {
            if (!IsValidNationalID(value))
                throw new ArgumentException("National ID must be exactly 14 digits.");
            _nationalID = value;
        }
    }

    public string PhoneNumber
    {
        get => _phoneNumber;
        set
        {
            if (!IsValidPhoneNumber(value))
                throw new ArgumentException("Phone number must start with '01' and be 11 digits.");
            _phoneNumber = value;
        }
    }

    public decimal Balance
    {
        get => _balance;
        set
        {
            if (value < 0)
                throw new ArgumentException("Balance cannot be negative.");
            _balance = value;
        }
    }

    public string Address
    {
        get => _address;
        set => _address = value; // Optional, no validation
    }

    // Constructors

    // 1. Default constructor
    public BankAccount()
    {
        _accountNumber = 0;
        FullName = "Unknown";
        NationalID = "00000000000000";
        PhoneNumber = "01000000000";
        Address = "N/A";
        Balance = 0;
        CreatedDate = DateTime.Now;
    }

    // 2. Parameterized constructor
    public BankAccount(string fullName, string nationalID, string phoneNumber, string address, decimal balance)
    {
        _accountNumber = new Random().Next(1000, 9999); // Simulating account number
        FullName = fullName;
        NationalID = nationalID;
        PhoneNumber = phoneNumber;
        Address = address;
        Balance = balance;
        CreatedDate = DateTime.Now;
    }

    // 3. Overloaded constructor (no balance, default to 0)
    public BankAccount(string fullName, string nationalID, string phoneNumber, string address)
        : this(fullName, nationalID, phoneNumber, address, 0)
    {
    }

    // Methods
    public void ShowAccountDetails()
    {
        Console.WriteLine("------ Account Details ------");
        Console.WriteLine($"Bank Code: {BankCode}");
        Console.WriteLine($"Created Date: {CreatedDate}");
        Console.WriteLine($"Account Number: {_accountNumber}");
        Console.WriteLine($"Full Name: {FullName}");
        Console.WriteLine($"National ID: {NationalID}");
        Console.WriteLine($"Phone Number: {PhoneNumber}");
        Console.WriteLine($"Address: {Address}");
        Console.WriteLine($"Balance: {Balance:C}");
        Console.WriteLine("-----------------------------\n");
    }

    public bool IsValidNationalID(string id)
    {
        return id != null && id.Length == 14 && long.TryParse(id, out _);
    }

    public bool IsValidPhoneNumber(string phone)
    {
        return phone != null && phone.Length == 11 && phone.StartsWith("01") && long.TryParse(phone, out _);
    }
}

class Program
{
    static void Main()
    {
        // Object 1: Using parameterized constructor
        BankAccount acc1 = new BankAccount("MOHAMED ATEF", "12345678901234", "01507195449", "MENOUFYA", 1000);

        // Object 2: Using overloaded constructor
        BankAccount acc2 = new BankAccount("AHMED Hassan", "98765432109876", "01146588784", "CAIRO");

        // Display details
        acc1.ShowAccountDetails();
        acc2.ShowAccountDetails();
    }
}
