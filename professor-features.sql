use EducationalSystem;

create function get_professor (token varchar(512)) returns varchar(512)
begin
    # Check if token is valid
    if not token in (select token from ProfessorLogins) then
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You are not logged in';
    end if;

    return (select professor_no from ProfessorLogins PL where PL.token=token);
end;

# Professor must can see class members
create procedure view_class_members (in token varchar(512))
begin
    select S.student_no, S.name_fa, S.email
    from Course C
        join Takes T on C.course_id = T.course_id
        join Student S on S.student_no = T.student_no
    where C.professor_no = get_professor(token);
end;

select user_login('12001', '5593661a793cf7e9044311cfae51945b');
call view_class_members('201088c547cfdb9855cd949d2bc80f67');
