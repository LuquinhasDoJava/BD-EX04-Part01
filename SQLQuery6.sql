CREATE DATABASE projetos
GO
USE projetos
GO

CREATE TABLE users (
id        INT         NOT NULL  IDENTITY(1,1),
name      VARCHAR(45) NOT NULL,
username  VARCHAR(45) NOT NULL  UNIQUE,
password  VARCHAR(45) NOT NULL  DEFAULT '123mudar',
email     VARCHAR(45) NOT NULL,
PRIMARY KEY (id)
);

CREATE TABLE projects (
id          INT         NOT NULL IDENTITY(10001,1),
name        VARCHAR(45) NOT NULL,
description VARCHAR(45) NULL,
date        DATE        NOT NULL  CHECK (date > '2014/09/01'),
PRIMARY KEY (id)
);
GO 

CREATE TABLE users_has_projects (
users_id    INT NOT NULL,
projects_id INT NOT NULL,
PRIMARY KEY (users_id, projects_id),
FOREIGN KEY (users_id) REFERENCES users(id),
FOREIGN KEY (projects_id) REFERENCES projects(id)
);


DECLARE @constraint_name NVARCHAR(255);
SELECT @constraint_name = CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'users' AND CONSTRAINT_TYPE = 'UNIQUE';
EXEC('ALTER TABLE users DROP CONSTRAINT ' + @constraint_name);
ALTER TABLE users ALTER COLUMN username VARCHAR(10) NOT NULL;
ALTER TABLE users ADD CONSTRAINT UQ_users_username UNIQUE (username);

ALTER TABLE users ALTER COLUMN password VARCHAR(8) NOT NULL;

INSERT INTO users(name,username,password,email) VALUES 
('Maria','Rh_maria','123mudar','maria@empresa.com'),
('Paulo','Ti_paulo','123@456','paulo@empresa.com'),
('Ana','Rh_ana','123mudar','ana@empresa.com'),
('Clara','Ti_clara','123mudar','clara@empresa.com'),
('Aparecido','Rh_apareci','55@!cido','aparecido@empresa.com');

INSERT INTO projects(name,description,date) VALUES
('Re-folha','Refatoração das Folhas','05/09/2014'),
('Manutenção PC ́s','Manutenção PC ́s','06/09/2014'),
('Auditoria',NULL,'07/09/2014');
GO

INSERT INTO users_has_projects(users_id,projects_id) VALUES
(1,10001),
(5,10001),
(3,10003),
(4,10002),
(2,10002);

UPDATE projects
SET date = '12/09/2014'
WHERE id = 10002;

UPDATE users
SET username = 'Rh_cido'
WHERE username LIKE '%apareci';

UPDATE users
SET password = '888@*'
WHERE username = 'Rh_maria' and password = '123mudar';

DELETE FROM users_has_projects
WHERE users_id = 2 AND projects_id = 10002;


INSERT INTO users(name,username,password,email) VALUES
('Joao','Ti_joao','123mudar','joao@empresa.com');

INSERT INTO projects(name,description,date) VALUES
('Atualização de Sistemas','Modificação de Sistemas Operacionais nos PCs','12/09/2014');

SELECT COUNT(projects.id) AS qty_projects_no_users
FROM projects
LEFT JOIN users_has_projects us ON us.projects_id = projects.id
WHERE us.projects_id IS NULL;


SELECT projects.id, projects.name, COUNT(users.id) as qty_users_project
FROM projects 
LEFT JOIN users_has_projects ON users_has_projects.projects_id = projects.id
LEFT JOIN users ON users.id = users_has_projects.users_id
GROUP BY projects.name, projects.id
ORDER BY projects.name ASC;


SELECT * FROM projects;
SELECT * FROM users_has_projects;
SELECT * FROM users;
