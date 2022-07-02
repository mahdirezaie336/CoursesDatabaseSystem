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
        return '0';
    end if;

    return token;
end;

create function user_logout (token varchar(255)) returns int
begin
    if exists(select * from StudentLogins SL where SL.token=token) then
        delete from StudentLogins SL where SL.token=token;
    elseif exists(select * from ProfessorLogins PL where PL.token=token) then
        delete from ProfessorLogins PL where PL.token=token;
    else
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You are not logged in';
        return 1;
    end if;
    return 0;
end;
