use EducationalSystem;

create function check_professor_login (token varchar(512)) returns bool
begin
    return exists(select * from ProfessorLogins PL where PL.token=token);
end;

create function get_professor (token varchar(512)) returns varchar(512)
begin
    # Check if token is valid
    if not check_professor_login(token) then
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You are not logged in';
    end if;

    return (select professor_no from ProfessorLogins PL where PL.token=token);
end;

# Professor must can see class members
create procedure view_class_members (in token varchar(512))
begin
    if check_professor_login(token) then
        select S.student_no, S.name_fa, S.email
        from Course C
            join Takes T on C.course_id = T.course_id
            join Student S on S.student_no = T.student_no
        where C.professor_no = get_professor(token);
    else
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You are not logged in';
    end if;
end;

# Professor can see list of quizzes
create procedure view_class_quizzes (in token varchar(512))
begin
    if check_professor_login(token) then
        select quiz_id, quiz_name, start_datetime, finish_datetime, duration, finish_datetime
        from Course C
            join Quiz Q on C.course_id = Q.course_id
        where C.professor_no = get_professor(token);
    else
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You are not logged in';
    end if;
end;

# Professor can see list of homeworks
create procedure view_class_homeworks (in token varchar(512))
begin
    if check_professor_login(token) then
        select homework_id, homework_name
        from Course C
            join Homework H on C.course_id = H.course_id
        where professor_no = get_professor(token);
    else
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You are not logged in';
    end if;
end;

# Professor can create homework
create procedure create_homework (in
    token varchar(512),
    homework_name varchar(512),
    course_id char(8),
    deadline datetime)
begin
    if check_professor_login(token) then
        # Checking if the course is for the professor
        if not exists(select *
                      from Course C
                      where C.professor_no = get_professor(token) and
                            C.course_id = course_id) then
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Access Denied';
        end if;

        insert into Homework (homework_name, course_id, deadline)
        values (homework_name, course_id, deadline);
    else
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You are not logged in';
    end if;
end;

# Professor can create quiz
create procedure create_quiz (in
    token varchar(512),
    quiz_name varchar(512),
    course_id char(8),
    start_datetime datetime,
    finish_datetime datetime,
    duration int
)
begin
    if check_professor_login(token) then
        # Checking if the course is for the professor
        if not exists(select *
                      from Course C
                      where C.professor_no = get_professor(token) and
                            C.course_id = course_id) then
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Access Denied';
        end if;

        insert into Quiz (quiz_name, course_id, start_datetime, finish_datetime, duration)
        values (quiz_name, course_id, start_datetime, finish_datetime, duration);
    else
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You are not logged in';
    end if;
end;

select user_login('12001', '3795148131Aa');
call view_class_members('43c5b1dfd5079b426167a2ef05e47c88');
call view_class_quizzes('43c5b1dfd5079b426167a2ef05e47c88');
call view_class_homeworks('43c5b1dfd5079b426167a2ef05e47c88');
call view_class_homeworks('a');
call create_homework(
    '43c5b1dfd5079b426167a2ef05e47c88',
    'HW6',
    '17000002',
    '2022-07-09 23:59:59'
    );
call create_homework(
    '43c5b1dfd5079b426167a2ef05e47c88',
    'HW6',
    '12000004',
    '2022-07-09 23:59:59'
    );
call create_quiz(
    '43c5b1dfd5079b426167a2ef05e47c88',
    'Quiz Final',
    '12000004',
    '2022-07-09 23:59:59',
    '2022-07-10 01:00:00',
    50
    );
