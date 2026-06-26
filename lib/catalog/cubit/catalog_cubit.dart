import 'package:deca_mobile/catalog/data/catalog_repository.dart';
import 'package:deca_mobile/core/cubit/collection_cubit.dart';
import 'package:deca_mobile/courses/data/models/course.dart';

class CatalogCubit extends CollectionCubit<Course> {
  CatalogCubit(this._repo);

  final CatalogRepository _repo;

  @override
  Future<List<Course>> readAll() => _repo.fetchAllCourses();
}
