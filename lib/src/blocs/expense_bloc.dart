import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/expense.dart';
import '../repositories/expense_repository.dart';

// Events
abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object> get props => [];
}

class LoadExpenses extends ExpenseEvent {}

class AddExpense extends ExpenseEvent {
  final Expense expense;

  const AddExpense(this.expense);

  @override
  List<Object> get props => [expense];
}

class DeleteExpense extends ExpenseEvent {
  final String id;

  const DeleteExpense(this.id);

  @override
  List<Object> get props => [id];
}

// States
abstract class ExpenseState extends Equatable {
  const ExpenseState();
  
  @override
  List<Object> get props => [];
}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<Expense> expenses;

  const ExpenseLoaded(this.expenses);

  @override
  List<Object> get props => [expenses];
  
  double get totalAmount => expenses.fold(0, (sum, item) => sum + item.amount);
}

class ExpenseError extends ExpenseState {
  final String message;

  const ExpenseError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository _repository;

  ExpenseBloc({required ExpenseRepository repository}) 
      : _repository = repository, 
        super(ExpenseLoading()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<AddExpense>(_onAddExpense);
    on<DeleteExpense>(_onDeleteExpense);
  }

  @override
  void onTransition(Transition<ExpenseEvent, ExpenseState> transition) {
    super.onTransition(transition);
    print(transition);
  }

  Future<void> _onLoadExpenses(LoadExpenses event, Emitter<ExpenseState> emit) async {
    print('Loading expenses...');
    emit(ExpenseLoading());
    try {
      final expenses = await _repository.loadExpenses();
      print('Loaded ${expenses.length} expenses');
      // Sort by date descending
      expenses.sort((a, b) => b.date.compareTo(a.date));
      emit(ExpenseLoaded(expenses));
    } catch (e) {
      print('Error loading expenses: $e');
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onAddExpense(AddExpense event, Emitter<ExpenseState> emit) async {
    print('Adding expense: ${event.expense}');
    try {
      await _repository.saveExpense(event.expense);
      print('Expense saved successfully');
      add(LoadExpenses());
    } catch (e) {
      print('Error adding expense: $e');
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onDeleteExpense(DeleteExpense event, Emitter<ExpenseState> emit) async {
    try {
      await _repository.deleteExpense(event.id);
      add(LoadExpenses());
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }
}
