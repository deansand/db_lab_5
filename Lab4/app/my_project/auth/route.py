from flask import Blueprint, request
from controller import FilmController, DirectorController, AwardController

api_bp = Blueprint('api', __name__)

@api_bp.route('/films', methods=['GET'])
def get_all_films():
    return FilmController.get_all_films()

@api_bp.route('/films/<int:film_id>', methods=['GET'])
def get_film(film_id):
    return FilmController.get_film(film_id)

@api_bp.route('/films', methods=['POST'])
def add_film():
    data = request.get_json()
    return FilmController.add_film(data)

@api_bp.route('/films/<int:film_id>', methods=['PUT'])
def update_film(film_id):
    data = request.get_json()
    return FilmController.update_film(film_id, data)

@api_bp.route('/films/<int:film_id>', methods=['DELETE'])
def delete_film(film_id):
    return FilmController.delete_film(film_id)

@api_bp.route('/directors', methods=['GET'])
def get_all_directors():
    return DirectorController.get_all_directors()

@api_bp.route('/directors/<int:director_id>', methods=['GET'])
def get_director(director_id):
    return DirectorController.get_director(director_id)

@api_bp.route('/directors/<int:director_id>/movies', methods=['GET'])
def get_movies_by_director(director_id):
    return DirectorController.get_movies_by_director(director_id)

@api_bp.route('/awards', methods=['POST'])
def add_award():
    data = request.get_json()
    return AwardController.add_award(data)

@api_bp.route('/awards', methods=['GET'])
def get_awards():
    return AwardController.get_awards()

@api_bp.route('/awards/<int:award_id>', methods=['PUT'])
def update_award(award_id):
    data = request.get_json()
    return AwardController.update_award(award_id, data)

@api_bp.route('/awards/<int:award_id>', methods=['DELETE'])
def delete_award(award_id):
    return AwardController.delete_award(award_id)