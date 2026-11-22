class Country {
  final String countryName;
  final String countryFlag; // Keeping for compatibility, we will use flag_4x3 by default
  final String? capital;
  final String? code;
  final String? continent;
  final String? flag1x1;
  final String? flag4x3;

  Country({
    required this.countryName,
    required this.countryFlag,
    this.capital,
    this.code,
    this.continent,
    this.flag1x1,
    this.flag4x3,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      countryName: json['name'] ?? '',
      countryFlag: json['flag_4x3'] ?? json['flag_1x1'] ?? '',
      capital: json['capital'],
      code: json['code'],
      continent: json['continent'],
      flag1x1: json['flag_1x1'],
      flag4x3: json['flag_4x3'],
    );
  }

  String getCountryName() => countryName;
  String getCountryFlag() => countryFlag;

  @override
  String toString() => '$countryName ($countryFlag)';
}
