class Director:
    def __init__(self, director_id, name, birth_date, nationality):
        self.director_id = director_id
        self.name = name
        self.birth_date = birth_date
        self.nationality = nationality

    def to_dict(self):
        return {
            'director_id': self.director_id,
            'name': self.name,
            'birth_date': self.birth_date,
            'nationality': self.nationality
        }

class Film:
    def __init__(self, movie_id, title, release_date, descriptions, director_id):
        self.movie_id = movie_id
        self.title = title
        self.release_date = release_date
        self.descriptions = descriptions
        self.director_id = director_id

    def to_dict(self):
        return {
            'movie_id': self.movie_id,
            'title': self.title,
            'release_date': self.release_date,
            'descriptions': self.descriptions,
            'director_id': self.director_id
        }

class Genre:
    def __init__(self, gener_id, gener_name):
        self.gener_id = gener_id
        self.gener_name = gener_name

    def to_dict(self):
        return {
            'gener_id': self.gener_id,
            'gener_name': self.gener_name
        }

class MovieGenre:
    def __init__(self, movie_id, gener_id):
        self.movie_id = movie_id
        self.gener_id = gener_id

    def to_dict(self):
        return {
            'movie_id': self.movie_id,
            'gener_id': self.gener_id
        }
