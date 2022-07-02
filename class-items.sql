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
# TODO: Create triggers to add from subclasses

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
    homework_id int primary key auto_increment,
    homework_name varchar(512),
    course_id char(8) references Course,
    deadline datetime
);

# Relation between homework and Short Answer Question
create table if not exists HomeworkQuestion (
    homework_id int references Homework,
    question_id int references ShortAnswerQuestion,
    primary key (homework_id, question_id)
);

insert into Quiz (quiz_name, course_id, start_datetime, finish_datetime, duration)
values ('Quiz - 1', '12000001', '2022-01-01 01:01:01', '2023-01-01 01:01:01', 60);
insert into Quiz (quiz_name, course_id, start_datetime, finish_datetime, duration)
values ('Quiz - 2', '12000001', '2022-01-01 01:01:01', '2023-01-01 01:01:01', 60);
insert into Quiz (quiz_name, course_id, start_datetime, finish_datetime, duration)
values ('Quiz - 1', '12000005', '2022-01-01 01:01:01', '2023-01-01 01:01:01', 60);
insert into Quiz (quiz_name, course_id, start_datetime, finish_datetime, duration)
values ('Quiz - 2', '12000005', '2022-01-01 01:01:01', '2023-01-01 01:01:01', 60);
insert into Quiz (quiz_name, course_id, start_datetime, finish_datetime, duration)
values ('Quiz - 3', '12000005', '2022-01-01 01:01:01', '2023-01-01 01:01:01', 60);
insert into Quiz (quiz_name, course_id, start_datetime, finish_datetime, duration)
values ('Quiz - 1', '17000001', '2022-01-01 01:01:01', '2023-01-01 01:01:01', 60);

insert into Question (question_id, question_body, answer_description)
values (1, 'What is 2+2?', '5');
insert into Question (question_id, question_body, answer_description)
values (2, 'What is 1+1?', '3');
insert into Question (question_id, question_body, answer_description)
values (3, 'What is 1+2?', '12');
insert into Question (question_id, question_body, answer_description)
values (4, 'What is 0+2?', '20');
insert into Question (question_id, question_body, answer_description)
values (11, 'What is 2+2?', '5');
insert into Question (question_id, question_body, answer_description)
values (12, 'What is 2+2?', '5');
insert into Question (question_id, question_body, answer_description)
values (13, 'What is 2+2?', '5');
insert into Question (question_id, question_body, answer_description)
values (14, 'What is 2+2?', '5');

insert into ShortAnswerQuestion (question_id, correct_answer)
values (1, '5');
insert into ShortAnswerQuestion (question_id, correct_answer)
values (2, '3');
insert into ShortAnswerQuestion (question_id, correct_answer)
values (3, '12');
insert into ShortAnswerQuestion (question_id, correct_answer)
values (4, '20');

insert into QuadraticQuestion (question_id, answer_1, answer_2, answer_3, answer_4, correct_answer)
values (11, '24', '30', '10', '20', 1);
insert into QuadraticQuestion (question_id, answer_1, answer_2, answer_3, answer_4, correct_answer)
values (12, '22', '30', '12', '20', 2);
insert into QuadraticQuestion (question_id, answer_1, answer_2, answer_3, answer_4, correct_answer)
values (13, '5', '14', '10', '18', 1);
insert into QuadraticQuestion (question_id, answer_1, answer_2, answer_3, answer_4, correct_answer)
values (14, '20', '30', '10', '16', 4);

insert into QuestionQuiz (quiz_id, question_id) values (1, 11);
insert into QuestionQuiz (quiz_id, question_id) values (1, 12);
insert into QuestionQuiz (quiz_id, question_id) values (1, 13);
insert into QuestionQuiz (quiz_id, question_id) values (1, 14);
insert into QuestionQuiz (quiz_id, question_id) values (2, 11);
insert into QuestionQuiz (quiz_id, question_id) values (2, 12);
insert into QuestionQuiz (quiz_id, question_id) values (3, 11);
insert into QuestionQuiz (quiz_id, question_id) values (5, 11);
insert into QuestionQuiz (quiz_id, question_id) values (5, 12);
insert into QuestionQuiz (quiz_id, question_id) values (5, 13);
insert into QuestionQuiz (quiz_id, question_id) values (4, 11);
insert into QuestionQuiz (quiz_id, question_id) values (4, 12);
insert into QuestionQuiz (quiz_id, question_id) values (4, 13);

insert into Homework (homework_name, course_id, deadline)
values ('HW1', '12000001', '2022-01-01 23:59:59');
insert into Homework (homework_name, course_id, deadline)
values ('HW2', '12000001', '2023-01-01 23:59:59');
insert into Homework (homework_name, course_id, deadline)
values ('HW3', '12000001', '2023-07-09 23:59:59');
insert into Homework (homework_name, course_id, deadline)
values ('HW1', '12000005', '2022-01-01 23:59:59');
insert into Homework (homework_name, course_id, deadline)
values ('HW2', '12000005', '2023-01-01 23:59:59');
insert into Homework (homework_name, course_id, deadline)
values ('HW3', '12000005', '2023-07-09 23:59:59');

insert into HomeworkQuestion (homework_id, question_id) values (1, 1);
insert into HomeworkQuestion (homework_id, question_id) values (1, 2);
insert into HomeworkQuestion (homework_id, question_id) values (1, 3);
insert into HomeworkQuestion (homework_id, question_id) values (1, 4);
insert into HomeworkQuestion (homework_id, question_id) values (2, 1);
insert into HomeworkQuestion (homework_id, question_id) values (2, 2);
insert into HomeworkQuestion (homework_id, question_id) values (2, 3);
insert into HomeworkQuestion (homework_id, question_id) values (3, 3);
insert into HomeworkQuestion (homework_id, question_id) values (3, 4);
insert into HomeworkQuestion (homework_id, question_id) values (4, 1);
insert into HomeworkQuestion (homework_id, question_id) values (4, 2);

