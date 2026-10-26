package vn.edu.fpt.slot29.bootstrap;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;
import vn.edu.fpt.slot29.domain.*;
import vn.edu.fpt.slot29.service.*;

@Component
@Profile("!test")
public class DemoRunner implements CommandLineRunner {
    private final IStudentService students;
    private final IBookService books;

    public DemoRunner(IStudentService students, IBookService books) {
        this.students = students;
        this.books = books;
    }

    @Override
    public void run(String... args) {
        Student student = students.getStudents().stream()
                .filter(s -> "s29@fu.edu.vn".equals(s.getEmail()))
                .findFirst()
                .orElseGet(() -> students.createStudent(new Student("s29@fu.edu.vn", "Slot", "TwentyNine", 8.0)));

        Book first = books.getBooks().stream()
                .filter(b -> "978-001".equals(b.getIsbn()))
                .findFirst()
                .orElseGet(() -> books.createBook(new Book("978-001", "Hibernate Basics", "FPT")));

        Book second = books.getBooks().stream()
                .filter(b -> "978-002".equals(b.getIsbn()))
                .findFirst()
                .orElseGet(() -> books.createBook(new Book("978-002", "ORM Design", "FPT")));

        Student loaded = students.getStudent(student.getId());
        boolean hasFirst = loaded.getBooks().stream().anyMatch(b -> java.util.Objects.equals(b.getId(), first.getId()));
        boolean hasSecond = loaded.getBooks().stream().anyMatch(b -> java.util.Objects.equals(b.getId(), second.getId()));

        java.util.List<Long> toBorrow = new java.util.ArrayList<>();
        if (!hasFirst) toBorrow.add(first.getId());
        if (!hasSecond) toBorrow.add(second.getId());

        if (!toBorrow.isEmpty()) {
            students.borrowBooksAtomically(student.getId(), toBorrow);
            loaded = students.getStudent(student.getId());
        }

        System.out.printf("%s has %d books%n", loaded, loaded.getBooks().size());
        students.findStudentsByBook(first.getId()).forEach(System.out::println);
    }
}
