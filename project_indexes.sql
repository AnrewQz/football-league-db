set search_path to fb;

-- индексы на nationality и date_of_birth в таблице players
create index if not exists player_nationality_hash on players using hash(nationality);
create index if not exists player_date_of_birth_index on players using btree(date_of_birth);

-- индексы на даты в таблицах players_teams и trainers_teams
create index if not exists players_teams_from on players_teams using btree(valid_from);
create index if not exists players_teams_to on players_teams using btree(valid_to);
create index if not exists trainers_teams_from on trainers_teams using btree(valid_from);
create index if not exists trainers_teams_to on trainers_teams using btree(valid_to);