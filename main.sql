create database Airport;
go
use Airport;
go

create table Passengers
(
    Id int primary key,
    Name varchar(50) not null check(Name<>'') ,
    Surname varchar(50) not null check(Surname<>'') ,
    Passport varchar(50) not null check(Passport<>'') unique
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
    Price float check(Price>0),
    foreign key (Flight_id) references Flights(Id),
    foreign key (Passenger_id) references Passengers(Id)
);
go


create trigger DeleteTickets -- створення тригера для видалення квитків при видаленні рейсу
on Flights
instead of delete
as
begin
    delete from Tickets
    where Flight_id in (select Id from deleted);

    delete from Flights
    where Id in (select Id from deleted);
end;
go

-- первірка тригера
insert into Passengers (Id, Name, Surname, Passport) values (1, 'John', 'Doe', 'A12345678');
insert into Passengers (Id, Name, Surname, Passport) values (2, 'Jane', 'Smith', 'B98765432');
go
insert into Flights (Id, Name, Departure, Arrival, Departure_time, Arrival_time, Price) values (1, 'Flight 101', 'City A', 'City B', '2025-03-01 08:00:00', '2025-03-01 10:00:00', 200);
insert into Flights (Id, Name, Departure, Arrival, Departure_time, Arrival_time, Price) values (2, 'Flight 102', 'City C', 'City D', '2025-03-02 09:00:00', '2025-03-02 11:00:00', 250);
go
insert into Tickets (Id, Flight_id, Passenger_id, Name, Surname, Passport, Class, Price) values (1, 1, 1, 'John', 'Doe', 'A12345678', 'Business', 150);
insert into Tickets (Id, Flight_id, Passenger_id, Name, Surname, Passport, Class, Price) values (2, 2, 2, 'Jane', 'Smith', 'B98765432', 'Economy', 300);
go
delete from Flights where Id = 2;
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
insert into Passengers (Id, Name, Surname, Passport) values (2, 'Jane', 'Smith', 'B98765432');
go
insert into Passengers (Id, Name, Surname, Passport) values (3, 'Alice', 'Johnson', 'C12345678');
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



alter table Flights add LastUpdated datetime; --трігер на оновлення дати останнього оновлення
go
create trigger UpdateLastUpdated
on Flights
after update
as
begin
    update Flights
    set LastUpdated = getdate()
    from Flights
    inner join inserted i on Flights.Id = i.Id;
end;
go

-- перевірка тригера на оновлення дати останнього оновлення
insert into Flights (Id, Name, Departure, Arrival, Departure_time, Arrival_time, Price)
values (4, 'Flight 101', 'City A', 'City B', '2025-03-01 08:00:00', '2025-03-01 10:00:00', 200);
go
update Flights
set Price = 250
where Id = 4;
go
select * from Flights;
go


create trigger SetDefaultClass -- трігер на встановлення класу за замовчуванням, якщо клас не вказано то буде Economy
on Tickets
instead of insert
as
begin
    insert into Tickets (Id, Flight_id, Passenger_id, Name, Surname, Passport, Class, Price)
    select Id, Flight_id, Passenger_id, Name, Surname, Passport,
           coalesce(Class, 'Economy'), Price
    from inserted;
end;
go
-- перевірка тригера на встановлення класу за замовчуванням
insert into Tickets (Id, Flight_id, Passenger_id, Name, Surname, Passport, Price)
values (3, 1, 1, 'Alice', 'Johnson', 'C12345678', 150);
go
select * from Tickets;
go


insert into Passengers (Id, Name, Surname, Passport) values (3, 'Alice', 'Johnson', 'C12345678');
insert into Passengers (Id, Name, Surname, Passport) values ( 4, 'Bob', 'Brown', 'D98765432');
insert into Passengers (Id, Name, Surname, Passport) values ( 5, 'Charlie', 'White', 'E12345678');
insert into Passengers (Id, Name, Surname, Passport) values ( 6, 'Diana', 'Black', 'F98765432');
insert into Passengers (Id, Name, Surname, Passport) values ( 7, 'Eve', 'Green', 'G12345678');

