use EducationalSystem;

create table if not exists Student (
    national_code char(10) unique,
    student_no char(7) primary key,
    name_fa varchar(64),
    name_en varchar(64),
    father_name varchar(64),
    birth_date date,
    mobile varchar(11),
    major varchar(512),
    first_name_en varchar(512),
    last_name_en varchar(512),
    password varchar(512),
    email varchar(512)
);

create table if not exists Professor (
    national_code char(10) unique,
    professor_no char(5) primary key,
    name_fa varchar(512),
    name_en varchar(512),
    birth_date date,
    mobile varchar(11),
    department varchar(512),
    title varchar(512),
    first_name_en varchar(512),
    last_name_en varchar(512),
    password varchar(512),
    email varchar(512)
);

create table if not exists Course (
    course_id char(8) primary key,
    course_name varchar(512),
    professor_no char(5),

    foreign key (professor_no) references Professor (professor_no)
);

create table if not exists Takes (
    course_id char(8),
    student_no char(7),

    primary key (student_no, course_id),
    foreign key (student_no) references Student(student_no),
    foreign key (course_id) references Course(course_id)
);

update Student
set password = MD5(
    concat(
        national_code,
        upper(left(first_name_en, 1)),
        lower(left(last_name_en, 1))
        )
    );

update Professor
set password = MD5(
    concat(
        national_code,
        upper(left(first_name_en, 1)),
        lower(left(last_name_en, 1))
        )
    );

update Student
set email = concat(
    lower(left(name_en, 1)),
    '.',
    lower(last_name_en),
    '@aut.ac.ir'
    );

update Professor
set email = concat(
    lower(left(name_en, 1)),
    '.',
    lower(last_name_en),
    '@aut.ac.ir'
    );


