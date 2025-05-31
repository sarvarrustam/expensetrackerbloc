part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class HomeLocalReadEvent extends HomeEvent {
  get newStyle => null;
}

class HomeLocalAddDataEvent extends HomeEvent {
  final BuildContext context;

  const HomeLocalAddDataEvent({required this.context});
}

class HomeTopDlEvent extends HomeEvent {
  final BuildContext context;
  const HomeTopDlEvent(this.context);
}

class NumberStyle extends HomeEvent {
  final String newStyle;

  const NumberStyle(this.newStyle);
}

class HomeSetFilterEvent extends HomeEvent {
  final String filter;
  const HomeSetFilterEvent({required this.filter});
}

class DeleteTransactionEvent extends HomeEvent {
  final Map<String, dynamic> transaction;
  final BuildContext context;

  const DeleteTransactionEvent(
    this.transaction,
    this.context,
  );
}

class EditTransactionEvent extends HomeEvent {
  final BuildContext context;
  final Map<String, dynamic>
      transaction; // Tahrir qilinishi kerak bo'lgan tranzaksiya

  const EditTransactionEvent(this.context, {required this.transaction});

  @override
  List<Object> get props => [
        transaction,
      ];
}

class AddButtonEvent extends HomeEvent {
  final String buttonLabel;

  const AddButtonEvent({required this.buttonLabel});
}
