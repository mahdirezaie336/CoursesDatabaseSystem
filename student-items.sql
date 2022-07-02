use EducationalSystem;

# When a student starts a quiz, a new row will be added to this table
create table QuizAnswer (
    student_no char(7),
    quiz_id int,
    start_datetime datetime,
    finished int default 0,

    primary key (student_no, quiz_id),
    foreign key (student_no) references Student(student_no),
    foreign key (quiz_id) references Quiz(quiz_id)
);

# When a student answers a question of a quiz, a new row will be added
create table QuizQuestionAnswer (
    student_no char(7),
    quiz_id int,
    question_id int,
    choice int,
    grade int,

    primary key (student_no, quiz_id, question_id),
    foreign key (student_no, quiz_id) references QuizAnswer(student_no, quiz_id),
    foreign key (question_id) references QuadraticQuestion(question_id),

    check ( choice in (1, 2, 3, 4) )
);

create trigger close_quiz after insert on Quiz for each row
begin
    create event e on schedule at new.finish_datetime do
    begin
        update QuizQuestionAnswer
        set grade = if((select correct_answer
                        from QuadraticQuestion QQ
                        where QQ.question_id = QuizQuestionAnswer.question_id), 1, 0)
        where quiz_id = new.quiz_id;
    end;
end;

# This is a 3 way relation between student, question and homework.
create table HomeworkAnswer (
    student_no char(7),
    homework_id int,
    question_id int,
    answer varchar(512),
    grade float,

    primary key (student_no, homework_id, question_id),
    foreign key (homework_id) references Homework(homework_id),
    foreign key (question_id) references ShortAnswerQuestion(question_id),
    foreign key (student_no) references Student(student_no)
);

# alter table HomeworkAnswer add grade float;
create event 'Helli' on schedule at '' do
    select now();