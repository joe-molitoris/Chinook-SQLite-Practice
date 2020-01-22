#Which artists did not make any albums at all? Include their names in your answer.
SELECT ar.Name
FROM artists ar
WHERE ar.Name NOT IN (SELECT al.Name
                      FROM albums al)

#Which artists did not record any tracks of the Latin genre?
SELECT ar.Name
FROM artists ar
JOIN albums al
ON ar.ArtistId = al.ArtistId
JOIN tracks tr
ON al.AlbumId = tr.AlbumId
JOIN genres ge
ON tr.GenreId = ge.GenreId
GROUP BY ar.ArtistId
HAVING SUM(ge.Name = 'Latin') == 0

#Which video track has the longest length?
SELECT Name
FROM tracks tr
JOIN (SELECT tr.TrackId, MAX(Milliseconds)
      FROM tracks tr
      JOIN media_types mt
      ON tr.MediaTypeId = mt.MediaTypeId
      WHERE mt.MediaTypeId == 3) x
ON tr.TrackId = x.TrackId

#Find the names of customers who live in the same city as the top employee (i.e. the one not managed by anyone).
SELECT cu.FirstNAme||" "||cu.LastName AS CustomerName
FROM employees em
LEFT JOIN customers cu
ON cu.City = em.City
WHERE em.ReportsTo IS NULL

#Find the managers of employees supporting Brazilian customers.
SELECT em.FirstName ||" "|| cu.LastName AS ManagerName
FROM employees em
INNER JOIN (SELECT DISTINCT(em.ReportsTo)
            FROM employees em
            LEFT JOIN customers cu
            ON cu.SupportRepId = em.EmployeeId
            WHERE cu.Country == "Brazil") x
ON x.ReportsTo = em.EmployeeId

#How many audio tracks in total were bought by German customers? And what was the total price paid for them?
SELECT COUNT(*) AS TracksBought, SUM(Total) AS TotalPrice
FROM invoices inv
LEFT JOIN invoice_items invit
ON invit.InvoiceId = inv.InvoiceId
LEFT JOIN tracks tr
ON tr.TrackId = invit.TrackId
WHERE inv.BillingCountry == "Germany"
AND tr.MediaTypeId != 3

#Which playlists have no Latin tracks?
SELECT pl.PlaylistId, pl.Name AS PlaylistName
FROM playlists pl
LEFT JOIN playlist_track pt
ON pt.PlaylistId = pl.PlaylistId
LEFT JOIN tracks tr
ON tr.TrackId = pt.TrackId
LEFT JOIN genres ge
ON ge.GenreId = tr.GenreId
GROUP BY pl.PlaylistId
HAVING SUM(ge.Name == 'Latin') == 0
OR ge.Name IS NULL

#What is the space (in bytes) occupied by the playlist 'Grunge' and how much would it cost? (Assume that the total cost of a playlist is the sum of its constituent tracks)
SELECT SUM(tr.Bytes) AS Size, SUM(tr.UnitPrice) AS TotalPrice
FROM tracks tr
INNER JOIN (SELECT pt.TrackId
            FROM playlists pl
            LEFT JOIN playlist_track pt
            ON pt.PlaylistId = pl.PlaylistId
            WHERE pl.Name == "Grunge") x
ON x.TrackId = tr.TrackId

#Which playlists do not contain any tracks for the artists "AC/DC" or "Chico Buarque"?
SELECT pl.PlaylistId, pl.Name
FROM playlists pl
LEFT JOIN playlist_track pt
ON pl.PlaylistId = pt.PlaylistId
LEFT JOIN tracks tr
ON pt.TrackId = tr.TrackId
LEFT JOIN albums al
ON tr.AlbumId = al.AlbumId
LEFT JOIN artists ar
ON al.ArtistId = ar.ArtistId
GROUP BY pl.PlaylistId
HAVING SUM(ar.Name == 'AC/DC') == 0
AND SUM(ar.Name == 'Chico Buarque') == 0

#Count how many tracks belong to the MediaType "Protected MPEG-4 video file".
SELECT COUNT(*) AS NumberProtected
FROM tracks tr
LEFT JOIN media_types mt
ON tr.MediaTypeId = mt.MediaTypeId
WHERE mt.MediaTypeId == 3

#Find the least expensive Track that has the Genre "Electronica/Dance".
SELECT tr.Name AS TrackName
FROM tracks tr
LEFT JOIN genres ge
ON tr.GenreId = ge.GenreId
WHERE ge.Name = 'Electronica/Dance'
GROUP BY ge.Name
HAVING MIN(tr.UnitPrice)

