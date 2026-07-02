import 'package:deca_mobile/core/cubit/collection_cubit.dart';
import 'package:deca_mobile/schedule/data/models/timetable_item.dart';
import 'package:deca_mobile/schedule/data/timetable_repository.dart';

/// Buoi hoc HOM NAY (theo view tuong ung vai tro) cho Trang chu.
class HomeTodayCubit extends CollectionCubit<TimetableItem> {
  HomeTodayCubit(this._repo, {required this.view});

  final TimetableRepository _repo;
  final String view;

  @override
  Future<List<TimetableItem>> readAll() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _repo.fetchTimetable(view: view, from: today, to: today);
  }
}
