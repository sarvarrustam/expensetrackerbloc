part of 'hisobotlar_bloc.dart';

abstract class HisobotEvent extends Equatable {
  const HisobotEvent();

  @override
  List<Object> get props => [];
}

class LoadHisobotDataEvent extends HisobotEvent {}
