import 'package:deca_mobile/core/cubit/collection_cubit.dart';
import 'package:deca_mobile/exams/data/exams_repository.dart';
import 'package:deca_mobile/exams/data/models/exam.dart';

/// Tai danh sach de thi cua 1 lop (classId co dinh theo man chi tiet lop).
class ExamsCubit extends CollectionCubit<Exam> {
  ExamsCubit(this._repo, this._classId);

  final ExamsRepository _repo;
  final int _classId;

  @override
  Future<List<Exam>> readAll() => _repo.fetchExamsByClass(_classId);
}
