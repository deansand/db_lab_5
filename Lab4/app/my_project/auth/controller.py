from flask import jsonify, request, current_app
from dao import FilmDAO, DirectorDAO, GenreDAO, ReviewDAO
from datetime import datetime
import mysql.connector as mysql

class FilmController:
    @staticmethod
    def get_all_films():
        films = FilmDAO.get_all_films()
        film_list = [film for film in films]
        return jsonify(film_list)

    @staticmethod
    def get_film(film_id):
        film = FilmDAO.get_film_by_id(film_id)
        if film:
            return jsonify(film)
        return jsonify({'message': 'Film not found'}), 404

    @staticmethod
    def add_film(data):
        release_date_str = data['release_date']
        release_date = datetime.strptime(release_date_str, "%Y-%m-%d").date()
        FilmDAO.add_film(data['title'], release_date, data['descriptions'], data['director_id'])
        return jsonify({'message': 'Film added successfully!'}), 201

    @staticmethod
    def update_film(film_id, data):
        release_date_str = data['release_date']
        release_date = datetime.strptime(release_date_str, "%Y-%m-%d").date()
        film = FilmDAO.update_film(film_id, data['title'], release_date, data['descriptions'], data['director_id'])
        if film:
            return jsonify({'message': 'Film updated successfully!'}), 200
        return jsonify({'message': 'Film not found'}), 404

    @staticmethod
    def delete_film(film_id):
        success = FilmDAO.delete_film(film_id)
        if success:
            return jsonify({'message': 'Film deleted successfully!'}), 200
        return jsonify({'message': 'Film not found'}), 404

class DirectorController:
    @staticmethod
    def get_all_directors():
        directors = DirectorDAO.get_all_directors()
        return jsonify(directors)

    @staticmethod
    def get_director(director_id):
        director = DirectorDAO.get_director_by_id(director_id)
        if director:
            return jsonify(director)
        return jsonify({'message': 'Director not found'}), 404

    @staticmethod
    def get_movies_by_director(director_id):
        movies = DirectorDAO.get_movies_by_director(director_id)
        return jsonify(movies)

class GenreController:
    @staticmethod
    def get_all_genres():
        genres = GenreDAO.get_all_genres()
        return jsonify(genres)

    @staticmethod
    def get_genres_by_movie(movie_id):
        genres = GenreDAO.get_genres_by_movie(movie_id)
        return jsonify(genres)

    @staticmethod
    def get_movies_by_genre(gener_id):
        movies = GenreDAO.get_movies_by_genre(gener_id)
        return jsonify(movies)

class AwardController:
    @staticmethod
    def add_award(data):
        cursor = current_app.mysql.connection.cursor()
        query = "INSERT INTO awards (movie_id, award_name, award_year) VALUES (%s, %s, %s)"
        cursor.execute(query, (data['movie_id'], data['award_name'], data['award_year']))
        current_app.mysql.connection.commit()
        cursor.close()
        return jsonify({'message': 'Award added successfully'}), 201

    @staticmethod
    def get_awards():
        cursor = current_app.mysql.connection.cursor()
        cursor.execute("SELECT * FROM awards")
        awards = cursor.fetchall()
        cursor.close()
        return jsonify(awards), 200

    @staticmethod
    def update_award(award_id, data):
        cursor = current_app.mysql.connection.cursor()
        query = "UPDATE awards SET movie_id = %s, award_name = %s, award_year = %s WHERE award_id = %s"
        cursor.execute(query, (data['movie_id'], data['award_name'], data['award_year'], award_id))
        current_app.mysql.connection.commit()
        cursor.close()
        return jsonify({'message': 'Award updated successfully'}), 200

    @staticmethod
    def delete_award(award_id):
        cursor = current_app.mysql.connection.cursor()
        cursor.execute("DELETE FROM awards WHERE award_id = %s", (award_id,))
        current_app.mysql.connection.commit()
        cursor.close()
        return jsonify({'message': 'Award deleted successfully'}), 200