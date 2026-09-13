import 'package:bloc/bloc.dart';
import 'package:deca_mobile/core/network/api_exception.dart';
import 'package:deca_mobile/core/state/data_state.dart';
import 'package:deca_mobile/core/state/view_status.dart';
import 'package:deca_mobile/home/data/marketing_repository.dart';

/// Noi dung Hero (badge/tieu de) cho phan chao dau Trang chu — lay tu
/// GET /api/v1/home/marketing (cung endpoint voi MarketingSection, cau
/// hinh qua man "Nội Dung" cua ADMIN) thay vi hard-code, dong bo voi WEB.
/// Xem KEHOACH_WEB_TrangChuCongKhai_HeroContent.md.
class HomeHeroCubit extends Cubit<DataState<HomeHero>> {
  HomeHeroCubit(this._repo) : super(const DataState<HomeHero>());

  final MarketingRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(status: ViewStatus.loading));
    try {
      final marketing = await _repo.fetchHomeMarketing();
      final hero = marketing.hero;
      emit(
        hero == null
            ? state.copyWith(status: ViewStatus.success)
            : state.copyWith(status: ViewStatus.success, data: hero),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(status: ViewStatus.failure, error: e.message));
    } on Object catch (_) {
      emit(
        state.copyWith(status: ViewStatus.failure, error: 'Đã có lỗi xảy ra'),
      );
    }
  }
}
