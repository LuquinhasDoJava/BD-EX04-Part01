CREATE DATABASE locadora;
GO
USE locadora;
GO

CREATE TABLE filme (
id		INT			NOT NULL,
titulo	VARCHAR(40)	NOT NULL,
ano		INT			NULL	CHECK (ano<2021),
PRIMARY KEY (id)
);

CREATE TABLE cliente (
num_cadastro	INT				NOT NULL,
nome			VARCHAR(70)		NOT NULL,
logradouro		VARCHAR(150)	NOT NULL,
num				INT				NOT NULL	CHECK (num>0),
cep				CHAR(8)			NULL	CHECK(LEN(cep)=8),
PRIMARY KEY (num_cadastro)
);

CREATE TABLE estrela (
id		INT			NOT NULL,
nome	VARCHAR(50)	NOT NULL,
PRIMARY KEY (id)
);
GO

CREATE TABLE filme_estrela (
filmeid		INT	NOT NULL,
estrelaid	INT NOT NULL,
PRIMARY KEY (filmeid, estrelaid),
FOREIGN KEY (filmeid) REFERENCES filme(id),
FOREIGN KEY (estrelaid) REFERENCES estrela(id)
);

CREATE TABLE dvd (
num				INT		NOT NULL,
data_fabricacao	DATE	NOT NULL	CHECK (data_fabricacao<GETDATE()),
filmeid			INT		NOT NULL,
PRIMARY KEY (num),
FOREIGN KEY (filmeid) REFERENCES filme(id)
);

CREATE TABLE locacao (
dvdnum				INT				NOT NULL,
clientenum_cadastro	INT				NOT NULL,
data_locacao		DATE			NOT NULL	DEFAULT(GETDATE()),
data_devolucao		DATE			NOT NULL,
valor				DECIMAL(7,2)	NOT NULL	CHECK (valor>0),
PRIMARY KEY (dvdnum,clientenum_cadastro,data_locacao),
FOREIGN KEY (dvdnum) REFERENCES dvd(num),
FOREIGN KEY (clientenum_cadastro) REFERENCES cliente(num_cadastro),
);
GO

ALTER TABLE locacao
ADD CONSTRAINT chk_data
CHECK (data_devolucao>data_locacao);



ALTER TABLE estrela
ADD nome_real VARCHAR(50) NULL;

ALTER TABLE filme
ALTER COLUMN titulo VARCHAR(80) NOT NULL;

INSERT INTO filme(id, titulo, ano) VALUES
(1001,'Whiplash',2015),
(1002,'Birdman',2015),
(1003,'Interestelar',2014),
(1004,'A Culpa é das estrelas',2014),
(1005,'Alexandre e o Dia Terrível, Horrível,Espantoso e Horroroso',2014),
(1006,'Sing',2016);

INSERT INTO estrela(id,nome,nome_real) VALUES
(9901,'Michael Keaton','Michael John Douglas'),
(9902,'Emma Stone','Emily Jean Stone'),
(9903,'Miles Teller',NULL),
(9904,'Steve Carell','Steven John Carell'),
(9905,'Jennifer Garner','Jennifer Anne Garner');

INSERT INTO filme_estrela(filmeid, estrelaid) VALUES
(1002,9901),
(1002,9902),
(1001,9903),
(1005,9904),
(1005,9905);

INSERT INTO dvd(num,data_fabricacao,filmeid) VALUES
(10001,'2020-12-02',1001),
(10002,'2019-10-18',1002),
(10003,'2020-04-03',1003),
(10004,'2020-12-02',1001),
(10005,'2019-10-18',1004),
(10006,'2020-04-03',1002),
(10007,'2020-12-02',1005),
(10008,'2019-10-18',1002),
(10009,'2020-04-03',1003);

INSERT INTO cliente(num_cadastro, nome,logradouro,num, cep) VALUES
(5501,'Matilde Luz','Rua Síria',150,'03086040'),
(5502,'Carlos Carreiro','Rua Bartolomeu Aires ',1250,'04419110'),
(5503,'Daniel Ramalho','Rua Itajutiba',169,NUll),
(5504,'Roberta Bento','Rua Jayme Von Rosenburg',36,NULL),
(5505,'Rosa Cerqueira','Rua Arnaldo Simões Pinto',235,'02917110');

