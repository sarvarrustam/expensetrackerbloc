part of 'hisobotlar_bloc.dart';

abstract class HisobotState extends Equatable {
  const HisobotState();

  @override
  List<Object> get props => [];
}

class HisobotInitial extends HisobotState {}

class HisobotLoaded extends HisobotState {
  final List<Map<String, dynamic>> data;

  const HisobotLoaded(this.data);

  @override
  List<Object> get props => [data];
}
