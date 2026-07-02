import 'package:deca_mobile/core/cubit/collection_cubit.dart';
import 'package:deca_mobile/fee/data/fee_repository.dart';
import 'package:deca_mobile/fee/data/models/invoice.dart';

/// Tải danh sách đợt thu học phí.
///
/// STUDENT: [studentId] = null → BE trả của chính mình.
/// PARENT: truyền [studentId] là con đang chọn (đổi con → cubit mới).
class FeeCubit extends CollectionCubit<MyInvoiceItem> {
  FeeCubit(this._repo, {this.studentId});

  final FeeRepository _repo;
  final int? studentId;

  @override
  Future<List<MyInvoiceItem>> readAll() =>
      _repo.fetchMyInvoices(studentId: studentId);
}
