import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expensetrackerbloc/src/number_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeState.init()) {
    on<HomeLocalReadEvent>(_onReadCash);
    on<HomeLocalAddDataEvent>(_onAddLocalData);
    on<HomeSetFilterEvent>(_setFilter);
    on<HomeTopDlEvent>(_onOpenDl);
    on<NumberStyle>((event, emit) {
      int newValue = int.tryParse(event.newStyle) ?? 0;
      emit(state.copyWith(formattedValue: newValue));
    });
    on<DeleteTransactionEvent>(_onDeleteLocalData);

    on<EditTransactionEvent>(_onEditLocalData);
  }

  void _onEditLocalData(
      EditTransactionEvent event, Emitter<HomeState> emit) async {
    // Tahrirlash oynasini ko‘rsatish
    var updatedData = await _showEditDialog(event.context, event.transaction);

    if (updatedData != null) {
      // Eski ro'yxatni olish
      var list = List<Map<String, dynamic>>.from(state.list);

      // Eski transactionni topib, uni yangilash
      int index = list.indexOf(event.transaction);
      if (index != -1) {
        list[index] = updatedData;

        // Hive bazasiga saqlash
        Box box = await Hive.openBox('db');
        await box.put('cash', list);

        // Yangilangan holatni yuborish
        emit(state.copyWith(list: list));
      }
    }
  }

  void _onDeleteLocalData(
      DeleteTransactionEvent event, Emitter<HomeState> emit) async {
    // Tasdiqlovchi dialogni ko'rsatish
    bool? shouldDelete = await _showDeleteConfirmationDialog(event.context);

    if (shouldDelete == true) {
      // Eski ro'yxatni olish
      var list = List<Map<String, dynamic>>.from(state.list);

      // Transactionni o'chirish
      list.remove(event.transaction);

      // Hive bazasiga saqlash
      Box box = await Hive.openBox('db');
      await box.put('cash', list);

      // Holatni yangilash
      emit(state.copyWith(list: list));
    }
  }

  void _setFilter(HomeSetFilterEvent event, Emitter<HomeState> emit) {
    emit(state.copyWith(filter: event.filter));
  }

  void _onReadCash(HomeLocalReadEvent event, Emitter<HomeState> emit) async {
    Box box = await Hive.openBox('db');
    var res = await box.get("cash");

    if (res != null) {
      List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.from(res.map((item) {
        return Map<String, dynamic>.from(item);
      }));

      emit(state.copyWith(list: list));
    }
  }

  void _onAddLocalData(
      HomeLocalAddDataEvent event, Emitter<HomeState> emit) async {
    var res = await _showMyDialog(event.context);
    if (res != null) {
      var list = List<Map<String, dynamic>>.from(state.list);
      list.add(res);
      Box box = await Hive.openBox('db');
      await box.put('cash', list);
      emit(state.copyWith(list: list));
    }
  }

  Future<Map<String, dynamic>?> getFromHive() async {
    var box = await Hive.openBox('catalogBox');
    var data = box.get('catalog');

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return null;
  }

  Future _showMyDialog(BuildContext parentContext) async {
    TextEditingController amountController = TextEditingController();
    TextEditingController titleController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    List<String> statusList = ['kirim', 'chiqim'];
    // String status = "kirim";

    int selectedIndex = 0;
    String status = statusList[selectedIndex];

    Map<String, dynamic>? newCotalog = await getFromHive();
    String? selectCotalog = newCotalog?['selectButtonCotalog'] ?? '1';

    // List<String> dropdownItems = ['1', '2']; // Boshlang'ich qiymat
    return showCupertinoDialog(
      context: parentContext,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Summa kiriting'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                const SizedBox(height: 10),
                SizedBox(
                  height: 100,
                  child: CupertinoPicker(
                    scrollController:
                        FixedExtentScrollController(initialItem: selectedIndex),
                    itemExtent: 36,
                    onSelectedItemChanged: (int index) {
                      setState(() {
                        selectedIndex = index;
                        status = statusList[index];
                      });
                    },
                    children: statusList.map((value) {
                      return Center(
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: value == 'kirim' ? Colors.green : Colors.red,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     CupertinoButton(
                //       padding: const EdgeInsets.symmetric(
                //           horizontal: 24, vertical: 8),
                //       color: status == 'kirim'
                //           ? CupertinoColors.activeGreen
                //           : CupertinoColors.systemGrey4,
                //       onPressed: () {
                //         setState(() {
                //           status = 'kirim';
                //         });
                //       },
                //       child: const Text(
                //         'Kirim',
                //         style: TextStyle(color: Colors.black),
                //       ),
                //     ),
                //     const SizedBox(width: 10),
                //     CupertinoButton(
                //       padding: const EdgeInsets.symmetric(
                //           horizontal: 24, vertical: 8),
                //       color: status == 'chiqm'
                //           ? CupertinoColors.systemRed
                //           : CupertinoColors.systemGrey4,
                //       onPressed: () {
                //         setState(() {
                //           status = 'chiqm';
                //         });
                //       },
                //       child: const Text(
                //         'Chiqm',
                //         style: TextStyle(color: Colors.black),
                //       ),
                //     ),
                //   ],
                // ),
                const SizedBox(height: 10),
                // 👇 Bu yerda formalar o'zgarishsiz qolgan:
                Material(
                  color: Colors.transparent,
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: titleController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Iltimos, sarlovha kiriting';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Sarlovha',
                              labelStyle: const TextStyle(
                                  color: CupertinoColors.systemGrey),
                              filled: true,
                              fillColor:
                                  CupertinoColors.extraLightBackgroundGray,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: CupertinoColors.systemGrey4),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: CupertinoColors.activeBlue),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          TextFormField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              ThousandsSeparatorInputFormatter()
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Iltimos, miqdor kiriting';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Miqdori',
                              labelStyle: const TextStyle(
                                  color: CupertinoColors.systemGrey),
                              filled: true,
                              fillColor:
                                  CupertinoColors.extraLightBackgroundGray,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: CupertinoColors.systemGrey4),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: CupertinoColors.activeBlue),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Saqlash'),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                String enteredTitle = titleController.text.trim();
                String enteredAmount =
                    amountController.text.replaceAll(' ', '').trim();
                var now = DateTime.now();
                var formattedDate = DateFormat('dd.MM.yyyy HH:mm').format(now);
                Map<String, dynamic> newData = {
                  'title': enteredTitle,
                  'amount': enteredAmount,
                  'type': status,
                  'typeInput': status == "kirim",
                  'selectCotalog': state.selectedCatalog,
                  'date': formattedDate,
                };

                Navigator.of(parentContext).pop(newData);
              }
            },
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Bekor qilish'),
            onPressed: () => Navigator.of(parentContext).pop(),
          ),
        ],
      ),
    );
  }

  void _onOpenDl(HomeTopDlEvent event, Emitter<HomeState> emit) async {
    showTopDialog(event.context).then((onValue) {
      if (onValue != null) {
        add(HomeSetFilterEvent(
          filter: onValue,
        ));
      }
    });
  }

  Future showTopDialog(BuildContext context) async {
    Map<String, dynamic> newCatalog = {'selectButtonCotalog': ''};
    List<String> buttonList = [];

    var box = await Hive.openBox('catalogBox');

    Future<void> saveCatalogToHive(
        Map<String, dynamic> catalog, void Function() callback) async {
      await box.put('catalog', catalog);
      callback();
    }

    Future<void> saveButtonList(List<String> list) async {
      await box.put('buttonList', list);
    }

    Future<List<String>> loadButtonList() async {
      List<dynamic>? storedList = box.get('buttonList');
      return storedList?.cast<String>() ?? ['1', '2'];
    }

    Future<Map<String, dynamic>> loadCatalog() async {
      var stored = box.get('catalog');
      return stored != null
          ? Map<String, dynamic>.from(stored)
          : {'selectButtonCotalog': ''};
    }

    buttonList = await loadButtonList();
    newCatalog = await loadCatalog();

    var res = await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dialog",
      barrierColor: Colors.black26,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: StatefulBuilder(
            builder: (context, setState) {
              return SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: EdgeInsets.all(20.r),
                      height: 500.h,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24.r),
                          topRight: Radius.circular(24.r),
                        ),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                                itemCount: buttonList.length,
                                itemBuilder: (context, index) {
                                  var btn = buttonList[index];
                                  return Container(
                                    margin: EdgeInsets.symmetric(vertical: 6.h),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12.w),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                    child: ListTile(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      tileColor: Colors.white,
                                      leading: const CircleAvatar(
                                        backgroundColor: Colors.blueAccent,
                                        child: Icon(Icons.folder,
                                            color: Colors.white),
                                      ),
                                      title: Text(
                                        btn,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          newCatalog['selectButtonCotalog'] =
                                              btn;
                                        });
                                        saveCatalogToHive(newCatalog, () {
                                          setState(() {});
                                        });
                                        Navigator.of(context).pop(btn);
                                      },
                                      trailing: (btn == '1' || btn == '2')
                                          ? null
                                          : IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.redAccent),
                                              onPressed: () async {
                                                bool? confirm =
                                                    await showDialog<bool>(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: const Text(
                                                        "Tasdiqlash"),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(false),
                                                        child: const Text(
                                                          "Yo'q",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(true),
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .blue),
                                                        child: const Text(
                                                          "Ha",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );

                                                if (confirm == true) {
                                                  setState(() {
                                                    // O'chirilgan elementni buttonListdan olib tashlash
                                                    buttonList.remove(btn);
                                                  });

                                                  // ButtonListni yangilash
                                                  await saveButtonList(
                                                      buttonList);

                                                  // `selectCotalog` qiymatini yangilash (o'chirish)
                                                  if (newCatalog[
                                                          'selectButtonCotalog'] ==
                                                      btn) {
                                                    newCatalog[
                                                            'selectButtonCotalog'] =
                                                        '1'; // O'chirildi
                                                    await saveCatalogToHive(
                                                        newCatalog, () {
                                                      setState(
                                                          () {}); // UIni yangilash
                                                    });
                                                  }

                                                  // Elementni state dan olib tashlash (agar kerak bo'lsa)
                                                  var list = state.list;
                                                  list.removeWhere((element) =>
                                                      element[
                                                          "selectCotalog"] ==
                                                      state.selectedCatalog);

                                                  // Yangilangan state ni emit qilish
                                                  emit(state.copyWith(
                                                    list: list,
                                                    selectedCatalog:
                                                        "1", // O'chirilgan catalogni 1 ga o'zgartirish
                                                  ));
                                                }
                                              }),
                                    ),
                                  );
                                }),
                          ),
                          SizedBox(height: 12.h),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                TextEditingController addCatalogController =
                                    TextEditingController();
                                await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text("Yangi Hamyon"),
                                      content: TextField(
                                        controller: addCatalogController,
                                        decoration: InputDecoration(
                                          hintText: "Hamyon nomi",
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                          ),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text("Bekor"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            String value = addCatalogController
                                                .text
                                                .trim();
                                            if (value.isNotEmpty &&
                                                !buttonList.contains(value)) {
                                              setState(() {
                                                buttonList.add(value);
                                              });
                                              await saveButtonList(buttonList);
                                            }
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text("Saqlash"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text("Yangi Hamyon qo‘shish"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
    );

    return res;
  }

  Future<Map<String, dynamic>?> _showEditDialog(
      BuildContext parentContext, Map<String, dynamic> transaction) async {
    TextEditingController amountController =
        TextEditingController(text: transaction['amount']);
    TextEditingController titleController =
        TextEditingController(text: transaction['title']);
    final formKey = GlobalKey<FormState>();
    String status = transaction['type'];

    return showDialog<Map<String, dynamic>>(
      context: parentContext,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Summani tahrirlang'),
          content: StatefulBuilder(builder: (context, setState) {
            return SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: status == 'kirim'
                                  ? Colors.green.shade300
                                  : Colors.grey.shade300,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              setState(() {
                                status = 'kirim';
                              });
                            },
                            child: const Text(
                              'kirim',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: status == 'chiqm'
                                  ? Colors.red.shade300
                                  : Colors.grey.shade300,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              setState(() {
                                status = 'chiqm';
                              });
                            },
                            child: const Text(
                              'chiqm',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Sarlovha',
                        labelStyle:
                            const TextStyle(color: CupertinoColors.systemGrey),
                        filled: true,
                        fillColor: CupertinoColors.extraLightBackgroundGray,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: CupertinoColors.systemGrey4),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: CupertinoColors.activeBlue),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                      ),
                      controller: titleController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Iltimos, Sarlovha kiriting';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      inputFormatters: [ThousandsSeparatorInputFormatter()],
                      decoration: InputDecoration(
                        labelText: 'Miqdori',
                        labelStyle:
                            const TextStyle(color: CupertinoColors.systemGrey),
                        filled: true,
                        fillColor: CupertinoColors.extraLightBackgroundGray,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: CupertinoColors.systemGrey4),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: CupertinoColors.activeBlue),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                      ),
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Iltimos, miqdor kiriting';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Bekor qilish
              },
              child: const Text(
                'Bekor qilish',
                style: TextStyle(
                  color: CupertinoColors.destructiveRed,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  String enteredTitle = titleController.text;
                  String enteredAmount =
                      amountController.text.replaceAll(' ', '');
                  Map<String, dynamic> updatedData = {
                    'title': enteredTitle,
                    'amount': enteredAmount,
                    'type': status,
                    'typeInput': status == "kirim",
                    'selectCotalog': transaction['selectCotalog'],
                    'date': transaction['date'],
                  };
                  Navigator.of(parentContext).pop(updatedData);
                }
              },
              child: const Text(
                'Saqlash',
                style: TextStyle(
                  color: CupertinoColors.activeBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    // showDialog<Map<String, dynamic>>(
    //   context: parentContext,
    //   barrierDismissible: true,
    //   builder: (BuildContext dialogContext) {
    //     return AlertDialog(
    //       title: const Text('Summa tahrirlang'),
    //       content: StatefulBuilder(builder: (context, setState) {
    //         return SingleChildScrollView(
    //           child: Form(
    //             key: formKey,
    //             child: Column(
    //               children: [
    //                 DropdownButton<String>(
    //                   value: status,
    //                   items: ['kirim', 'chiqm'].map((String value) {
    //                     return DropdownMenuItem<String>(
    //                       value: value,
    //                       child: Text(value),
    //                     );
    //                   }).toList(),
    //                   onChanged: (value) {
    //                     if (value != null) {
    //                       setState(() {
    //                         status = value;
    //                       });
    //                     }
    //                   },
    //                 ),
    //                 TextFormField(
    //                   decoration: const InputDecoration(labelText: 'Sarlovha'),
    //                   controller: titleController,
    //                   validator: (value) {
    //                     if (value == null || value.trim().isEmpty) {
    //                       return 'Iltimos, Sarlovha kiriting';
    //                     }
    //                     return null;
    //                   },
    //                 ),
    //                 TextFormField(
    //                   inputFormatters: [ThousandsSeparatorInputFormatter()],
    //                   decoration: const InputDecoration(labelText: 'miqdori'),
    //                   controller: amountController,
    //                   keyboardType: TextInputType.number,
    //                   validator: (value) {
    //                     if (value == null || value.trim().isEmpty) {
    //                       return 'Iltimos, miqdor kiriting';
    //                     }
    //                     return null;
    //                   },
    //                 ),
    //               ],
    //             ),
    //           ),
    //         );
    //       }),
    //       actions: [
    //         TextButton(
    //           child: const Text('Save'),
    //           onPressed: () {
    //             if (formKey.currentState!.validate()) {
    //               String enteredTitle = titleController.text;
    //               String enteredAmount =
    //                   amountController.text.replaceAll(' ', '');
    //               Map<String, dynamic> updatedData = {
    //                 'title': enteredTitle,
    //                 'amount': enteredAmount,
    //                 'type': status,
    //                 'typeInput': status == "kirim",
    //                 'selectCotalog': transaction['selectCotalog'],
    //                 'date': transaction['date'],
    //               };
    //               Navigator.of(parentContext).pop(updatedData);
    //             }
    //           },
    //         )
    //       ],
    //     );
    //   },
    // );
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("O'chirishni tasdiqlang"),
          content: const Text("Ushbu transactionni o'chirishni xohlaysizmi?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text("Yo'q"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text("Ha"),
            ),
          ],
        );
      },
    );
  }
}
