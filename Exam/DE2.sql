CREATE DATABASE DE2

USE DE2

CREATE TABLE NHANVIEN
(
	MANV CHAR(5) PRIMARY KEY,
	HOTEN VARCHAR(25),
	NGVL SMALLDATETIME,
	HSLUONG NUMERIC(4,2),
	MAPHONG CHAR(5)
)

ALTER TABLE NHANVIEN
ADD CONSTRAINT FK_NV_PB FOREIGN KEY (MAPHONG)
REFERENCES PHONGBAN (MAPHONG)

CREATE TABLE PHONGBAN
(
	MAPHONG CHAR(5) PRIMARY KEY,
	TENPHONG VARCHAR(5),
	TRUONGPHONG CHAR(5)
)

CREATE TABLE XE
(
	MAXE CHAR(5) PRIMARY KEY,
	LOAIXE VARCHAR(20),
	SOCHONGOI INT,
	NAMSX INT
)

CREATE TABLE PHANCONG
(
	MAPC CHAR(5) PRIMARY KEY, 
	MANV CHAR(5) ,
	MAXE CHAR(5) ,
	NGAYDI SMALLDATETIME,
	NGAYVE SMALLDATETIME,
	NOIDEN VARCHAR(25)
)

ALTER TABLE PHANCONG
ADD CONSTRAINT FK_PC_NV FOREIGN KEY (MANV)
REFERENCES NHANVIEN (MANV)

ALTER TABLE PHANCONG
ADD CONSTRAINT FK_PC_X FOREIGN KEY (MAXE)
REFERENCES XE (MAXE)


CREATE TRIGGER I_U_X
ON XE
FOR INSERT, UPDATE
AS
BEGIN
	IF (EXISTS ( SELECT *
				FROM INSERTED I 
				WHERE LOAIXE = 'Toyota' AND NAMSX < 2006
				)
		)
		BEGIN
		PRINT 'NAMSX CUA XE TOYOTA >= 2006'
		ROLLBACK TRANSACTION
		END
	ELSE
		BEGIN
		PRINT ' THEM HOA SUA THANH CONG'
		END
END;


CREATE TRIGGER U_NV
ON NHANVIEN
FOR UPDATE 
AS
BEGIN
	IF ( EXISTS (SELECT *
				FROM INSERTED I JOIN PHONGBAN PB ON I.MAPHONG = PB.MAPHONG
					JOIN PHANCONG PC ON PC.MANV = I.MANV
					JOIN XE X ON X.MAXE = PC.MAXE
				WHERE TENPHONG = 'Ngoai thanh' AND LOAIXE <> 'Toyota'
				)
		)
		BEGIN
		PRINT 'NHANVIEN THUOC PHONG NGOAITHANH CHI DUOC PHANCONG LAI LOAIXE TOYOTA'
		ROLLBACK TRANSACTION 
		END
	ELSE
		BEGIN 
		PRINT 'THEM HOAC SUA THANH CONG'
		END
END;

CREATE TRIGGER I_U_PC
ON PHANCONG
FOR UPDATE, INSERT 
AS
BEGIN
	IF ( EXISTS (SELECT *
				FROM INSERTED I JOIN XE X ON X.MAXE = I.MAXE
				JOIN NHANVIEN NV ON NV.MANV = I.MANV
				JOIN PHONGBAN PB ON NV.MAPHONG = PB.MAPHONG
	
				WHERE TENPHONG = 'Ngoai thanh' AND LOAIXE <> 'Toyota'
				)
		)
		BEGIN
		PRINT 'NHANVIEN THUOC PHONG NGOAITHANH CHI DUOC PHANCONG LAI LOAIXE TOYOTA'
		ROLLBACK TRANSACTION 
		END
	ELSE
		BEGIN 
		PRINT 'THEM HOAC SUA THANH CONG'
		END
END;


SELECT NV.MANV, HOTEN
FROM NHANVIEN NV JOIN PHONGBAN PB ON PB.MAPHONG = NV.MAPHONG 
	join PHANCONG PC ON PC.MANV = NV.MANV
	JOIN XE X ON X.MAXE = PC.MAXE
WHERE TENPHONG = 'Noi thanh'  AND LOAIXE= 'Toyota' and SOCHONGOI = 4



SELECT NV.MANV, HOTEN
FROM NHANVIEN NV JOIN PHONGBAN PB ON PB.TRUONGPHONG = NV.MANV
WHERE NOT EXISTS (SELECT *
					FROM XE
					WHERE NOT EXISTS ( SELECT *
										FROM PHANCONG
										WHERE PHANCONG.MANV = NV.MANV AND XE.MAXE = PHANCONG.MAXE
										)
				)


SELECT NV.MANV, HOTEN
FROM PHONGBAN PB JOIN NHANVIEN NV ON NV.MAPHONG = PB.MAPHONG
		JOIN PHANCONG PC ON PC.MANV = NV.MANV
		JOIN XE X ON X.MAXE = PC.MAXE
WHERE LOAIXE = 'Toyota'
GROUP BY PB.MAPHONG, NV.MANV, HOTEN
HAVING COUNT(LOAIXE) >= 1


SELECT NV.MANV, HOTEN
FROM PHONGBAN PB JOIN NHANVIEN NV ON NV.MAPHONG = PB.MAPHONG
		JOIN PHANCONG PC ON PC.MANV = NV.MANV
		JOIN (
					SELECT COUNT(*) SL , MAXE
					FROM (	SELECT X.MAXE
							FROM XE X JOIN PHANCONG PC ON X.MAXE = PC.MAXE
							WHERE LOAIXE = 'Toyota'
						) AS T
					GROUP BY MAXE
				) AS B ON B.MAXE = PC.MAXE
WHERE SL >= 1
GROUP BY PB.MAPHONG, NV.MANV, HOTEN

