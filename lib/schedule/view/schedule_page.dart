import 'package:deca_mobile/core/state/data_state.dart';
import 'package:deca_mobile/core/widgets/async_list_view.dart';
import 'package:deca_mobile/schedule/cubit/schedule_cubit.dart';
import 'package:deca_mobile/schedule/data/models/schedule_item.dart';
import 'package:deca_mobile/schedule/widgets/schedule_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScheduleCubit, DataState<List<ScheduleItem>>>(
      builder: (context, state) {
        return AsyncListView<ScheduleItem>(
          state: state,
          onRefresh: context.read<ScheduleCubit>().refresh,
          emptyMessage: 'Không có buổi học nào trong lịch.',
          itemBuilder: (context, item) => ScheduleCard(item: item),
        );
      },
    );
  }
}
