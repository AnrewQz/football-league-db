set search_path to fb;

create or replace function trigger_add_match()
returns trigger as $$
	begin
		-- проверка 1: существование команд
	    if not exists (select 1 from teams where team_id = new.home_team_id) then
	        raise exception 'домашняя команда с id % не существует', home_team_id;
	    end if;
	    
	    if not exists (select 1 from teams where team_id = new.guest_team_id) then
	        raise exception 'гостевая команда с id % не существует', guest_team_id;
	    end if;
	    
	    -- проверка 2: домашняя и гостевая команды должны быть разными
	    if new.home_team_id = new.guest_team_id then
	        raise exception 'домашняя и гостевая команды не могут быть одинаковыми';
	    end if;
	    
	    -- проверка 3: неотрицательность голов
	    if new.home_team_scored < 0 or new.guest_team_scored < 0 then
	        raise exception 'количество голов не может быть отрицательным';
	    end if;

		return new;
	end;
$$ language plpgsql;

create or replace trigger insert_match 
before insert on matches
for each row
execute function trigger_add_match();

-- insert into matches (home_team_id, guest_team_id, home_team_scored, guest_team_scored) values
--(5, 10, 1, 4),
--(7, 9, 2, 1),
--(1, 2, 3, 0);

create or replace function check_player_team_period()
returns trigger as $$
begin
    if exists (
        select 1
        from players_teams
        where player_id = new.player_id
          and team_id != new.team_id
          and (new.valid_from > valid_from and new.valid_from < valid_to) or
			  (new.valid_from < valid_from and new.valid_to > valid_from)
    ) then
        raise exception 'игрок не может играть в разных командах в пересекающиеся периоды';
    end if;
    return new;
end;
$$ language plpgsql;

create trigger before_insert_update_player_team
before insert or update on players_teams
for each row
execute function check_player_team_period();


create or replace function check_trainer_team_period()
returns trigger as $$
begin
    if exists (
        select 1
        from trainers_teams
        where trainer_id = new.trainer_id
          and team_id != new.team_id
          and (new.valid_from > valid_from and new.valid_from < valid_to) or
              (new.valid_from < valid_from and new.valid_to > valid_from)
    ) then
        raise exception 'тренер не может работать в разных командах в пересекающиеся периоды';
    end if;
    return new;
end;
$$ language plpgsql;

create trigger before_insert_update_trainer_team
before insert or update on trainers_teams
for each row
execute function check_trainer_team_period();

