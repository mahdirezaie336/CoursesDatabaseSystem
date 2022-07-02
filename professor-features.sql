use EducationalSystem;

create function get_professor (token varchar(512)) returns varchar(512)
begin
    # Check if token is valid
    if not token in (select token from ProfessorLogins) then
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You are not logged in';
    end if;

    return (select professor_no from ProfessorLogins PL where Pl.token=token);
end;

# Professor must can see class members
create procedure view_class_members (in token varchar(512))
begin
    select *
    from Course C
        join Takes T on C.course_id = T.course_id
    where C.professor_no = get_professor(token);
end;

select user_login('12001', '5593661a793cf7e9044311cfae51945b');
call view_courses()
