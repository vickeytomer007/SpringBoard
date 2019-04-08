/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT  name FROM FACILITIES WHERE MEMBERCOST<>0

/* Q2: How many facilities do not charge a fee to members? */

SELECT  COUNT(name) AS zero_membercost FROM FACILITIES WHERE MEMBERCOST=0


/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT  distinct facid, name as facility_name, membercost,monthlymaintenance  FROM FACILITIES WHERE 1=1
and MEMBERCOST<>0
and membercost<(0.2*monthlymaintenance)


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */


SELECT  * FROM FACILITIES WHERE facid in (1,5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT  name,case when monthlymaintenance>100 then 'expensive' else 'cheap' end as Labelled FROM FACILITIES WHERE 1=1 


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT  top 1 firstname,surname FROM MEMBERS order by joindate desc
>or
SELECT     firstname, surname FROM    members WHERE    joindate = (SELECT 
            MAX(joindate)    FROM   members);

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT distinct name as [court name],firstname+' '+surname as [member name] FROM MEMBERS MB
JOIN BOOKINGS BS ON MB.MEMID=BS.MEMID
JOIN FACILITIES FS ON FS.FACID=BS.FACID
where 1=1 
and name like '%Tennis%'
order by (firstname+' '+surname)


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT     f.name AS facility_name,
    CONCAT(m.firstname, ' ', m.surname) AS member_ID,
    CASE
        WHEN m.memid != 0 THEN b.slots * f.membercost
        WHEN m.memid = 0 THEN b.slots * f.guestcost
    END AS cost
FROM   members m
        JOIN    bookings b ON m.memid = b.memid
        JOIN    facilities AS f ON b.facid = f.facid
WHERE    b.starttime >= '2012-09-14'
        AND b.starttime < '2012-09-15'
        AND ((m.memid != 0
        AND b.slots * f.membercost > 30)
        OR (m.memid = 0
        AND b.slots * f.guestcost > 30))
ORDER BY cost DESC;


/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT     sub.name AS facility_name,
    sub.member AS member_ID,
    sub.cost AS cost
FROM    (SELECT 
        CONCAT(m.firstname, ' ', m.surname) AS member,
            f.name,
            CASE
                WHEN m.memid != 0 THEN b.slots * f.membercost
                WHEN m.memid = 0 THEN b.slots * f.guestcost
            END AS cost
    FROM        members m
    JOIN bookings b ON m.memid = b.memid
    JOIN facilities f ON b.facid = f.facid
    WHERE        b.starttime >= '2012-09-14'
            AND b.starttime < '2012-09-15'
    HAVING cost > 30) AS sub
ORDER BY cost DESC;


/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT     facility_name, revenue AS total_revenue
FROM    (SELECT 
        SUM(CASE
                WHEN b.memid != 0 THEN b.slots * f.membercost
                WHEN b.memid = 0 THEN b.slots * f.guestcost
            END) AS revenue,
            f.name AS facility_name
    FROM        bookings b
    JOIN facilities f ON b.facid = f.facid
    GROUP BY f.name
    HAVING revenue < 1000) AS sub
ORDER BY revenue;
