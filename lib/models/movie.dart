class MovieSchedule {
  final String time;
  final String date;

  MovieSchedule({required this.time, required this.date});

  Map<String, dynamic> toJson() {
    return {'time': time, 'date': date};
  }

  factory MovieSchedule.fromJson(Map<String, dynamic> json) {
    return MovieSchedule(time: json['time'], date: json['date']);
  }
}

class Movie {
  final String id;
  final String title;
  final String genre;
  final double price;
  final String posterUrl;
  final List<MovieSchedule> schedules;

  Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.price,
    required this.posterUrl,
    required this.schedules,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'genre': genre,
      'price': price,
      'posterUrl': posterUrl,
      'schedules': schedules.map((s) => s.toJson()).toList(),
    };
  }

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      genre: json['genre'],
      price: json['price'],
      posterUrl: json['posterUrl'],
      schedules: (json['schedules'] as List)
          .map((s) => MovieSchedule.fromJson(s))
          .toList(),
    );
  }
}
