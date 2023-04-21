class Restaurant {
  String _name;
  String _description;
  String _foodCategory;
  int _numTables;
  int _numSeats;
  List<String> _timeslots;
  int? _id;
  String _location;
  String _imgUrl;

  // Constructor with id parameter
  Restaurant.withId(this._id, this._name, this._description, this._foodCategory,
      this._numTables, this._numSeats, this._timeslots,this._location,this._imgUrl);

  // Constructor without id parameter (sets _id to null)
  Restaurant(this._name, this._description, this._foodCategory, this._numTables,
      this._numSeats, this._timeslots,this._location,this._imgUrl)
      : _id = null;

  // Empty constructor
  Restaurant.empty()
      : _name = '',
        _description = '',
        _foodCategory = '',
        _numTables = 0,
        _numSeats = 0,
        _timeslots = [],
        _id = null,
        _location='',
        _imgUrl='';

  String get name => _name;

  set name(String name) => _name = name;

  String get description => _description;

  set description(String description) => _description = description;

  String get foodCategory => _foodCategory;

  set foodCategory(String foodCategory) => _foodCategory = foodCategory;

  int get numTables => _numTables;

  set numTables(int numTables) => _numTables = numTables;

  int get numSeats => _numSeats;

  set numSeats(int numSeats) => _numSeats = numSeats;

  List<String> get timeslots => _timeslots;

  set timeslots(List<String> timeslots) => _timeslots = timeslots;

  int? get id => _id;

  set id(int? id) => _id = id;

  String get location => _location;

  set location(String value) {
    _location = value;
  }

  String get imgUrl => _imgUrl;

  set imgUrl(String value) {
    _imgUrl = value;
  }
}
