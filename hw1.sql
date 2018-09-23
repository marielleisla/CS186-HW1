DROP VIEW IF EXISTS q0, q1i, q1ii, q1iii, q1iv, q2i, q2ii, q2iii, q3i, q3ii, q3iii, q4i, q4ii, q4iii, q4iv, q4v;

-- Question 0
CREATE VIEW q0(era) 
AS
  SELECT MAX(era)
  FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE namefirst ~ '.* .*';
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(*)
  FROM people
  GROUP BY birthyear
  ORDER BY birthyear ASC
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height) as ah, COUNT(*)
  FROM people
  GROUP BY birthyear
  HAVING AVG(height) > 70
  ORDER BY birthyear ASC
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT p.namefirst, p.namelast, p.playerid, h.yearid
  FROM people as p, HallofFame as h
  WHERE p.playerid = h.playerid AND inducted = 'Y'
  ORDER BY h.yearid DESC
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT p.namefirst, p.namelast, p.playerid, c.schoolid, h.yearid
  FROM people as p, HallofFame as h, CollegePlaying as c, schools as s
  WHERE p.playerid = h.playerid AND inducted = 'Y' AND p.playerid = c.playerid
    AND c.schoolid = s.schoolid AND s.schoolstate = 'CA'
  ORDER BY h.yearid DESC, c.schoolid, p.playerid
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT p.playerid, p.namefirst, p.namelast, c.schoolid
  FROM people as p LEFT OUTER JOIN CollegePlaying as c
  ON (p.playerid = c.playerid), HallofFame as h
  WHERE p.playerid = h.playerid AND inducted = 'Y'
  ORDER BY p.playerid DESC, c.schoolid ASC
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT p.playerid, p.namefirst, p.namelast, b.yearid, 
  ((b.h - b.h2b - b.h3b - b.hr) + 2*b.h2b + 3*b.h3b + 4*b.hr)/CAST(b.ab as FLOAT) as slg
  FROM people as p, batting as b
  WHERE p.playerid = b.playerid AND b.ab > 50
  ORDER BY slg DESC, b.yearid, p.playerid
  LIMIT 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  WITH stats as (
    SELECT ((SUM(b.h) - SUM(b.h2b) - SUM(b.h3b) - SUM(b.hr)) + 2*SUM(b.h2b) + 3*SUM(b.h3b) + 4*SUM(b.hr))
    /CAST(SUM(b.ab) as FLOAT) as lslg, SUM(b.ab) as ab, p.playerid
    FROM people as p, batting as b
    WHERE p.playerid = b.playerid and b.ab > 0
    GROUP BY p.playerid
    )
  SELECT p.playerid, p.namefirst, p.namelast, stats.lslg
  FROM people as p, stats
  WHERE p.playerid = stats.playerid AND stats.ab > 50
  ORDER BY stats.lslg DESC, p.playerid
  LIMIT 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  WITH stats as (
    SELECT ((SUM(b.h) - SUM(b.h2b) - SUM(b.h3b) - SUM(b.hr)) + 2*SUM(b.h2b) + 3*SUM(b.h3b) + 4*SUM(b.hr))
    /CAST(SUM(b.ab) as FLOAT) as lslg, SUM(b.ab) as ab, p.playerid
    FROM people as p, batting as b
    WHERE p.playerid = b.playerid and b.ab > 0
    GROUP BY p.playerid
    ), player as (
    SELECT ((SUM(b2.h) - SUM(b2.h2b) - SUM(b2.h3b) - SUM(b2.hr)) + 2*SUM(b2.h2b) + 3*SUM(b2.h3b) + 4*SUM(b2.hr))
    /CAST(SUM(b2.ab) as FLOAT) as lslg, b2.playerid
    FROM batting as b2
    WHERE b2.playerid = 'mayswi01' AND b2.ab > 0
    GROUP BY b2.playerid
    )
  SELECT p2.namefirst, p2.namelast, stats.lslg
  FROM people as p2, stats, player
  WHERE p2.playerid = stats.playerid AND stats.ab > 50 AND stats.lslg > player.lslg
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg, stddev)
AS
  SELECT yearid, MIN(salary), MAX(salary), AVG(salary), STDDEV(salary)
  FROM salaries
  GROUP BY yearid
  ORDER BY yearid ASC
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  WITH stats as (
    SELECT min(salary) as min, max(salary) as max
    FROM salaries
    WHERE yearid = 2016)
  SELECT width_bucket(s.salary, stats.min, stats.max + 1, 10) - 1 as id, min(s.salary), max(s.salary), count(s.salary)
  FROM salaries as s , stats
  WHERE s.yearid = 2016
  GROUP BY id
  ORDER BY id
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  SELECT s.yearid, min(s.salary) - min(prev.salary),
    max(s.salary) - max(prev.salary),
    avg(s.salary) - avg(prev.salary)
  FROM salaries as s, salaries as prev
  WHERE s.yearid = prev.yearid + 1
  GROUP BY s.yearid
  ORDER BY s.yearid
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  WITH stats as (
    SELECT max(salary) as max, yearid
    FROM salaries
    WHERE yearid = 2001 OR yearid = 2000
    GROUP BY yearid
    )
  SELECT p.playerid, p.namefirst, p.namelast, s.salary, s.yearid
  FROM people as p, salaries as s, stats
  WHERE p.playerid = s.playerid
    AND s.yearid = stats.yearid 
    AND (s.yearid = 2001 OR s.yearid = 2000)
    AND s.salary = stats.max
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  WITH stats as (
    SELECT a.teamid, a.playerid, s.salary
    FROM allstarfull as a, salaries as s
    WHERE s.yearid = 2016 AND s.yearid = a.yearid
      AND s.teamid = a.teamid AND s.playerid = a.playerid
    )
  SELECT teamid, max(salary) - min(salary)
  FROM stats
  GROUP BY teamid
  ORDER BY teamid
;

