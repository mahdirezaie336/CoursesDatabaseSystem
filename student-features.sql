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
create procedure student_view_class_homeworks (in
    token varchar(512),
    c_id varchar(512)
    )
begin
    # Check if user is logged in as student
    if check_student_login(token) then
        select C.course_id, course_name, homework_id, homework_name
        from Homework H
            join Course C on H.course_id = C.course_id
            join Takes T on C.course_id = T.course_id
        where T.student_no = get_student(token) and
              T.course_id = c_id;
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

# Students can take quiz after they have started the quiz
create procedure student_answer_quiz (in
    token varchar(512),
    quiz_id int,
    question_id int,
    answer int
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

        # Check if they did not started the quiz
        if not exists(select * from QuizAnswer QA where QA.quiz_id = quiz_id and
                                                    QA.student_no = get_student(token)) then
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You did not start the quiz';
        end if;

        # Submit the answer
        insert into QuizQuestionAnswer (student_no, quiz_id, question_id, choice)
        values (get_student(token), quiz_id, question_id, answer);
    else
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You are not logged in';
    end if;
end;

# Students can review their quiz
create procedure student_review_quiz (in
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

        # Check if did not take this quiz
        if not exists(select * from QuizAnswer QA where QA.quiz_id = quiz_id and
                                                        QA.student_no = get_student(token)) then
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You did not participate in this quiz';
        end if;

        select start_datetime into start_time from Quiz Q where Q.quiz_id = quiz_id;
        select finish_datetime into finish_time from Quiz Q where Q.quiz_id = quiz_id;

        # Check if student is in allowed time interval
        if now() < finish_time then
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You are not allowed at this time';
        end if;

        select student_no, quiz_id, QQ.question_id, question_body,
               correct_answer, choice as 'Your Answer', answer_description
        from QuizQuestionAnswer QQA
            join QuadraticQuestion QQ on QQA.question_id = QQ.question_id
            join Question Q2 on QQ.question_id = Q2.question_id
        where QQA.quiz_id = quiz_id and QQA.student_no = get_student(token);
    else
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You are not logged in';
    end if;
end;

# Student can submit their answer to homework
create procedure student_submit_homework (in
    token varchar(512),
    hw_id int,
    q_id int,
    ans varchar(512)
)
begin
    declare deadline datetime;

    # Check if user is logged in as student
    if check_student_login(token) then
        # Check if the student is allowed to this homework
        if not exists(
            select *
            from Homework H
                join Course C on H.course_id = C.course_id
                join Takes T on C.course_id = T.course_id
                where H.homework_id = hw_id and student_no = get_student(token)
            ) then
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permission Denied';
        end if;

        # Check if the student if in allowed interval
        select deadline into deadline from Homework H where H.homework_id = hw_id;

        if now() > deadline then
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You are not allowed at this time';
        end if;

        # Check if previously uploaded
        if exists(
            select *
            from HomeworkAnswer HA
            where HA.homework_id = hw_id and
                  HA.student_no = get_student(token) and
                  HA.question_id = q_id) then

            update HomeworkAnswer
            set answer = ans
            where HomeworkAnswer.homework_id = hw_id and
                  HomeworkAnswer.student_no = get_student(token) and
                  HomeworkAnswer.question_id = q_id;
        else
            insert into HomeworkAnswer (student_no, homework_id, question_id, answer)
            values (get_student(token), hw_id, q_id, ans);
        end if;

    else
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You are not logged in';
    end if;
end;

# Students can review their homework
create procedure student_review_homework (in
    token varchar(512),
    hw_id int
)
begin
    declare deadline datetime;
    if check_student_login(token) then
        # Check if the student is allowed to this homework
        if not exists(
            select *
            from Homework H
                join Course C on H.course_id = C.course_id
                join Takes T on C.course_id = T.course_id
                where H.homework_id = hw_id and student_no = get_student(token)
            ) then
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permission Denied';
        end if;

        # Check if the student if in allowed interval
        select deadline into deadline from Homework H where H.homework_id = hw_id;

        if now() < deadline then
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You are not allowed at this time';
        end if;

        # Get home work answers
        select question_id, answer
        from HomeworkAnswer
        where student_no = get_student(token) and homework_id = hw_id;
    else
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You are not logged in';
    end if;
end;

# Students can see their homeworks
create procedure get_homework_details (in
    token varchar(512),
    hw_id int
)
begin
    if check_student_login(token) then
        # Check if the student is allowed to this homework
        if not exists(
            select *
            from Homework H
                join Course C on H.course_id = C.course_id
                join Takes T on C.course_id = T.course_id
                where H.homework_id = hw_id and student_no = get_student(token)
            ) then
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permission Denied';
        end if;

        # Get home work answers
        select HQ.question_id, question_body
        from Homework H
            join HomeworkQuestion HQ on H.homework_id = HQ.homework_id
            join ShortAnswerQuestion SAQ on SAQ.question_id = HQ.question_id
            join Question Q on SAQ.question_id = Q.question_id
        where H.homework_id = hw_id;
    else
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You are not logged in';
    end if;
end;

call student_view_class_homeworks('98482979514914d31ae7fbc2b9558717');
call student_view_class_quizzes('98482979514914d31ae7fbc2b9558717');
call student_start_quiz('98482979514914d31ae7fbc2b9558717', 4);
call student_review_quiz('98482979514914d31ae7fbc2b9558717', 4);
call student_submit_homework('98482979514914d31ae7fbc2b9558717', 4, 1, 'My Answer');
call student_answer_quiz('98482979514914d31ae7fbc2b9558717', 4, 11, '1');
call student_answer_quiz('98482979514914d31ae7fbc2b9558717', 4, 12, '1');
