using System;
using System.Collections.Generic;
using System.Linq;

namespace ExaminationSystem
{
    #region Entities

    public sealed class Course
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public int MaximumDegree { get; set; }

        public List<int> EnrolledStudentIds { get; } = new();
        public List<int> InstructorIds { get; } = new();
    }

    public sealed class Student
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public List<int> EnrolledCourseIds { get; } = new();
    }

    public sealed class Instructor
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Specialization { get; set; } = string.Empty;
        public List<int> TeachingCourseIds { get; } = new();
    }

    public abstract class QuestionBase
    {
        public int Id { get; set; }
        public string Text { get; set; } = string.Empty;
        public int Mark { get; set; }
        public abstract bool Grade(string studentAnswer);
    }

    public sealed class MultipleChoiceQuestion : QuestionBase
    {
        public List<string> Options { get; set; } = new();
        public int CorrectOptionIndex { get; set; }

        public override bool Grade(string studentAnswer)
            => int.TryParse(studentAnswer, out var idx) && idx == CorrectOptionIndex;
    }

    public sealed class TrueFalseQuestion : QuestionBase
    {
        public bool CorrectAnswer { get; set; }

        public override bool Grade(string studentAnswer)
            => bool.TryParse(studentAnswer, out var val) && val == CorrectAnswer;
    }

    public sealed class EssayQuestion : QuestionBase
    {
        public override bool Grade(string studentAnswer) => false;
    }

    public sealed class Exam
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public int CourseId { get; set; }
        public bool Started { get; set; }

        public List<QuestionBase> Questions { get; } = new();
    }

    public sealed class ExamAttempt
    {
        public int Id { get; set; }
        public int ExamId { get; set; }
        public int StudentId { get; set; }
        public Dictionary<int, string> Answers { get; } = new();
        public int Score { get; set; }
    }

    #endregion

    #region Repositories

    public sealed class InMemoryStore
    {
        private int _nextCourseId = 1;
        private int _nextStudentId = 1;
        private int _nextInstructorId = 1;
        private int _nextExamId = 1;
        private int _nextQuestionId = 1;
        private int _nextAttemptId = 1;

        public Dictionary<int, Course> Courses { get; } = new();
        public Dictionary<int, Student> Students { get; } = new();
        public Dictionary<int, Instructor> Instructors { get; } = new();
        public Dictionary<int, Exam> Exams { get; } = new();
        public Dictionary<int, QuestionBase> Questions { get; } = new();
        public Dictionary<int, ExamAttempt> Attempts { get; } = new();

        public Course AddCourse(Course c)
        {
            c.Id = _nextCourseId++;
            Courses[c.Id] = c;
            return c;
        }

        public Student AddStudent(Student s)
        {
            s.Id = _nextStudentId++;
            Students[s.Id] = s;
            return s;
        }

        public Instructor AddInstructor(Instructor i)
        {
            i.Id = _nextInstructorId++;
            Instructors[i.Id] = i;
            return i;
        }

        public Exam AddExam(Exam e)
        {
            e.Id = _nextExamId++;
            Exams[e.Id] = e;
            return e;
        }

        public TQuestion AddQuestion<TQuestion>(TQuestion q) where TQuestion : QuestionBase
        {
            q.Id = _nextQuestionId++;
            Questions[q.Id] = q;
            return q;
        }

        public ExamAttempt AddAttempt(ExamAttempt a)
        {
            a.Id = _nextAttemptId++;
            Attempts[a.Id] = a;
            return a;
        }
    }

    #endregion

    #region Services

    public static class EnrollmentService
    {
        public static void EnrollStudent(InMemoryStore db, int studentId, int courseId)
        {
            var s = db.Students[studentId];
            var c = db.Courses[courseId];
            s.EnrolledCourseIds.Add(courseId);
            c.EnrolledStudentIds.Add(studentId);
        }
    }

    public static class ExamService
    {
        public static void AddQuestionToExam(Exam exam, QuestionBase question, Course course)
        {
            var currentMarks = exam.Questions.Sum(q => q.Mark);
            if (currentMarks + question.Mark > course.MaximumDegree)
                throw new InvalidOperationException("Exceeds maximum course degree");
            if (exam.Started) throw new InvalidOperationException("Exam already started");

            exam.Questions.Add(question);
        }

        public static void StartExam(Exam exam)
        {
            exam.Started = true;
        }

        public static ExamAttempt TakeExam(InMemoryStore db, Exam exam, Student student)
        {
            var attempt = new ExamAttempt { ExamId = exam.Id, StudentId = student.Id };

            foreach (var q in exam.Questions)
            {
                Console.WriteLine($"Q{q.Id}: {q.Text} (Marks: {q.Mark})");
                if (q is MultipleChoiceQuestion mcq)
                {
                    for (int i = 0; i < mcq.Options.Count; i++)
                        Console.WriteLine($"[{i}] {mcq.Options[i]}");
                }

                Console.Write("Answer: ");
                var ans = Console.ReadLine() ?? string.Empty;
                attempt.Answers[q.Id] = ans;
                if (q.Grade(ans)) attempt.Score += q.Mark;
            }

            db.AddAttempt(attempt);
            Console.WriteLine($"Final Score: {attempt.Score}\n");
            return attempt;
        }
    }

    public static class ReportingService
    {
        public static void ShowReports(InMemoryStore db)
        {
            foreach (var att in db.Attempts.Values)
            {
                var exam = db.Exams[att.ExamId];
                var course = db.Courses[exam.CourseId];
                var student = db.Students[att.StudentId];
                var passed = att.Score >= course.MaximumDegree / 2 ? "Pass" : "Fail";

                Console.WriteLine($"Exam: {exam.Title} | Student: {student.Name} | Course: {course.Title} | Score: {att.Score}/{course.MaximumDegree} | {passed}");
            }
        }

        public static void CompareStudents(InMemoryStore db, int studentId1, int studentId2, int examId)
        {
            var a1 = db.Attempts.Values.FirstOrDefault(a => a.StudentId == studentId1 && a.ExamId == examId);
            var a2 = db.Attempts.Values.FirstOrDefault(a => a.StudentId == studentId2 && a.ExamId == examId);
            if (a1 == null || a2 == null)
            {
                Console.WriteLine("Comparison not possible, one student has not attempted.");
                return;
            }
            Console.WriteLine($"Comparison: {db.Students[studentId1].Name} scored {a1.Score}, {db.Students[studentId2].Name} scored {a2.Score}.");
        }
    }

    #endregion

    #region Program with Menu

    public static class Program
    {
        public static void Main()
        {
            var db = new InMemoryStore();

            while (true)
            {
                Console.WriteLine("\n==== Examination System Menu ====");
                Console.WriteLine("1. Add Course");
                Console.WriteLine("2. Add Student");
                Console.WriteLine("3. Enroll Student in Course");
                Console.WriteLine("4. Create Exam & Add Questions");
                Console.WriteLine("5. Start Exam & Take Exam");
                Console.WriteLine("6. Show Reports");
                Console.WriteLine("7. Compare Students");
                Console.WriteLine("0. Exit");
                Console.Write("Choose: ");

                var choice = Console.ReadLine();
                try
                {
                    switch (choice)
                    {
                        case "1":
                            Console.Write("Course Title: "); var ct = Console.ReadLine();
                            Console.Write("Description: "); var cd = Console.ReadLine();
                            Console.Write("Max Degree: "); var md = int.Parse(Console.ReadLine() ?? "0");
                            db.AddCourse(new Course { Title = ct!, Description = cd!, MaximumDegree = md });
                            break;
                        case "2":
                            Console.Write("Student Name: "); var sn = Console.ReadLine();
                            Console.Write("Email: "); var se = Console.ReadLine();
                            db.AddStudent(new Student { Name = sn!, Email = se! });
                            break;
                        case "3":
                            Console.Write("Student ID: "); var sid = int.Parse(Console.ReadLine() ?? "0");
                            Console.Write("Course ID: "); var cid = int.Parse(Console.ReadLine() ?? "0");
                            EnrollmentService.EnrollStudent(db, sid, cid);
                            break;
                        case "4":
                            Console.Write("Exam Title: "); var et = Console.ReadLine();
                            Console.Write("Course ID: "); var ecid = int.Parse(Console.ReadLine() ?? "0");
                            var exam = db.AddExam(new Exam { Title = et!, CourseId = ecid });

                            Console.Write("How many questions? "); var qcount = int.Parse(Console.ReadLine() ?? "0");
                            for (int i = 0; i < qcount; i++)
                            {
                                Console.WriteLine($"Add Question {i + 1} - Type (MCQ/TF/Essay): ");
                                var qtype = Console.ReadLine()?.ToLower();
                                Console.Write("Question Text: "); var qt = Console.ReadLine();
                                Console.Write("Marks: "); var qm = int.Parse(Console.ReadLine() ?? "0");

                                QuestionBase q;
                                if (qtype == "mcq")
                                {
                                    var mcq = new MultipleChoiceQuestion { Text = qt!, Mark = qm };
                                    Console.Write("How many options? "); var optn = int.Parse(Console.ReadLine() ?? "0");
                                    for (int j = 0; j < optn; j++)
                                    {
                                        Console.Write($"Option {j}: "); mcq.Options.Add(Console.ReadLine() ?? "");
                                    }
                                    Console.Write("Correct Option Index: "); mcq.CorrectOptionIndex = int.Parse(Console.ReadLine() ?? "0");
                                    q = db.AddQuestion(mcq);
                                }
                                else if (qtype == "tf")
                                {
                                    var tfq = new TrueFalseQuestion { Text = qt!, Mark = qm };
                                    Console.Write("Correct Answer (true/false): "); tfq.CorrectAnswer = bool.Parse(Console.ReadLine() ?? "false");
                                    q = db.AddQuestion(tfq);
                                }
                                else
                                {
                                    q = db.AddQuestion(new EssayQuestion { Text = qt!, Mark = qm });
                                }

                                ExamService.AddQuestionToExam(exam, q, db.Courses[ecid]);
                            }
                            break;
                        case "5":
                            Console.Write("Exam ID: "); var exid = int.Parse(Console.ReadLine() ?? "0");
                            Console.Write("Student ID: "); var stid = int.Parse(Console.ReadLine() ?? "0");
                            var ex = db.Exams[exid];
                            ExamService.StartExam(ex);
                            ExamService.TakeExam(db, ex, db.Students[stid]);
                            break;
                        case "6":
                            ReportingService.ShowReports(db);
                            break;
                        case "7":
                            Console.Write("Exam ID: "); var cmpEx = int.Parse(Console.ReadLine() ?? "0");
                            Console.Write("Student 1 ID: "); var s1 = int.Parse(Console.ReadLine() ?? "0");
                            Console.Write("Student 2 ID: "); var s2 = int.Parse(Console.ReadLine() ?? "0");
                            ReportingService.CompareStudents(db, s1, s2, cmpEx);
                            break;
                        case "0":
                            return;
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error: {ex.Message}");
                }
            }
        }
    }

    #endregion
}
