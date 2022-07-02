use EducationalSystem;

create function check_student_login (token varchar(512)) returns bool
begin
    return exists(select * from StudentLogins SL where SL.token=token);
end;

create function get_student (token varchar(512)) returns char(7)
begin
    # Check if token is valid
    if not check_student_login(token) then
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You are not logged in';
    end if;

    return (select student_no from StudentLogins SL where SL.token=token);
end;

# Students can see their homeworks
create procedure student_view_class_homeworks (in token varchar(512))
begin
    # Check if user is logged in as student
    if check_student_login(token) then
        select C.course_id, course_name, homework_id, homework_name
        from Homework H
            join Course C on H.course_id = C.course_id
            join Takes T on C.course_id = T.course_id
        where T.student_no = get_student(token);
    else
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You are not logged in';
    end if;
end;

# Students can see their quizzes
create procedure student_view_class_quizzes (in token varchar(512))
begin
    # Check if user is logged in as student
    if check_student_login(token) then
        select C.course_id, course_name, quiz_id, quiz_name
        from Quiz Q
            join Course C on Q.course_id = C.course_id
            join Takes T on C.course_id = T.course_id
        where T.student_no = get_student(token);
    else
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You are not logged in';
    end if;
end;

# Students can start a quiz in the specified time
create procedure student_start_quiz (in
    token varchar(512),
    quiz_id int
    )
begin
    declare start_time datetime;
    declare finish_time datetime;
    # Check if user is logged in as student
    if check_student_login(token) then
        # Check if student is allowed to this quiz
        if not exists (select *
                       from Quiz Q
                            join Course C on Q.course_id = C.course_id
                            join Takes T on C.course_id = T.course_id
                       where T.student_no = get_student(token) and
                                Q.quiz_id = quiz_id) then
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permission Denied';
        end if;

        select start_datetime into start_time from Quiz Q where Q.quiz_id = quiz_id;
        select finish_datetime into finish_time from Quiz Q where Q.quiz_id = quiz_id;

        # Check if student can start the quiz at this time
        if now() not between start_time and finish_time then
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You are not allowed at this time';
        end if;

        # Check if already started
        if exists(select * from QuizAnswer QA where QA.quiz_id = quiz_id and
                                                    QA.student_no = get_student(token)) then
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You already started this quiz';
        end if;

        # Start the quiz
        insert into QuizAnswer (student_no, quiz_id, start_datetime)
        values (get_student(token), quiz_id, now());
    else
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You are not logged in';
    end if;
end;

call student_view_class_homeworks('98482979514914d31ae7fbc2b9558717');
call student_view_class_quizzes('98482979514914d31ae7fbc2b9558717');
call student_start_quiz('98482979514914d31ae7fbc2b9558717', 4);

