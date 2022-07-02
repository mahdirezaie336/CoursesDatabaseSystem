use EducationalSystem;

create table if not exists Quiz (
    quiz_id int primary key auto_increment,
    quiz_name varchar(512),
    course_id char(8) references Course,
    start_datetime datetime,
    finish_datetime datetime,
    duration int,
    finished int default 0
);

# Questions' superclass
create table if not exists Question (
    question_id int primary key,
    question_body varchar(512),
    answer_description varchar(512)
);

create table if not exists QuadraticQuestion (
    question_id int primary key references Question,
    answer_1 varchar(512),
    answer_2 varchar(512),
    answer_3 varchar(512),
    answer_4 varchar(512),
    correct_answer int not null,
    check ( correct_answer in (1, 2, 3, 4) )
);

create table if not exists ShortAnswerQuestion (
    question_id int primary key references Question,
    correct_answer varchar(512)
);

# Relation between question and quiz
create table if not exists QuestionQuiz (
    quiz_id int references Quiz,
    question_id int references QuadraticQuestion,
    primary key (quiz_id, question_id)
);

create table if not exists Homework (
    homework_id int primary key,
    homework_name varchar(512)
);

# Relation between homework and Short Answer Question
create table if not exists HomeworkQuestion (
    homework_id int references Homework,
    question_id int references ShortAnswerQuestion,
    primary key (homework_id, question_id)
);


