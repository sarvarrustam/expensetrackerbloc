// import 'package:expensetrackerbloc/src/text_fermat.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'bloc/hisobotlar_bloc.dart';

// class HisobotPage extends StatefulWidget {
//   const HisobotPage({super.key});

//   @override
//   _HisobotPageState createState() => _HisobotPageState();
// }

// class _HisobotPageState extends State<HisobotPage> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       SystemChrome.setPreferredOrientations([
//         DeviceOrientation.landscapeLeft,
//         DeviceOrientation.landscapeRight,
//       ]);
//     });
//   }

//   @override
//   void dispose() {
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.landscapeRight,
//     ]);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => HisobotBloc()..add(LoadHisobotDataEvent()),
//       child: Scaffold(
//         appBar: PreferredSize(
//           preferredSize: const Size.fromHeight(35),
//           child: AppBar(
//             title: const Row(
//               children: [
//                 Text("Qoldiqlar hisobot"),
//               ],
//             ),
//             centerTitle: true,
//             actions: const [
//               // Padding(
//               //   padding: const EdgeInsets.only(right: 45.0),
//               //   child: IconButton(
//               //     icon: const Icon(Icons.date_range),
//               //     onPressed: () {},
//               //   ),
//               // ),
//             ],
//           ),
//         ),
//         body: BlocBuilder<HisobotBloc, HisobotState>(
//           builder: (context, state) {
//             if (state is HisobotLoaded) {
//               int umumiyKirim = 0;
//               int umumiyChiqim = 0;

//               for (var item in state.data) {
//                 int amount = int.tryParse(item['amount'].toString()) ?? 0;
//                 bool isKirim = item['typeInput'] == true;
//                 if (isKirim) {
//                   umumiyKirim += amount;
//                 } else {
//                   umumiyChiqim += amount;
//                 }
//               }

//               int umumiyQoldiq = umumiyKirim - umumiyChiqim;
//               int joriyQoldiq = 0;

