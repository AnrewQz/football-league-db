set search_path to fb;

-- 1. Список всех стадионов Москвы, отсортированный по вместимости
select name as stadium, capacity
from stadiums
where city = 'Москва'
order by capacity desc

-- 2. Текущие игроки ФК Машина
select p.name as player, t.name as club
from players p
join (
	select * from players_teams
	where current_date between valid_from and valid_to
)
using (player_id)
join teams t using (team_id)
where t.name = 'ФК Машина'

-- 3. Пять самых результативных матчей и на каком это было стадионе
select h.name as home_team, g.name as guest_team, m.home_team_scored || ':' || m.guest_team_scored as score, s.name as stadium
from matches m
join teams h on h.team_id = home_team_id
join teams g on g.team_id = guest_team_id
join stadiums s on s.stadium_id = m.stadium_id
order by m.home_team_scored + m.guest_team_scored desc
limit 5

-- 4. Средняя зарплата футболистов по разным странам
select nationality, avg(salary)
from players
group by nationality

-- 5. Имена тренеров и их зарплаты, если их зарплата ниже средней зарплаты всех тренеров.
select name, salary
from trainers
where salary < (select avg(salary) from trainers)
order

-- 6. Игроки, которые когда-либо играли в команде из Москвы
select name
from players
where player_id in (
    select player_id
    from players_teams pt
    join teams t on pt.team_id = t.team_id
    where t.city = 'Москва'
)

-- 7. Тренеры, которые работали хотя бы с 2 командами и количество команда, которое они тренировали
select t.name, count(tt.team_id) as team_count
from trainers t
join trainers_teams tt on t.trainer_id = tt.trainer_id
group by t.trainer_id
having count(tt.team_id) > 2

-- 8. Команды, которые в гостях забили больше, чем дома
select t.name, (sum(m_guest.guest_team_scored) - sum(m_home.home_team_scored)) as goal_difference
from teams t
join matches m_home on t.team_id = m_home.home_team_id
join matches m_guest on t.team_id = m_guest.guest_team_id
where m_home.match_id is not null or m_guest.match_id is not null
group by t.team_id, t.name
having sum(m_guest.guest_team_scored) > sum(m_home.home_team_scored)
order by goal_difference desc

-- 9. Игроки, которые наибольшее число дней выступали за один и тот же клуб
select 
    p.name as player_name, 
    t.name as team_name, 
    pt.valid_from, 
    pt.valid_to, 
    (least(pt.valid_to, current_date) - pt.valid_from) as days_in_team
from players p
join players_teams pt on p.player_id = pt.player_id
join teams t on pt.team_id = t.team_id
order by days_in_team desc
limit 5

-- 10. Команды, чьи стадионы самые вместительные
select 
    t.name as team_name, 
    s.name as stadium_name, 
    s.capacity
from teams t
join stadiums s on t.stadium_id = s.stadium_id
order by s.capacity desc
limit 5

-- 11. Игроки и их текущие клубы
select p.name as player, t.name as club
from players p
left join (
	select * from players_teams
	where current_date between valid_from and valid_to
)
using (player_id)
left join teams t using (team_id)

-- 12 ранжирование команд по забитым голам
select 
    t.name as team_name,
    sum(h.home_team_scored) + sum(g.guest_team_scored) as total_goals,
    row_number() over (order by sum(h.home_team_scored) + sum(g.guest_team_scored) desc) as goal_rank
from teams t
join matches h on t.team_id = h.home_team_id
join matches g on t.team_id = g.guest_team_id
group by t.team_id
order by goal_rank
