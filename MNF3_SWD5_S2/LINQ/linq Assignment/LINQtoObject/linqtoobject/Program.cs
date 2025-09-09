using System;
using System.Linq;

namespace LINQtoObject
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("---- Queries ----");

            // 1- Display book title and its ISBN
            var q1 = from b in SampleData.Books
                     select new { b.Title, b.Isbn };

            Console.WriteLine("\n1) Title and ISBN:");
            foreach (var item in q1)
                Console.WriteLine($"{item.Title} - {item.Isbn}");

            // 2- Display the first 3 books with price more than 25
            var q2 = SampleData.Books
                               .Where(b => b.Price > 25)
                               .Take(3);

            Console.WriteLine("\n2) First 3 books with price > 25:");
            foreach (var b in q2)
                Console.WriteLine($"{b.Title} - {b.Price}");

            // 3- Display Book title along with its publisher name (two ways)
            var q3a = from b in SampleData.Books
                      select new { b.Title, PublisherName = b.Publisher.Name };

            Console.WriteLine("\n3a) Title with Publisher:");
            foreach (var item in q3a)
                Console.WriteLine($"{item.Title} - {item.PublisherName}");

            var q3b = SampleData.Books.Select(b => new { b.Title, Publisher = b.Publisher.Name });

            Console.WriteLine("\n3b) Title with Publisher (method syntax):");
            foreach (var item in q3b)
                Console.WriteLine($"{item.Title} - {item.Publisher}");

            // 4- Find the number of books which cost more than 20
            var q4 = SampleData.Books.Count(b => b.Price > 20);
            Console.WriteLine($"\n4) Number of books with price > 20 = {q4}");

            // 5- Display book title, price, subject name sorted by subject ASC and price DESC
            var q5 = SampleData.Books
                               .OrderBy(b => b.Subject.Name)
                               .ThenByDescending(b => b.Price)
                               .Select(b => new { b.Title, b.Price, Subject = b.Subject.Name });

            Console.WriteLine("\n5) Books sorted by subject asc, price desc:");
            foreach (var item in q5)
                Console.WriteLine($"{item.Subject} - {item.Title} - {item.Price}");

            // 6- Display All subjects with books (two ways)
            var q6a = from s in SampleData.Subjects
                      select new
                      {
                          Subject = s.Name,
                          Books = SampleData.Books.Where(b => b.Subject == s).Select(b => b.Title)
                      };

            Console.WriteLine("\n6a) Subjects with books:");
            foreach (var item in q6a)
            {
                Console.WriteLine($"{item.Subject}: {string.Join(", ", item.Books)}");
            }

            var q6b = SampleData.Books.GroupBy(b => b.Subject.Name);

            Console.WriteLine("\n6b) Subjects with books (group by):");
            foreach (var group in q6b)
            {
                Console.WriteLine($"{group.Key}: {string.Join(", ", group.Select(b => b.Title))}");
            }

            // 7- Display book title & price returned from GetBooks()
            var q7 = SampleData.GetBooks().Cast<Book>()
                               .Select(b => new { b.Title, b.Price });

            Console.WriteLine("\n7) Books from GetBooks():");
            foreach (var item in q7)
                Console.WriteLine($"{item.Title} - {item.Price}");

            // 8- Display books grouped by publisher & subject
            var q8 = SampleData.Books.GroupBy(b => new { Publisher = b.Publisher.Name, Subject = b.Subject.Name });

            Console.WriteLine("\n8) Books grouped by Publisher & Subject:");
            foreach (var group in q8)
            {
                Console.WriteLine($"{group.Key.Publisher} / {group.Key.Subject}: {string.Join(", ", group.Select(b => b.Title))}");
            }
        }
    }
}
