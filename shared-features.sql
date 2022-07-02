use EducationalSystem;

create table if not exists StudentLogins (
    token varchar(512) primary key,
    student_no varchar(7) references Student,
    login_datetime datetime
);

create table if not exists ProfessorLogins (
    token varchar(512) primary key,
    professor_no varchar(5) references Professor,
    login_datetime datetime
);

SET GLOBAL log_bin_trust_function_creators = 1;

# User login function
create function user_login (user_no varchar(7), password_md5 varchar(512)) returns varchar(512)
begin
    # Create a random token
    declare token varchar(512);
    set token = md5(rand());

    # If the user is a student
    if exists(select * from Student where student_no=user_no and password=password_md5) then
        # If already exists in table
        while exists(select * from StudentLogins SL where SL.token=token) do
            select md5(rand()) into token;
        end while;

        # Inserting logged in student into the table
        insert into StudentLogins values (token, user_no, now());
    elseif exists(select * from Professor where professor_no=user_no and password=password_md5) then
        # If already exists in table
        while exists(select * from ProfessorLogins PL where PL.token=token) do
            select md5(rand()) into token;
        end while;

        # Inserting logged in professor into the table
        insert into ProfessorLogins values (@token, user_no, now());
    else
        # If credentials are invalid
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid Credentials';
    end if;

    return token;
end;

# User logout function
create function user_logout (token varchar(512)) returns int
begin
    # If user is a student
    if exists(select * from StudentLogins SL where SL.token=token) then
        delete from StudentLogins SL where SL.token=token;
    # If user if a professor
    elseif exists(select * from ProfessorLogins PL where PL.token=token) then
        delete from ProfessorLogins PL where PL.token=token;
    # If non of above raise error
    else
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You are not logged in';
    end if;
    return 0;
end;

# Change password function
create function change_password (token varchar(512), new_password varchar(512)) returns int
begin
    # If the password does not satisfy the conditions
    if not new_password REGEXP '^(?=.*[A-Z]+)(?=.*[0-9]+)(?=.*[a-z]+).{8,20}$' then
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Weak Password';
    end if;

    # If user is a student
    if exists(select * from StudentLogins SL where SL.token=token) then
        update Student
        set password=md5(new_password)
        where student_no = (select student_no from StudentLogins SL where SL.token=token);
    # If user if a professor
    elseif exists(select * from ProfessorLogins PL where PL.token=token) then
        update Professor
        set password=md5(new_password)
        where professor_no = (select professor_no from ProfessorLogins PL where PL.token=token);
    # If non of above, raise error
    else
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You are not logged in';
    end if;
    return 0;
end;

# Procedure to show courses
create procedure view_courses (in token varchar(512))
begin
    # If user is a student
    if exists(select * from StudentLogins SL where SL.token=token) then
        select T.course_id, course_name
        from Takes T join Course C on C.course_id = T.course_id
        where T.student_no = (select student_no
                              from StudentLogins SL
                              where SL.token=token);
    # If user if a professor
    elseif exists(select * from ProfessorLogins PL where PL.token=token) then
        select course_id, course_name
        from Course C
        where professor_no = (select professor_no
                              from ProfessorLogins PL
                              where PL.token=token);
    # If non of above raise error
    else
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You are not logged in';
    end if;
end;

select user_login('9212001', '501fd53c715b4663282d5bc936c9db49');
select change_password('5d94e97c3cd65f82d8e8c79754dfe82f', 'A124Ab22a');
call view_courses('5d94e97c3cd65f82d8e8c79754dfe82f');