//               return Column(
//                 children: [
//                   Padding(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                     child: Row(
//                       children: [
//                         Text(
//                           "U:kirim: ${umumiyKirim.toString().formattedAmount()}",
//                           style: const TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.green),
//                         ),
//                         const SizedBox(width: 12),
//                         Text(
//                           "U:chiqim: ${umumiyChiqim.toString().formattedAmount()}",
//                           style: const TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.red),
//                         ),
//                         const SizedBox(width: 12),
//                         Text(
//                           "U:qoldiq: ${umumiyQoldiq.toString().formattedAmount()}",
//                           style: const TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.blue),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Divider(height: 1),
//                   Expanded(
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: Column(
//                         children: [
//                           // Header scrollni alohida qo'llash
//                           SingleChildScrollView(
//                             scrollDirection: Axis.horizontal,
//                             child: DataTable(
//                               columns: const [
//                                 DataColumn(label: Text("№       ")),
//                                 DataColumn(label: Text("Vaqti   ")),
//                                 DataColumn(label: Text("Sarlavha   ")),
//                                 DataColumn(label: Text("Kirim   ")),
//                                 DataColumn(label: Text("Chiqim  ")),
//                                 DataColumn(label: Text("Katalog  ")),
//                                 DataColumn(label: Text("Qoldiq ")),
//                               ],
//                               rows: const [], // Faqat header
//                             ),
//                           ),

//                           // Body scrollni pastga ham ishlatish
//                           Expanded(
//                             child: SingleChildScrollView(
//                               scrollDirection: Axis.vertical,
//                               child: SingleChildScrollView(
//                                 scrollDirection: Axis.horizontal,
//                                 child: DataTable(
//                                   headingRowHeight: 0, // headerni yashirish
//                                   dataRowHeight: 56,
//                                   columns: const [
//                                     DataColumn(label: Text("")),
//                                     DataColumn(label: Text("")),
//                                     DataColumn(label: Text("")),
//                                     DataColumn(label: Text("")),
//                                     DataColumn(label: Text("")),
//                                     DataColumn(label: Text("")),
//                                     DataColumn(
//                                         label: Text("")), // Qoldiq ustuni
//                                   ],
//                                   rows:
//                                       List.generate(state.data.length, (index) {
//                                     var item = state.data[index];
//                                     bool isKirim = item['typeInput'] == true;
//                                     int amount = int.tryParse(
//                                             item['amount'].toString()) ??
//                                         0;

//                                     if (isKirim) {
//                                       joriyQoldiq += amount;
//                                     } else {
//                                       joriyQoldiq -= amount;
//                                     }

//                                     Color rowColor = isKirim
//                                         ? Colors.green.shade100
//                                         : Colors.pink.shade100;

//                                     return DataRow(
//                                       color: WidgetStateProperty.all(rowColor),
//                                       cells: [
//                                         DataCell(Text("${index + 1}")),
//                                         DataCell(Text(item['date']
//                                             .toString()
//                                             .substring(0, 16))),
//                                         DataCell(
//                                             Text(item['title'].toString())),
//                                         DataCell(Text(isKirim
//                                             ? item['amount']
//                                                 .toString()
//                                                 .formattedAmount()
//                                             : '')),
//                                         DataCell(Text(!isKirim
//                                             ? item['amount']
//                                                 .toString()
//                                                 .formattedAmount()
//                                             : '')),
//                                         DataCell(Text(
//                                             item['selectCotalog']?.toString() ??
//                                                 "")),
//                                         DataCell(Text(joriyQoldiq
//                                             .toString()
//                                             .formattedAmount())),
//                                       ],
//                                     );
//                                   }),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             } else {
//               return const Center(child: CircularProgressIndicator());
//             }
//           },
//         ),
//       ),
//     );
//   }
// }

import 'package:expensetrackerbloc/src/text_fermat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/hisobotlar_bloc.dart';

class HisobotPage extends StatefulWidget {
  const HisobotPage({super.key});

  @override
  _HisobotPageState createState() => _HisobotPageState();
}

class _HisobotPageState extends State<HisobotPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HisobotBloc()..add(LoadHisobotDataEvent()),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(35),
          child: AppBar(
            title: const Row(
              children: [
                Text("Qoldiqlar hisobot"),
              ],
            ),
            centerTitle: true,
            actions: const <Widget>[],
          ),
        ),
        body: BlocBuilder<HisobotBloc, HisobotState>(
          builder: (context, state) {
            if (state is HisobotLoaded) {
              int umumiyKirim = 0;
              int umumiyChiqim = 0;

              for (var item in state.data) {
                int amount = int.tryParse(item['amount'].toString()) ?? 0;
                bool isKirim = item['typeInput'] == true;
                if (isKirim) {
                  umumiyKirim += amount;
                } else {
                  umumiyChiqim += amount;
                }
              }

              int umumiyQoldiq = umumiyKirim - umumiyChiqim;
              int joriyQoldiq = 0;

              return Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          "U:kirim: ${umumiyKirim.toString().formattedAmount()}",
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "U:chiqim: ${umumiyChiqim.toString().formattedAmount()}",
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "U:qoldiq: ${umumiyQoldiq.toString().formattedAmount()}",
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        children: [
                          // Header scrollni alohida qo'llash
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text("№       ")),
                                DataColumn(label: Text("Vaqti   ")),
                                DataColumn(label: Text("Sarlavha   ")),
                                DataColumn(label: Text("Kirim   ")),
                                DataColumn(label: Text("Chiqim  ")),
                                DataColumn(label: Text("Katalog  ")),
                                DataColumn(label: Text("Qoldiq ")),
                              ],
                              rows: const [], // Faqat header
                            ),
                          ),

                          // Body scrollni pastga ham ishlatish
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  headingRowHeight: 0, // headerni yashirish
                                  dataRowHeight: 56,
                                  columns: const [
                                    DataColumn(label: Text("")),
                                    DataColumn(label: Text("")),
                                    DataColumn(label: Text("")),
                                    DataColumn(label: Text("")),
                                    DataColumn(label: Text("")),
                                    DataColumn(label: Text("")),
                                    DataColumn(
                                        label: Text("")), // Qoldiq ustuni
                                  ],
                                  rows:
                                      List.generate(state.data.length, (index) {
                                    var item = state.data[index];
                                    bool isKirim = item['typeInput'] == true;
                                    int amount = int.tryParse(
                                            item['amount'].toString()) ??
                                        0;

                                    if (isKirim) {
                                      joriyQoldiq += amount;
                                    } else {
                                      joriyQoldiq -= amount;
                                    }

                                    Color rowColor = isKirim
                                        ? Colors.green.shade100
                                        : Colors.pink.shade100;

                                    return DataRow(
                                      color: WidgetStateProperty.all(rowColor),
                                      cells: [
                                        DataCell(Text("${index + 1}")),
                                        DataCell(Text(item['date']
                                            .toString()
                                            .substring(0, 16))),
                                        DataCell(
                                            Text(item['title'].toString())),
                                        DataCell(Text(isKirim
                                            ? item['amount']
                                                .toString()
                                                .formattedAmount()
                                            : '')),
                                        DataCell(Text(!isKirim
                                            ? item['amount']
                                                .toString()
                                                .formattedAmount()
                                            : '')),
                                        DataCell(Text(
                                            item['selectCotalog']?.toString() ??
                                                "")),
                                        DataCell(Text(joriyQoldiq
                                            .toString()
                                            .formattedAmount())),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