go
insert into Flights (Id, Name, Departure, Arrival, Departure_time, Arrival_time, Price) values (2, 'Flight 102', 'City C', 'City D', '2025-03-02 09:00:00', '2025-03-02 11:00:00', 250);
insert into Flights (Id, Name, Departure, Arrival, Departure_time, Arrival_time, Price) values (3, 'Flight 103', 'City E', 'City F', '2025-03-03 10:00:00', '2025-03-03 12:00:00', 300);
insert into Flights (Id, Name, Departure, Arrival, Departure_time, Arrival_time, Price) values (8, 'Flight 104', 'City G', 'City H', '2025-03-04 11:00:00', '2025-03-04 13:00:00', 350);
insert into Flights (Id, Name, Departure, Arrival, Departure_time, Arrival_time, Price) values (6, 'Flight 105', 'City I', 'City J', '2025-03-05 12:00:00', '2025-03-05 14:00:00', 400);
insert into Flights (Id, Name, Departure, Arrival, Departure_time, Arrival_time, Price) values (7, 'Flight 106', 'City K', 'City L', '2025-03-06 13:00:00', '2025-03-06 15:00:00', 450);
insert into Flights (Id, Name, Departure, Arrival, Departure_time, Arrival_time, Price)
values (11, 'Flight 109', 'City X', 'City Y', cast(getdate() as datetime), dateadd(hour, 2, cast(getdate() as datetime)), 300);
insert into Flights (Id, Name, Departure, Arrival, Departure_time, Arrival_time, Price) values
(9, 'Flight 107', 'City M', 'City N', '2025-03-07 08:00:00', '2025-03-07 11:00:00', 500),
(10, 'Flight 108', 'City O', 'City P', '2025-03-08 09:00:00', '2025-03-08 12:00:00', 600);
go
insert into Tickets (Id, Flight_id, Passenger_id, Name, Surname, Passport, Class, Price) values (8, 2, 3, 'Alice', 'Johnson', 'C12345678', 'Business', 200);
insert into Tickets (Id, Flight_id, Passenger_id, Name, Surname, Passport, Class, Price) values (9, 3, 4, 'Bob', 'Brown', 'D98765432', 'Economy', 300);
insert into Tickets (Id, Flight_id, Passenger_id, Name, Surname, Passport, Class, Price) values (10, 8, 5, 'Charlie', 'White', 'E12345678', 'Business', 350);
insert into Tickets (Id, Flight_id, Passenger_id, Name, Surname, Passport, Class, Price) values (11, 6, 6, 'Diana', 'Black', 'F98765432', 'Economy', 400);
insert into Tickets (Id, Flight_id, Passenger_id, Name, Surname, Passport, Class, Price) values (12, 7, 7, 'Eve', 'Green', 'G12345678', 'Business', 450);
insert into Tickets (Id, Flight_id, Passenger_id, Name, Surname, Passport, Class, Price)
values (13, 11, null, 'Test', 'User', 'Z12345678', 'Business', 300);


select * from Passengers;
select * from Flights;
select * from Tickets;


-- запити
select *
from Flights
where Arrival = 'City B' and cast(Departure_time as date) = '2025-03-01'
order by Departure_time;
go
select top 1 *, datediff(minute, Departure_time, Arrival_time) as Duration
from Flights
order by Duration desc;
go
select *, datediff(minute, Departure_time, Arrival_time) as Duration
from Flights
where datediff(minute, Departure_time, Arrival_time) > 120;
go
select Arrival, count(*) as NumberOfFlights
from Flights
group by Arrival;
go
select top 1 Arrival, count(*) as NumberOfFlights
from Flights
group by Arrival
order by NumberOfFlights desc;
go
-- запит для отримання кількості рейсів у кожне місто
select Arrival, count(*) as NumberOfFlights
from Flights
group by Arrival;
go
-- запит для отримання загальної кількості рейсів за певний місяць
select count(*) as TotalFlights
from Flights
where year(Departure_time) = 2025 and month(Departure_time) = 3;
go
select f.*
from Flights f
join Tickets t on f.Id = t.Flight_id
where cast(f.Departure_time as date) = cast(getdate() as date)
  and t.Class = 'Business'
  and t.Passenger_id is null;
go
select f.Id as FlightId, f.Name as FlightName, count(t.Id) as NumberOfSoldTickets, sum(t.Price) as TotalAmount
from Flights f
join Tickets t on f.Id = t.Flight_id
where cast(f.Departure_time as date) = '2025-03-01'
group by f.Id, f.Name;
go
select f.Id as FlightId, f.Name as FlightName, count(t.Id) as NumberOfSoldTickets
from Flights f
left join Tickets t on f.Id = t.Flight_id and t.Passenger_id is not null
where cast(f.Departure_time as date) = '2025-03-01'
group by f.Id, f.Name;
go
select Id as FlightNumber, Arrival as CityName
from Flights;

use master;
go
drop database Airport;

