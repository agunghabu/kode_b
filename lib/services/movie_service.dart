import '../models/movie.dart';

class MovieService {
  static List<Movie> getMovies() {
    return [
      Movie(
        id: '1',
        title: 'Inception',
        genre: 'Sci-Fi, Thriller',
        price: 50000,
        posterUrl: '1.jpg',
        schedules: [
          MovieSchedule(time: '10:00', date: '2025-12-20'),
          MovieSchedule(time: '13:00', date: '2025-12-20'),
          MovieSchedule(time: '16:00', date: '2025-12-20'),
          MovieSchedule(time: '19:00', date: '2025-12-20'),
        ],
      ),
      Movie(
        id: '2',
        title: 'The Dark Knight',
        genre: 'Action, Crime',
        price: 55000,
        posterUrl: '2.jpg',
        schedules: [
          MovieSchedule(time: '11:00', date: '2025-12-20'),
          MovieSchedule(time: '14:00', date: '2025-12-20'),
          MovieSchedule(time: '17:00', date: '2025-12-20'),
        ],
      ),
      Movie(
        id: '3',
        title: 'Interstellar',
        genre: 'Sci-Fi, Drama',
        price: 60000,
        posterUrl: '3.jpg',
        schedules: [
          MovieSchedule(time: '12:00', date: '2025-12-21'),
          MovieSchedule(time: '15:00', date: '2025-12-21'),
          MovieSchedule(time: '18:00', date: '2025-12-21'),
          MovieSchedule(time: '21:00', date: '2025-12-21'),
        ],
      ),
      Movie(
        id: '4',
        title: 'The Shawshank Redemption',
        genre: 'Drama',
        price: 45000,
        posterUrl: '4.jpg',
        schedules: [
          MovieSchedule(time: '10:30', date: '2025-12-22'),
          MovieSchedule(time: '13:30', date: '2025-12-22'),
          MovieSchedule(time: '16:30', date: '2025-12-22'),
        ],
      ),
    ];
  }
}
