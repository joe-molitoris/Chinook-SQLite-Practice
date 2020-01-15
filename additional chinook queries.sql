#Which artists did not make any albums at all? Include their names in your answer.
SELECT Name
FROM artists ar
LEFT OUTER JOIN albums al
ON al.ArtistId = ar.ArtistId
WHERE al.ArtistId IS NULL

#Which artists did not record any tracks of the Latin genre?
SELECT DISTINCT(ar.Name)
FROM artists ar
LEFT JOIN (SELECT al.Name
          FROM albums al
          LEFT JOIN tracks tr
          ON tr.AlbumId = ar.AlbumId
          LEFT JOIN genres ge
          ON ge.GenreId = tr.GenreId
          WHERE ge.Name != "Latin") x
ON x.ArtistId = ar.ArtistId

#Which video track has the longest length?
SELECT Name, (MAX(Milliseconds)/1000)/60 AS Minutes
FROM tracks
WHERE MediaTypeId == 3

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