INSERT INTO locacao(dvdnum, clientenum_cadastro, data_locacao, data_devolucao, valor) VALUES
(10001,'5502','2021-02-18','2021-02-21',3.5),
(10009,'5502','2021-02-18','2021-02-21',3.5),
(10002,'5503','2021-02-18','2021-02-19',3.5),
(10002,'5505','2021-02-20','2021-02-23',3),
(10004,'5505','2021-02-20','2021-02-23',3),
(10005,'5505','2021-02-20','2021-02-23',3),
(10001,'5501','2021-02-24','2021-02-26',3.5),
(10008,'5501','2021-02-24','2021-02-26',3.5);

UPDATE cliente
SET cep = CASE
			WHEN num_cadastro = 5503 THEN '08411150'
			WHEN num_cadastro = 5504 THEN '02918190'
		  END
WHERE num_cadastro IN (5503,5504);

--A locação de 2021-02-24 do cliente 5501 teve o valor de 3.10 para cada DVD alugado
UPDATE locacao
SET valor = 3.10
WHERE data_locacao = '2021-02-24' AND clientenum_cadastro = 5501;

--O DVD 10005 foi fabricado em 2019-07-14
UPDATE dvd
SET data_fabricacao = '2019-07-14'
WHERE num = 10005;
SELECT * FROM dvd;

--O nome real de Miles Teller é Miles Alexander Teller
UPDATE estrela
SET nome_real = 'Miles Alexander Teller'
WHERE nome = 'Miles Teller';

--O filme Sing não tem DVD cadastrado e deve ser excluído
DELETE FROM filme
WHERE titulo = 'Sing';

--1) Consultar, num_cadastro do cliente, nome do cliente, titulo do filme, data_fabricação
--do dvd, valor da locação, dos dvds que tem a maior data de fabricação dentre todos os cadastrados.
SELECT TOP 5 num_cadastro, nome, filme.titulo, dvd.data_fabricacao, locacao.valor
FROM cliente
INNER JOIN locacao ON locacao.clientenum_cadastro = cliente.num_cadastro
INNER JOIN dvd ON dvd.num = locacao.dvdnum
INNER JOIN filme ON filme.id = dvd.filmeid
ORDER BY data_fabricacao DESC;

--2) Consultar Consultar, num_cadastro do cliente, nome do cliente, data de locação
--(Formato DD/MM/AAAA) e a quantidade de DVD ́s alugados por cliente (Chamar essa coluna de qtd), por data de locação
SELECT num_cadastro, nome, FORMAT(locacao.data_locacao,'dd/MM/yyyy') AS data_locacao, COUNT(locacao.clientenum_cadastro) AS qtd
FROM cliente
INNER JOIN locacao ON locacao.clientenum_cadastro = clientenum_cadastro
GROUP BY cliente.num_cadastro, cliente.nome, locacao.data_locacao;

--3) Consultar Consultar, num_cadastro do cliente, nome do cliente, data de locação
--(Formato DD/MM/AAAA) e a valor total de todos os dvd ́s alugados (Chamar essa coluna de valor_total), por data de locação
SELECT num_cadastro, nome, FORMAT(locacao.data_locacao,'dd/MM/yyyy') AS data_locacao, SUM(locacao.valor)  AS valor_total
FROM cliente
INNER JOIN locacao ON locacao.clientenum_cadastro = clientenum_cadastro
GROUP BY cliente.num_cadastro, cliente.nome, locacao.data_locacao;

--4) Consultar Consultar, num_cadastro do cliente, nome do cliente, Endereço concatenado de logradouro e numero 
--como Endereco, data de locação (Formato DD/MM/AAAA) dos clientes que alugaram mais de 2 filmes simultaneamente
SELECT num_cadastro, nome, CONCAT(cliente.logradouro,', ',cliente.num,' : ',cliente.cep) AS ende, FORMAT(locacao.data_locacao,'dd/MM/yyyy') AS data_locacao, COUNT(locacao.clientenum_cadastro) AS qtd
FROM cliente
INNER JOIN locacao ON locacao.clientenum_cadastro = clientenum_cadastro
GROUP BY cliente.num_cadastro, cliente.nome, locacao.data_locacao, logradouro, num, cep
HAVING COUNT(*) > 2
ORDER BY data_locacao;


SELECT * FROM locacao;
SELECT * FROM cliente;
SELECT * FROM dvd;
SELECT * FROM filme_estrela;
SELECT * FROM estrela;
SELECT * FROM filme;