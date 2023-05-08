class Book {
  String _date;
  String _timeSlot;
  int _table;

  Book(this._date, this._timeSlot, this._table);

  String get date => _date;

  set date(String date) {
    _date = date;
  }

  String get timeSlot => _timeSlot;

  set timeSlot(String timeSlot) {
    _timeSlot = timeSlot;
  }

  int get table => _table;

  set table(int table) {
    _table = table;
  }
}
