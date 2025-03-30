create schema fb;
set search_path to fb;

create table trainers (
    trainer_id integer primary key,
    name varchar(100) not null,
    nationality varchar(100),
    salary integer
);

create table stadiums (
    stadium_id integer primary key,
    name varchar(100) not null,
    city varchar(100) not null,
    capacity integer
);

create table players (
    player_id integer primary key,
    name varchar(100) not null,
    nationality varchar(100),
    salary integer,
    date_of_birth date
);

create table teams (
    team_id integer primary key,
    name varchar(100) not null,
    city varchar(100),
    trainer_id integer,
    stadium_id integer,
    foreign key (trainer_id) references trainers(trainer_id),
    foreign key (stadium_id) references stadiums(stadium_id)
);

create table matches (
    match_id integer primary key,
    home_team_id integer,
    guest_team_id integer,
    stadium_id integer,
    home_team_scored integer not null,
    guest_team_scored integer not null,
    foreign key (home_team_id) references teams(team_id),
    foreign key (guest_team_id) references teams(team_id),
    foreign key (stadium_id) references stadiums(stadium_id)
);

create table trainers_teams (
    trainer_id integer,
    team_id integer,
    valid_from date not null,
    valid_to date not null,
    primary key (trainer_id, team_id),
    foreign key (trainer_id) references trainers(trainer_id),
    foreign key (team_id) references teams(team_id)
);

create table players_teams (
    player_id integer,
    team_id integer,
    valid_from date not null,
    valid_to date not null,
    primary key (player_id, team_id),
    foreign key (player_id) references players(player_id),
    foreign key (team_id) references teams(team_id)
);
