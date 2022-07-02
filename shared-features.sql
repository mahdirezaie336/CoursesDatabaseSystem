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
    declare token varchar(512);
    if exists(select * from Student where student_no=user_no and password=password_md5) then
        while exists(select * from StudentLogins SL where SL.token=token)
        insert into StudentLogins values (token);
    end if;
end;

