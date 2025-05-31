import 'dart:math';
import 'package:expensetrackerbloc/pages/home/bloc/home_bloc.dart';
import 'package:expensetrackerbloc/src/text_fermat.dart';
import 'package:expensetrackerbloc/widgets/enhanced_transaction_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> newCotalog = {
      'selectButtonCotalog': '',
    };

    Future<void> saveToHive(Map<String, dynamic> newCatalog,
        void Function() setStateCallback) async {
      var box = await Hive.openBox('catalogBox');
      await box.put('catalog', newCatalog);
      setStateCallback();
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[200],
          title: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              return Text('Hamyon: ${state.selectedCatalog}',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500));
            },
          ),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {
                  context.read<HomeBloc>().add(HomeTopDlEvent(context));
                },
                icon: const Icon(Icons.filter_list))
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context
                .read<HomeBloc>()
                .add(HomeLocalAddDataEvent(context: context));
          },
          child: const Icon(Icons.add),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width / 2,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                        Theme.of(context).colorScheme.tertiary,
                      ],
                      transform: const GradientRotation(pi / 4),
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 4,
                          color: Colors.grey.shade300,
                          offset: const Offset(5, 5))
                    ]),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Umumiy Hisob',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context
                          .watch<HomeBloc>()
                          .state
                          .balans()
                          .toString()
                          .formattedAmount(),
                      style: const TextStyle(
                          fontSize: 35,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 12.w, horizontal: 20.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 30.w,
                                height: 30.h,
                                decoration: const BoxDecoration(
                                    color: Colors.white30,
                                    shape: BoxShape.circle),
                                child: Center(
                                    child: Icon(
                                  CupertinoIcons.arrow_down,
                                  size: 15.sp,
                                  color: Colors.black,
                                )),
                              ),
                              SizedBox(width: 8.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Krim',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  Text(
                                    context
                                        .watch<HomeBloc>()
                                        .state
                                        .incomeBalance()
                                        .toString()
                                        .formattedAmount(),
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              )
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              context.push("/hisoborlar");
                            },
                            child: Column(
                              children: [
                                Icon(Icons.add_chart_sharp,
                                    color: Colors.red, size: 30.sp),
                                Text('Xisobot',
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 15.sp)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: const BoxDecoration(
                                    color: Colors.white30,
                                    shape: BoxShape.circle),
                                child: const Center(
                                    child: Icon(
                                  CupertinoIcons.arrow_up,
                                  size: 15,
                                  color: Colors.black,
                                )),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Chiqim',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  Text(
                                    context
                                        .watch<HomeBloc>()
                                        .state
                                        .expenseBalance()
                                        .toString()
                                        .formattedAmount(),
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: state.getFilterList().length,
                      itemBuilder: (BuildContext context, int index) {
                        final item = state.getFilterList()[index];
                        final amount =
                            item['amount'].toString().parseToDouble();

                        return EnhancedTransactionCard(
                          title: item['title'],
                          date: item['date'],
                          catalog: item['selectCotalog'],
                          amount: amount.toString().formattedAmount(),
                          isIncome: item['typeInput'] == true ||
                              item['typeInput'] == 'true' ||
                              item['typeInput'] == 1,
                          onEdit: () {
                            context.read<HomeBloc>().add(
                                  EditTransactionEvent(
                                    context,
                                    transaction: item,
                                  ),
                                );
                          },
                          onDelete: () {
                            context.read<HomeBloc>().add(
                                  DeleteTransactionEvent(item, context),
                                );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
