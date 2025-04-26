set search_path to fb;

-- Текущая турнирная таблица
create or replace view league_table as 
with 
team_info as (
select
	t.team_id,
    count(case when m.home_team_id = t.team_id or m.guest_team_id = t.team_id then 1 end) as matches,
    sum(
    	case 
        	when m.home_team_id = t.team_id then m.home_team_scored - m.guest_team_scored
        	when m.guest_team_id = t.team_id then m.guest_team_scored - m.home_team_scored
        	else 0
    	end
	) as goal_diff,
    sum(
        case 
            when m.home_team_id = t.team_id and m.home_team_scored > m.guest_team_scored then 3
            when m.guest_team_id = t.team_id and m.home_team_scored < m.guest_team_scored then 3
            when m.home_team_scored = m.guest_team_scored and (m.home_team_id = t.team_id or m.guest_team_id = t.team_id) then 1
            else 0
        end
    ) as total_points
from teams t
left join matches m 
    on t.team_id = m.home_team_id or t.team_id = m.guest_team_id
group by t.team_id
)
select
    rank() over ( order by ti.total_points desc, ti.goal_diff desc) as rank,
    t.name as team,
    ti.matches,
    ti.total_points as points,
    ti.goal_diff as goal_diff
from teams t
left join team_info ti using (team_id)
order by rank

-- Информация об игроках
create or replace view players_info as
select 
    p.name as name,
    t.name as club,
    p.nationality,
	extract(year from age(current_date, p.date_of_birth)) as age,
	p.salary as salary,
    pt.valid_from as signed_date
from players p
join players_teams pt using(player_id)
join teams t using(team_id)
where current_date between pt.valid_from and pt.valid_to
order by name
