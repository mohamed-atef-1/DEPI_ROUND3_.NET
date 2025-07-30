using System;

class SimpleCalculator
{
    static void Main()
    {
        Console.WriteLine("Hello!");

        // Input the first number
        Console.Write("Input the first number: ");
        double num1 = GetValidNumber();

        // Input the second number
        Console.Write("Input the second number: ");
        double num2 = GetValidNumber();

        // Ask for operation
        Console.WriteLine("What do you want to do with those numbers?");
        Console.WriteLine("[A]dd");
        Console.WriteLine("[S]ubtract");
        Console.WriteLine("[M]ultiply");
        Console.Write("Enter your choice: ");
        string choice = Console.ReadLine().Trim().ToLower();

        // Perform the operation
        switch (choice)
        {
            case "a":
                Console.WriteLine($"{num1} + {num2} = {num1 + num2}");
                break;
            case "s":
                Console.WriteLine($"{num1} - {num2} = {num1 - num2}");
                break;
            case "m":
                Console.WriteLine($"{num1} * {num2} = {num1 * num2}");
                break;
            default:
                Console.WriteLine("Invalid option");
                break;
        }

        // Wait for any key
        Console.WriteLine("Press any key to close");
        Console.ReadKey();
    }

    // Helper method to ensure valid number input
    static double GetValidNumber()
    {
        double result;
        while (!double.TryParse(Console.ReadLine(), out result))
        {
            Console.Write("Invalid number, try again: ");
        }
        return result;
    }
}
