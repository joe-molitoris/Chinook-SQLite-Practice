#Provide a query showing customers (full names, customer ID, and country) who are not in the US.
SELECT CustomerId, Country, FirstName ||" "|| LastName AS FullName
FROM customers
WHERE Country != "United States"

# Provide a query only showing customers from Brazil.
SELECT CustomerId, FirstName, LastName
FROM customers
WHERE country = "Brazil"

#Provide a query showing the Invoices of customers who are from Brazil. 
#The resultant table should show the customer's full name, Invoice ID, Date of the invoice and billing country.
SELECT inv.InvoiceId, inv.InvoiceDate, inv.BillingCountry, cu.FirstName ||" "|| cu.LastName AS FullName
FROM invoices inv
LEFT JOIN customers cu
ON cu.CustomerId = inv.CustomerId
WHERE inv.BillingCountry = "Brazil"

#Provide a query showing only the Employees who are Sales Agents.
SELECT *
FROM employees
WHERE Title LIKE "%Agent%"

#Provide a query showing a unique list of billing countries from the Invoice table
SELECT DISTINCT(BillingCountry) AS Country
FROM invoices

#Provide a query that shows the invoices associated with each sales agent. The resultant table should include the Sales Agent's full name.
SELECT inv.InvoiceId, em.FirstName ||" "|| em.LastName AS AgentName
FROM invoices inv, employees em, customers cu
WHERE cu.SupportRepId = em.EmployeeId
AND cu.CustomerId = inv.CustomerId

#Provide a query that shows the Invoice Total, Customer name, Country and Sale Agent name for all invoices and customers.
SELECT inv.InvoiceId, cu.FirstName ||" "|| cu.LastName AS CustomerName, cu.Country, em.FirstName ||" "|| em.LastName AS AgentName, inv.Total
FROM invoices inv, customers cu, employees em
WHERE cu.SupportRepId = em.EmployeeId
AND cu.CustomerId = inv.CustomerId

#How many Invoices were there in 2009 and 2011? What are the respective total sales for each of those years?
SELECT strftime('%Y', InvoiceDate) AS Year, COUNT(*) AS TotalInvoices, ROUND(SUM(Total)) AS TotalSales
FROM invoices
WHERE InvoiceDate LIKE "2009%"
OR InvoiceDate LIKE "2011%"
GROUP BY Year

#Looking at the InvoiceLine table, provide a query that COUNTs the number of line items for Invoice ID 37.
SELECT COUNT(*) AS TotalItems
FROM invoice_items
WHERE InvoiceId = 37

#Looking at the InvoiceLine table, provide a query that COUNTs the number of line items for each Invoice. HINT: GROUP BY
SELECT InvoiceId, COUNT(*) AS TotalItems
FROM invoice_items
GROUP BY InvoiceId

#Provide a query that includes the track name with each invoice line item.
SELECT inv.InvoiceId, tr.Name
FROM invoice_items inv
LEFT JOIN tracks tr
ON tr.TrackId = inv.TrackId

#Provide a query that includes the purchased track name AND artist name with each invoice line item.
SELECT inv.InvoiceId, tr.Name AS TrackName, ar.Name as Artist
FROM invoice_items inv
LEFT JOIN tracks tr
ON tr.TrackId = inv.TrackId
LEFT JOIN albums al
ON tr.AlbumId = al.AlbumId
LEFT JOIN artists ar
ON al.ArtistId = ar.ArtistId

#Provide a query that shows the # of invoices per country.
SELECT BillingCountry, COUNT(*) AS TotalInvoices
FROM invoices
GROUP BY BillingCountry

#Provide a query that shows the total number of tracks in each playlist. The Playlist name should be included on the resultant table.
SELECT pl.Name, COUNT(*) AS TotalTracks
FROM playlist_track plst
LEFT JOIN playlists pl
ON pl.PlaylistId = plst.PlaylistId
GROUP BY pl.PlaylistId

#Provide a query that shows all the Tracks, but displays no IDs. The resultant table should include the Album name, Media type and Genre.
SELECT tr.Name AS Track, al.Title AS Album, mt.Name AS MediaType, ge.Name as Genre
FROM tracks tr, albums al, media_types mt, genres ge
WHERE tr.AlbumId = al.AlbumId
AND tr.MediaTypeId = mt.MediaTypeId
AND tr.GenreId = ge.GenreId

#Provide a query that shows all Invoices but includes the # of invoice line items.
SELECT inv.InvoiceId, COUNT(invit.InvoiceId) AS NumItems
FROM invoices inv
LEFT JOIN invoice_items invit
ON inv.InvoiceId = invit.InvoiceId
GROUP BY inv.InvoiceId                                    

#Provide a query that shows total sales made by each sales agent.
SELECT em.EmployeeId, SUM(inv.Total) AS TotalSales
FROM (SELECT EmployeeId
      FROM employees
      WHERE Title LIKE "%Agent%") em
LEFT JOIN customers cu
ON cu.SupportRepId = em.EmployeeId
LEFT JOIN invoices inv
ON inv.CustomerId = cu.CustomerId
GROUP BY em.EmployeeId