#Find the all the Artists whose names start with A.
SELECT Name 
FROM artists
WHERE Name LIKE "A%"

#Find all the Tracks that belong to the first Playlist.
SELECT Name
FROM tracks tr
LEFT JOIN playlist_track pt
ON tr.TrackId = pt.TrackId
INNER JOIN playlists pl
ON pl.PlaylistId = pt.PlaylistId
WHERE pl.PlaylistId == 1

#What is the total number of songs and total cost of the songs for the genres Rock, Metal, and Jazz?
SELECT ge.Name AS Genre, COUNT(DISTINCT tr.TrackId) AS NumSongs, SUM(tr.UnitPrice) AS TotalCost
FROM tracks tr
INNER JOIN genres ge
ON tr.GenreId = ge.GenreId
WHERE tr.GenreId IN (SELECT ge.GenreId
                     FROM genres ge
                     WHERE ge.Name IN ('Rock', 'Metal', 'Jazz'))
GROUP BY ge.Name

#Find all the artist names with multiple track genres.
SELECT ar.Name
FROM artists ar
LEFT JOIN albums al
ON ar.ArtistId = al.ArtistId
LEFT JOIN tracks tr
ON al.AlbumId = tr.AlbumId
LEFT JOIN genres ge
ON tr.GenreId = ge.GenreId
GROUP BY ar.ArtistId
HAVING COUNT(DISTINCT ge.GenreId)>1

#Find the First and Last name of the customer who spent the most money.
WITH x AS (SELECT inv.CustomerId, SUM(inv.Total) AS Purchases
           FROM invoices inv
           GROUP BY inv.CustomerId)

SELECT cu.FirstName ||" "|| cu.LastName AS CustomerName
FROM customers cu
INNER JOIN (SELECT x.CustomerId, MAX(x.Purchases)
            FROM x) y
ON cu.CustomerId == y.CustomerId

#Find the First and Last name of the employee who sold the most money.
WITH emp_sales AS (SELECT em.EmployeeId, SUM(Total) AS TotalSales
                   FROM employees em
                   LEFT JOIN customers cu
                   ON em.EmployeeId = cu.SupportRepId
                   LEFT JOIN invoices inv
                   ON cu.CustomerId = inv.CustomerId
                   GROUP BY em.EmployeeId)

SELECT em.FirstName ||" "|| em.LastName AS EmployeeName
FROM employees em
INNER JOIN (SELECT EmployeeId, MAX(TotalSales)
            FROM emp_sales) x
ON em.EmployeeId = x.EmployeeId

#Write a query that lists for each artist and the countries of customers who have bought a track from an album produced by them. Your query should return artist.name and customer.country. Make sure to write your query as to show *no* duplicates.
SELECT DISTINCT cu.Country, ar.Name AS Artist
FROM artists ar
JOIN albums al
ON ar.ArtistId = al.ArtistId
JOIN tracks tr
ON al.AlbumId = tr.AlbumId
JOIN invoice_items invit
ON tr.TrackId = invit.TrackId
JOIN invoices inv
ON invit.InvoiceId = inv.InvoiceId
JOIN customers cu
ON inv.CustomerId = inv.CustomerId
ORDER BY ar.ArtistId
                                       
# Write a query that lists for each artist name the number of different countries for which there is a customer listening to their album.Only show those artists who have customers from at least 10 different countries. For your query, assume that there are artists that have the same name, but different ids(in other words, you cannot assume that names are unique). Sort your result in decreasing number of countries.

WITH art_count AS (SELECT DISTINCT cu.Country, ar.ArtistId
                   FROM artists ar
                   JOIN albums al
                   ON ar.ArtistId = al.ArtistId
                   JOIN tracks tr
                   ON al.AlbumId = tr.AlbumId
                   JOIN invoice_items invit
                   ON tr.TrackId = invit.TrackId
                   JOIN invoices inv
                   ON invit.InvoiceId = inv.InvoiceId
                   JOIN customers cu
                   ON inv.CustomerId = cu.CustomerId)                                                                             
                                       
SELECT ar.Name, COUNT(ac.Country) AS Countries
FROM artists ar                                       
LEFT JOIN art_count ac 
ON ar.ArtistId = ac.ArtistId                                       
GROUP BY ar.ArtistId
HAVING Countries>=10                                       
ORDER BY Countries DESC                     
                                       
