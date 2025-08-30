using System;

namespace CalculatorExtensionApp
{
    // Define static class for extension methods
    public static class CalculatorExtensions
    {
       
        // addition
        public static int Add(this int a, int b) => a + b;

        // subtraction
        public static int Subtract(this int a, int b) => a - b;

        // Multiplication
        public static int Multiply(this int a, int b) => a * b;

        // Divition
        public static double Divide(this int a, int b)
        {
            if (b == 0) throw new DivideByZeroException("Cannot divide by zero!");
            return (double)a / b;
        }

        // power
        public static double Power(this int a, int exp) => Math.Pow(a, exp);

        // squareroot
        public static double SquareRoot(this int a)
        {
            if (a < 0) throw new ArgumentException("Cannot calculate square root of negative number");
            return Math.Sqrt(a);
        }
    }


    // Step 2: Test the extensions
    class Program
    {
        static void Main()
        {
            int x = 20;
            int y = 10;

            Console.WriteLine($"{x} + {y} = {x.Add(y)}");
            Console.WriteLine($"{x} - {y} = {x.Subtract(y)}");
            Console.WriteLine($"{x} * {y} = {x.Multiply(y)}");
            Console.WriteLine($"{x} / {y} = {x.Divide(y)}");
            Console.WriteLine($"{x} ^ 3 = {x.Power(3)}");
            Console.WriteLine($"√{x} = {x.SquareRoot()}");
        }
    }
}