#Which sales agent made the most in sales in 2009?
SELECT em.SalesAgent AS Agent, MAX(TotalSales) AS Sales
FROM (SELECT em.FirstName ||" "|| em.LastName AS SalesAgent, SUM(inv.Total) AS TotalSales
      FROM employees em
      LEFT JOIN customers cu
      ON cu.SupportRepId = em.EmployeeId
      LEFT JOIN invoices inv
      ON inv.CustomerId = cu.CustomerId
      WHERE inv.InvoiceDate LIKE "2009%"
      GROUP BY em.EmployeeId)

#Which sales agent made the most in sales in 2010?
SELECT SalesAgent, MAX(TotalSales) AS Sales
FROM (SELECT em.FirstName ||" "|| em.LastName AS SalesAgent, SUM(inv.Total) AS TotalSales
      FROM employees em
      LEFT JOIN customers
      ON cu.SupportRepID = em.EmployeeId
      LEFT JOIN invoices inv
      ON inv.CustomerId = cu.CustomerId
      WHERE inv.InvoiceDate LIKE "2010%"
      GROUP BY em.EmployeeId)
                                                                                 
#Which sales agent made the most in sales over all?
SELECT SalesAgent, MAX(TotalSales) as Sales
FROM (SELECT em.FirstName ||" "|| em.LastName AS SalesAgent, SUM(inv.Total) AS TotalSales
      FROM employees em
      LEFT JOIN customers cu
      ON cu.SupportRepId = em.EmployeeId
      LEFT JOIN invoices inv
      ON inv.CustomerId = cu.CustomerId
      GROUP BY em.EmployeeId)
                                                                                 
#Provide a query that shows the # of customers assigned to each sales agent.
SELECT em.EmployeeId, SalesAgent, COUNT(cu.EmployeeId) AS TotalCustomers
FROM (SELECT EmployeeId, FirstName ||" "|| LastName AS SalesAgent
      FROM employees
      WHERE Title LIKE "%Agent%") em
LEFT JOIN customers cu
ON cu.SupportRepId = em.EmployeeId
GROUP BY em.EmployeeId

#Provide a query that shows the total sales per country.
SELECT cu.Country, SUM(inv.Total) AS TotalSales
FROM customers cu
LEFT JOIN invoices inv
ON inv.CustomerId = cu.CustomerId
GROUP BY cu.Country
                                                                                 
#Which country's customers spent the most?
SELECT cu.Country, MAX(TotalSales) AS Sales 
FROM (SELECT cu.Country, SUM(inv.Total) AS TotalSales
      FROM customers cu
      LEFT JOIN invoices inv
      ON inv.CustomerId = cu.CustomerId
      GROUP BY cu.CustomerId)

#Provide a query that shows the most purchased track of 2013.
SELECT TrackName, MAX(TotalSales) AS Sales
FROM (SELECT tr.Name AS TrackName, COUNT(invit.TrackId) AS TotalSales
      FROM tracks tr
      LEFT JOIN invoice_items invit
      ON invit.TrackId = tr.TrackId
      LEFT JOIN invoices inv
      ON inv.InvoiceId = invit.InvoiceId
      WHERE inv.InvoiceDate LIKE "2013%"
      GROUP BY tr.TrackId)

#Provide a query that shows the top 5 most purchased tracks over all.
SELECT tr.Name as TrackName, COUNT(tr.TrackId) AS TotalSales
FROM tracks tr
LEFT JOIN invoice_items invit
ON invit.TrackId = tr.TrackId
GROUP BY tr.TrackId
ORDER BY TotalSales DESC
LIMIT 5                           

#Provide a query that shows the top 3 best selling artists.
SELECT ar.Name as Artist, COUNT(invit.TrackId) AS TotalSales
FROM artists ar
LEFT JOIN albums al
ON al.ArtistId = ar.ArtistId                            
LEFT JOIN tracks tr
ON tr.AlbumId = al.AlbumId
LEFT JOIN invoice_items invit
ON invit.TrackId = tr.TrackId
GROUP BY ar.ArtistId
ORDER BY TotalSales DESC
LIMIT 3

#Provide a query that shows the most purchased Media Type.
SELECT MediaType, MAX(Purchases) AS TotalPurchases
FROM (SELECT mt.Name AS MediaType, COUNT(*) AS Purchases
      FROM media_types mt
      LEFT JOIN tracks tr
      ON tr.MediaTypeId = mt.MediaTypeId
      JOIN invoice_items invit
      ON invit.TrackId = tr.TrackId
      GROUP BY MediaType)

#Provide a query that shows the number tracks purchased in all invoices that contain more than one genre.
SELECT inv.InvoiceId, COUNT(*) AS TracksPurchased, NumGenres
FROM invoices inv                                                                                 
INNER JOIN (SELECT invit.InvoiceId, COUNT(DISTINCT(tr.GenreId)) AS NumGenres
            FROM invoice_items invit
            LEFT JOIN tracks tr                                                                    
            ON invit.TrackId = tr.TrackId
            GROUP BY invit.InvoiceId
            HAVING NumGenres > 1) test
ON inv.InvoiceId = test.InvoiceId
LEFT JOIN invoice_items invit
ON inv.InvoiceId = invit.InvoiceId
GROUP BY inv.InvoiceId                                                                                 
                                                                                 
                                                                                 
                                                                                 
                                                                                 
