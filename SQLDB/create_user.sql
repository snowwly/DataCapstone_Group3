
CREATE USER Bionic_blobs
FROM LOGIN Bionic_blobs

EXEC sp_addrolemember 'db_owner', 'Bionic_blobs'