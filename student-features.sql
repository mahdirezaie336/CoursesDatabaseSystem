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

call student_view_class_homeworks('98482979514914d31ae7fbc2b9558717');
call student_view_class_quizzes('98482979514914d31ae7fbc2b9558717');
