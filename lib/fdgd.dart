class LocalUser {
  String name;
  String email;
  bool online;
  String profilePhotoUrl;
  String bloodType;
  String phoneNumber;
  String district;

  LocalUser({
    required this.name,
    required this.email,
    required this.online,
    required this.profilePhotoUrl,
    required this.bloodType,
    required this.district,
    required this.phoneNumber,
    required isDonationEnabled,
  });
}