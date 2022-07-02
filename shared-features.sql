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

create function user_login (user_no varchar(7), password_md5 varchar(512)) returns varchar(512)
begin
    # Create a random token
    set @token = md5(rand());

    # If the user is a student
    if exists(select * from Student where student_no=user_no and password=password_md5) then
        # If already exists in table
        while exists(select * from StudentLogins SL where SL.token=@token) do
            select @token = md5(rand());
        end while;

        # Inserting logged in student into the table
        insert into StudentLogins values (@token, user_no, now());
    end if;

    # If the user is a professor
    if exists(select * from Professor where professor_no=user_no and password=password_md5) then
        # If already exists in table
        while exists(select * from ProfessorLogins PL where PL.token=@token) do
            select @token = md5(rand());
        end while;

        # Inserting logged in student into the table
        insert into ProfessorLogins values (@token, user_no, now());
    end if;

end;

