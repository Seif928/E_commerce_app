class Location {
  final String id;
  final String city;
  final String country;
  final String imgUrl;
  final bool isChosen;

  const Location({
    required this.id,
    required this.city,
    required this.country,
    this.isChosen = false,
    this.imgUrl =
        'https://previews.123rf.com/images/emojoez/emojoez1903/emojoez190300018/119684277-illustrations-design-concept-location-maps-with-road-follow-route-for-destination-drive-by-gps.jpg',
  });

  Location copyWith({
    String? id,
    String? city,
    String? country,
    String? imgUrl,
    bool? isChosen,
  }) {
    return Location(
      id: id ?? this.id,
      city: city ?? this.city,
      country: country ?? this.country,
      imgUrl: imgUrl ?? this.imgUrl,
      isChosen: isChosen ?? this.isChosen,
    );
  }
}