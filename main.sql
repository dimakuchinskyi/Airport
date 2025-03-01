create database Airport;
go
use Airport;
go
create table Passengers
(
    Id int primary key,
    Name varchar(50) not null check(Name<>'') ,
    Surname varchar(50) not null check(Surname<>'') ,
    Passport varchar(50) not null check(Passport<>'') unique,
);
go
create table Flights
(
    Id int primary key,
    Name varchar(50) not null check(Name<>''),
    Departure varchar(50) not null check(Departure<>''),
    Arrival varchar(50) not null check(Arrival<>''),
    Departure_time datetime not null,
    Arrival_time datetime not null,
    Price float not null check(Price>=0),
    constraint chk_time check (Departure_time < Arrival_time)
);
go
create table Tickets
(
    Id int primary key,
    Flight_id int,
    Passenger_id int,
    Name varchar(50) not null check(Name<>'') ,
    Surname varchar(50) not null check(Surname<>'') ,
    Passport varchar(50) not null check(Passport<>''),
    Class varchar(10) not null check(Class in ('Business', 'Economy')),
    Price float check(Price>0) ,
    foreign key (Flight_id) references Flights(Id),
    foreign key (Passenger_id) references Passengers(Id)
);
go
create trigger DeleteTickets -- трігер на видалення квитків коли видаляються рейси
on Flights
after delete
as
begin
    delete from Tickets
    Where Flight_id in(select Id from deleted)
end;






go
create trigger CheckUniquePasspot--трігер на перевірку унікальності паспорта           c:
on Passengers
instead of insert
as
begin
    if exists(select 1 from Passengers where Passport = (select Passport from inserted))
    begin
        raiserror('Passport is not unique' , 16, 1)
    end
    else
    begin
        insert into Passengers (Id, Name, Surname, Passport)
        select Id, Name, Surname, Passport
        from inserted
    end
end

-- Вставка першого запису з унікальним паспортом
    insert into Passengers (Id, Name, Surname, Passport) values (2, 'Jane', 'Smith', 'B98765432');
go

-- спроба вставити другий запис з тим самим паспортом, що й у попередньому записі, що повинно викликати помилку
insert into Passengers (Id, Name, Surname, Passport) values (3, 'Alice', 'Johnson', 'B98765432');
go




go
create trigger SetDefaultsOnInsert -- тригер на встановлення значень за замовчуванням, якщо цінна не вказана то буде 100
    on Tickets
    instead of insert
    as
begin
    insert into Tickets (Id, Flight_id, Passenger_id, Name, Surname, Passport, Class, Price)
    select Id, Flight_id, Passenger_id, Name, Surname, Passport,
           coalesce(Class, 'Economy'), coalesce(Price, 100)
    from inserted
end;
go

-- перевірка тригера на встановлення ціни 100 якщо ціна не була введена
insert into Passengers (Id, Name, Surname, Passport) values (1, 'John', 'Doe', 'A12345678');
insert into Flights (Id, Name, Departure, Arrival, Departure_time, Arrival_time, Price) values (1, 'Flight 101', 'City A', 'City B', '2025-03-01 08:00:00', '2025-03-01 10:00:00', 200);
go
insert into Tickets (Id, Flight_id, Passenger_id, Name, Surname, Passport, Class) values (1, 1, 1, 'John', 'Doe', 'A12345678', 'Business');
go
select * from Tickets
go








use master;
go
drop database Airport;