import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'hisobotlar_event.dart';
part 'hisobotlar_state.dart';

class HisobotBloc extends Bloc<HisobotEvent, HisobotState> {
  HisobotBloc() : super(HisobotInitial()) {
    on<LoadHisobotDataEvent>(_loadData);
  }

  Future<void> _loadData(
      LoadHisobotDataEvent event, Emitter<HisobotState> emit) async {
    final box = await Hive.openBox('db');
    final rawData = box.get('cash') ?? [];

    List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
        rawData.map((item) => Map<String, dynamic>.from(item)));

    // 🔽 Filter uchun catalogBox dan tanlangan qiymatni olish
    final catalogBox = await Hive.openBox('catalogBox');
    final selectedCatalog =
        catalogBox.get('catalog')?['selectButtonCotalog'] ?? '';

    // 🔽 Agar filter tanlanmagan bo‘lsa, hamma data, aks holda filterlangan
    List<Map<String, dynamic>> filteredData;
    if (selectedCatalog.isEmpty) {
      filteredData = data;
    } else {
      filteredData = data
          .where((item) => item['selectCotalog'] == selectedCatalog)
          .toList();
    }

    emit(HisobotLoaded(filteredData));
  }
}
