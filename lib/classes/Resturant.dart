class Restaurant {
  String _name;
  String _description;
  String _image;
  String _foodCategory;
  int _numTables;
  int _numSeats;
  int? _id;

  // Constructor with id parameter
  Restaurant.withId(
      this._id,
      this._name,
      this._description,
      this._image,
      this._foodCategory,
      this._numTables,
      this._numSeats);

  // Constructor without id parameter (sets _id to null)
  Restaurant(
      this._name,
      this._description,
      this._image,
      this._foodCategory,
      this._numTables,
      this._numSeats)
      : _id = null;

  // Empty constructor
  Restaurant.empty()
      : _name = '',
        _description = '',
        _image = '',
        _foodCategory = '',
        _numTables = 0,
        _numSeats = 0,
        _id = null;

  String get name => _name;
  set name(String name) => _name = name;

  String get description => _description;
  set description(String description) => _description = description;

  String get image => _image;
  set image(String image) => _image = image;

  String get foodCategory => _foodCategory;
  set foodCategory(String foodCategory) => _foodCategory = foodCategory;

  int get numTables => _numTables;
  set numTables(int numTables) => _numTables = numTables;

  int get numSeats => _numSeats;
  set numSeats(int numSeats) => _numSeats = numSeats;

  int? get id => _id;
  set id(int? id) => _id = id;
}
