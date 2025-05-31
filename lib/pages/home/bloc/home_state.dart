part of 'home_bloc.dart';

class HomeState {
  final List<Map<String, dynamic>> list;
  final String selectedValue;
  final int formattedValue;
  final String? filter;
  final List<String> dynamicButtons; // dynamicButtonsni qo'shish
  var selectedCatalog;

  HomeState({
    required this.selectedCatalog,
    required this.list,
    required this.selectedValue,
    required this.formattedValue,
    this.filter,
    required this.dynamicButtons, // dynamicButtonsni constructorga qo'shish
  });

  List<Map<String, dynamic>> getFilterList() {
    // Hive box'ni olish
    final box = Hive.box('catalogBox');

    // selectedCatalog ni Hive'dan olish
    selectedCatalog = box.get('catalog')?['selectButtonCotalog'] ?? '1';

    // Agar selectedCatalog bo'sh bo'lsa, ro'yxatni qaytarish
    if (selectedCatalog.isEmpty) {
      return list;
    } else {
      // selectedCatalog ga mos keladigan itemlarni qaytarish
      return list
          .where((item) => item['selectCotalog'] == selectedCatalog)
          .toList();
    }
  }

  String balans() {
    int sum = 0;
    for (var element in getFilterList()) {
      final amountStr = element['amount'];
      final typeInput = element['typeInput'];

      if (amountStr == null || int.tryParse(amountStr) == null) continue;
      int amount = int.parse(amountStr);

      bool isIncome =
          typeInput == true || typeInput == 'true' || typeInput == 1;

      if (isIncome) {
        sum += amount;
      } else {
        sum -= amount;
      }
    }

    return sum.toString();
  }

  String incomeBalance() {
    int incomeSum = 0;
    for (var element in getFilterList()) {
      final typeInput = element['typeInput'];
      final amountStr = element['amount'];
      if (amountStr == null || int.tryParse(amountStr) == null) continue;
      int amount = int.parse(amountStr);

      if (typeInput == true || typeInput == 'true' || typeInput == 1) {
        incomeSum += amount;
      }
    }
    return incomeSum.toString();
  }

  String expenseBalance() {
    int expenseSum = 0;
    for (var element in getFilterList()) {
      final typeInput = element['typeInput'];
      final amountStr = element['amount'];
      if (amountStr == null || int.tryParse(amountStr) == null) continue;
      int amount = int.parse(amountStr);

      if (typeInput == false || typeInput == 'false' || typeInput == 0) {
        expenseSum += amount;
      }
    }
    return expenseSum.toString();
  }

  HomeState copyWith({
    List<Map<String, dynamic>>? list,
    String? selectedValue,
    String? selectedCatalog,
    int? formattedValue,
    String? filter,
    List<String>? dynamicButtons, // dynamicButtonsni qo‘shish
  }) {
    return HomeState(
      list: list ?? this.list,
      selectedValue: selectedValue ?? this.selectedValue,
      formattedValue: formattedValue ?? this.formattedValue,
      filter: filter ?? this.filter,
      dynamicButtons: dynamicButtons ?? this.dynamicButtons,
      selectedCatalog:
          selectedCatalog ?? this.selectedCatalog, // dynamicButtonsni saqlash
    );
  }

  factory HomeState.init() {
    return HomeState(
      list: [],
      selectedValue: 'kirim',
      formattedValue: 0,

      dynamicButtons: ['1', '2'],
      selectedCatalog: "1", // boshlang‘ich dynamicButtons
    );
  }
}
