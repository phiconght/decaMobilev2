import 'package:deca_mobile/core/cubit/collection_cubit.dart';
import 'package:deca_mobile/reports/data/models/report.dart';
import 'package:deca_mobile/reports/data/reports_repository.dart';

class ReportsCubit extends CollectionCubit<Report> {
  ReportsCubit(this._repository);

  final ReportsRepository _repository;

  @override
  Future<List<Report>> readAll() => _repository.fetchReports();
}
