from flask import current_app
from models import Film, Director, Genre

class FilmDAO:
    @staticmethod
    def get_all_films():
        cursor = current_app.mysql.connection.cursor()
        cursor.execute("SELECT * FROM movies")
        films = [Film(*row).to_dict() for row in cursor.fetchall()]
        cursor.close()
        return films

    @staticmethod
    def get_film_by_id(film_id):
        cursor = current_app.mysql.connection.cursor()
        cursor.execute("SELECT * FROM movies WHERE movie_id = %s", (film_id,))
        row = cursor.fetchone()
        cursor.close()
        if row:
            return Film(*row).to_dict()
        return None

    @staticmethod
    def add_film(title, release_date, descriptions, director_id):
        cursor = current_app.mysql.connection.cursor()
        cursor.execute(
            "INSERT INTO movies (title, release_date, descriptions, director_id) VALUES (%s, %s, %s, %s)",
            (title, release_date, descriptions, director_id)
        )
        current_app.mysql.connection.commit()
        cursor.close()

    @staticmethod
    def update_film(film_id, title, release_date, descriptions, director_id):
        cursor = current_app.mysql.connection.cursor()
        cursor.execute(
            "UPDATE movies SET title = %s, release_date = %s, descriptions = %s, director_id = %s WHERE movie_id = %s",
            (title, release_date, descriptions, director_id, film_id)
        )
        current_app.mysql.connection.commit()
        cursor.close()

    @staticmethod
    def delete_film(film_id):
        cursor = current_app.mysql.connection.cursor()
        cursor.execute("DELETE FROM movies WHERE movie_id = %s", (film_id,))
        current_app.mysql.connection.commit()
        cursor.close()
        return cursor.rowcount > 0

class DirectorDAO:
    @staticmethod
    def get_all_directors():
        cursor = current_app.mysql.connection.cursor()
        cursor.execute("SELECT * FROM directors")
        directors = [Director(*row).to_dict() for row in cursor.fetchall()]
        cursor.close()
        return directors

    @staticmethod
    def get_director_by_id(director_id):
        cursor = current_app.mysql.connection.cursor()
        cursor.execute("SELECT * FROM directors WHERE director_id = %s", (director_id,))
        row = cursor.fetchone()
        cursor.close()
        if row:
            return Director(*row).to_dict()
        return None

    @staticmethod
    def get_movies_by_director(director_id):
        cursor = current_app.mysql.connection.cursor()
        cursor.execute("SELECT * FROM movies WHERE director_id = %s", (director_id,))
        movies = [Film(*row).to_dict() for row in cursor.fetchall()]
        cursor.close()
        return movies

class GenreDAO:
    @staticmethod
    def get_all_genres():
        cursor = current_app.mysql.connection.cursor()
        cursor.execute("SELECT * FROM gener")
        genres = [Genre(*row).to_dict() for row in cursor.fetchall()]
        cursor.close()
        return genres

    @staticmethod
    def get_genres_by_movie(movie_id):
        cursor = current_app.mysql.connection.cursor()
        cursor.execute("""
            SELECT g.gener_id, g.gener_name
            FROM gener g
            JOIN movie_gener mg ON g.gener_id = mg.gener_id
            WHERE mg.movie_id = %s
        """, (movie_id,))
        genres = [Genre(*row).to_dict() for row in cursor.fetchall()]
        cursor.close()
        return genres

    @staticmethod
    def get_movies_by_genre(gener_id):
        cursor = current_app.mysql.connection.cursor()
        cursor.execute("""
            SELECT m.movie_id, m.title, m.release_date, m.descriptions, m.director_id
            FROM movies m
            JOIN movie_gener mg ON m.movie_id = mg.movie_id
            WHERE mg.gener_id = %s
        """, (gener_id,))
        movies = [Film(*row).to_dict() for row in cursor.fetchall()]
        cursor.close()
        return movies

class ReviewDAO:
    @staticmethod
    def add_review(movie_id, user_id, rating, review_text, review_date):
        cursor = current_app.mysql.connection.cursor()
        cursor.callproc('add_review', [movie_id, user_id, rating, review_text, review_date])
        current_app.mysql.connection.commit()
        cursor.close()

    @staticmethod
    def insert_dummy_reviews():
        cursor = current_app.mysql.connection.cursor()
        cursor.callproc('insert_dummy_reviews')
        current_app.mysql.connection.commit()
        cursor.close()

    @staticmethod
    def get_review_statistic(column_name, statistic_type):
        cursor = current_app.mysql.connection.cursor()
        cursor.callproc('get_review_statistic', [column_name, statistic_type])
        result = cursor.fetchone()
        cursor.close()
        return result[0]

    @staticmethod
    def create_dynamic_tables():
        cursor = current_app.mysql.connection.cursor()
        cursor.callproc('create_dynamic_tables')
        current_app.mysql.connection.commit()
        cursor.close()