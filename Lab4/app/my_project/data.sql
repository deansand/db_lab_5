DROP DATABASE IF EXISTS lab_1;
CREATE DATABASE lab_1;
USE lab_1;
SHOW PROCEDURE STATUS WHERE Db = 'lab_1';

CREATE TABLE countries (
    country_id INT PRIMARY KEY AUTO_INCREMENT,
    country_name VARCHAR(100) UNIQUE
);

INSERT INTO countries (country_name) VALUES ('USA'), ('South Korea');

CREATE TABLE directors (
    director_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    birth_date DATE,
    nationality VARCHAR(100),
    INDEX (name)
);

CREATE TABLE movies (
    movie_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    release_date DATE,
    descriptions TEXT,
    director_id INT,
    FOREIGN KEY (director_id) REFERENCES directors(director_id) ON DELETE SET NULL,
    INDEX (title)
);

CREATE TABLE actor (
    actor_id INT PRIMARY KEY AUTO_INCREMENT,
    actor_name VARCHAR(255),
    birth_date DATE,
    nationality VARCHAR(100),
    INDEX (actor_name)
);

CREATE TABLE movie_cast (
    movie_id INT,
    actor_id INT,
    role_name VARCHAR(255),
    PRIMARY KEY (movie_id, actor_id, role_name),
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE,
    FOREIGN KEY (actor_id) REFERENCES actor(actor_id) ON DELETE CASCADE,
    INDEX (movie_id, actor_id)
);

CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    password_hash VARCHAR(255),
    registration_date DATE,
    UNIQUE(email),
    INDEX (username)
);

CREATE TABLE reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    movie_id INT,
    user_id INT,
    rating INT CHECK (rating >= 1 AND rating <= 10),
    review_text TEXT,
    review_date DATE,
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX (movie_id, user_id)
);

CREATE TABLE fun_fact (
    fact_id INT PRIMARY KEY AUTO_INCREMENT,
    movie_id INT UNIQUE,
    fact TEXT,
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE,
    INDEX (movie_id)
);

CREATE TABLE money_get (
    movie_id INT,
    country_id INT,
    revenue DECIMAL(15, 2),
    PRIMARY KEY (movie_id, country_id),
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE,
    FOREIGN KEY (country_id) REFERENCES countries(country_id),
    INDEX (country_id)
);

CREATE TABLE gener (
    gener_id INT PRIMARY KEY AUTO_INCREMENT,
    gener_name VARCHAR(100),
    INDEX (gener_name)
);

CREATE TABLE movie_gener (
    movie_id INT,
    gener_id INT,
    PRIMARY KEY (movie_id, gener_id),
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE,
    FOREIGN KEY (gener_id) REFERENCES gener(gener_id) ON DELETE CASCADE,
    INDEX (movie_id, gener_id)
);

-- Add the new table
CREATE TABLE awards (
    award_id INT PRIMARY KEY AUTO_INCREMENT,
    movie_id INT,
    award_name VARCHAR(255) NOT NULL,
    award_year YEAR NOT NULL
);

DELIMITER //

-- Trigger to ensure movie_id exists in movies table before inserting into awards
CREATE TRIGGER before_awards_insert
BEFORE INSERT ON awards
FOR EACH ROW
BEGIN
    DECLARE movie_exists INT;
    SELECT COUNT(*) INTO movie_exists FROM movies WHERE movie_id = NEW.movie_id;
    IF movie_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Movie ID does not exist';
    END IF;
END //

-- Trigger to ensure movie_id exists in movies table before updating awards
CREATE TRIGGER before_awards_update
BEFORE UPDATE ON awards
FOR EACH ROW
BEGIN
    DECLARE movie_exists INT;
    SELECT COUNT(*) INTO movie_exists FROM movies WHERE movie_id = NEW.movie_id;
    IF movie_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Movie ID does not exist';
    END IF;
END //

DELIMITER ;


--Task 2a: Parameterized Insertion into a Table--
DELIMITER //

CREATE PROCEDURE insert_into_awards(IN p_movie_id INT, IN p_award_name VARCHAR(255), IN p_award_year YEAR)
BEGIN
    INSERT INTO awards (movie_id, award_name, award_year) VALUES (p_movie_id, p_award_name, p_award_year);
END //

DELIMITER ;


--Task 2b: Insert into Junction Table Based on Existing Values
DELIMITER //

CREATE PROCEDURE insert_into_movie_cast(IN p_actor_name VARCHAR(255), IN p_movie_title VARCHAR(255), IN p_role_name VARCHAR(255))
BEGIN
    DECLARE v_actor_id INT;
    DECLARE v_movie_id INT;

    SELECT actor_id INTO v_actor_id FROM actor WHERE actor_name = p_actor_name;
    SELECT movie_id INTO v_movie_id FROM movies WHERE title = p_movie_title;

    IF v_actor_id IS NOT NULL AND v_movie_id IS NOT NULL THEN
        INSERT INTO movie_cast (movie_id, actor_id, role_name) VALUES (v_movie_id, v_actor_id, p_role_name);
    END IF;
END //

