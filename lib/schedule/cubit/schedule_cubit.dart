import 'package:deca_mobile/core/cubit/collection_cubit.dart';
import 'package:deca_mobile/schedule/data/models/schedule_item.dart';
import 'package:deca_mobile/schedule/data/schedule_repository.dart';

class ScheduleCubit extends CollectionCubit<ScheduleItem> {
  ScheduleCubit(this._repo);

  final ScheduleRepository _repo;

  @override
  Future<List<ScheduleItem>> readAll() => _repo.fetchSchedule();
}