DELIMITER ;


--Task 2c: Insert into Table with Dynamic Table Name
DELIMITER //

CREATE PROCEDURE insert_noname_rows()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 10 DO
        INSERT INTO some_table (some_column) VALUES (CONCAT('Noname', i));
        SET i = i + 1;
    END WHILE;
END //

DELIMITER ;


--Task 2d: Insert into Table with Dynamic Column Name
DELIMITER //

CREATE FUNCTION custom_aggregate(op VARCHAR(10), tbl VARCHAR(64), col VARCHAR(64))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    SET @query = CONCAT('SELECT ', op, '(', col, ') FROM ', tbl);
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    RETURN @result;
END //

DELIMITER ;


--Task 2e: Call a Custom Aggregate Function
DELIMITER //

CREATE PROCEDURE call_custom_aggregate(op VARCHAR(10), tbl VARCHAR(64), col VARCHAR(64))
BEGIN
    SELECT custom_aggregate(op, tbl, col) AS result;
END //

DELIMITER ;


--Task 2f: Dynamic Table Creation and Data Insertion
DELIMITER //

CREATE PROCEDURE dynamic_table_creation()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_id INT;
    DECLARE v_name VARCHAR(255);
    DECLARE cur CURSOR FOR SELECT id, name FROM some_table;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    SET @table1 = CONCAT('table1_', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'));
    SET @table2 = CONCAT('table2_', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'));

    SET @create_table1 = CONCAT('CREATE TABLE ', @table1, ' LIKE some_table');
    SET @create_table2 = CONCAT('CREATE TABLE ', @table2, ' LIKE some_table');

    PREPARE stmt1 FROM @create_table1;
    EXECUTE stmt1;
    DEALLOCATE PREPARE stmt1;

    PREPARE stmt2 FROM @create_table2;
    EXECUTE stmt2;
    DEALLOCATE PREPARE stmt2;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_id, v_name;
        IF done THEN
            LEAVE read_loop;
        END IF;

        IF RAND() < 0.5 THEN
            SET @insert_query = CONCAT('INSERT INTO ', @table1, ' VALUES (', v_id, ', "', v_name, '")');
        ELSE
            SET @insert_query = CONCAT('INSERT INTO ', @table2, ' VALUES (', v_id, ', "', v_name, '")');
        END IF;

        PREPARE stmt FROM @insert_query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END LOOP;

    CLOSE cur;
END //

DELIMITER ;




INSERT INTO directors (name, birth_date, nationality)
VALUES ('Sample Director', '1970-01-01', 'USA');

INSERT INTO movies (title, release_date, descriptions, director_id)
VALUES ('Sample Movie', '2023-01-01', 'Sample Description', 1);

INSERT INTO awards (movie_id, award_name, award_year)
VALUES (1, 'Best Picture', 2023);

INSERT INTO directors (name, birth_date, nationality)
VALUES
('Christopher Nolan', '1970-07-30', 'UK'),
('The Wachowskis', '1965-06-21', 'USA'),
('Bong Joon-ho', '1969-09-14', 'South Korea');

INSERT INTO movies (title, release_date, descriptions, director_id)
VALUES 
('Inception', '2010-07-16', 'A mind-bending thriller', 1),
('The Matrix', '1999-03-31', 'A dystopian sci-fi classic', 2),
('Parasite', '2019-05-30', 'A dark social satire', 3);

INSERT INTO actor (actor_name, birth_date, nationality)
VALUES
('Leonardo DiCaprio', '1974-11-11', 'USA'),
('Keanu Reeves', '1964-09-02', 'Canada'),
('Song Kang-ho', '1967-01-17', 'South Korea');

INSERT INTO movie_cast (movie_id, actor_id, role_name)
VALUES
(1, 1, 'Dom Cobb'),
(2, 2, 'Neo'),
(3, 3, 'Kim Ki-taek');

INSERT INTO users (username, email, password_hash, registration_date)
VALUES 
('user1', 'user1@example.com', 'hashed_password1', '2020-01-10'),
('user2', 'user2@example.com', 'hashed_password2', '2020-03-15'),
('user3', 'user3@example.com', 'hashed_password3', '2020-07-20');

INSERT INTO reviews (movie_id, user_id, rating, review_text, review_date)
VALUES
(1, 1, 9, 'Amazing mind-bending thriller!', '2020-05-15'),
(2, 2, 10, 'Classic sci-fi!', '2021-07-22'),
(3, 3, 8, 'Dark, but brilliant satire.', '2022-01-05');

INSERT INTO fun_fact (movie_id, fact)
VALUES
(1, 'Inception took over 14 years to make.'),
(2, 'The Matrix introduced the bullet time visual effect.');

INSERT INTO money_get (movie_id, country_id, revenue)
VALUES
(1, 1, 829895144),
(2, 1, 463517383),
(3, 2, 257987083);

INSERT INTO gener (gener_name)
VALUES
('Sci-Fi'),
('Thriller'),
('Drama');

INSERT INTO movie_gener (movie_id, gener_id)
VALUES
(1, 2),
(2, 1),
(3, 3);