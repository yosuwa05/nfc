class BusinessDetailsEntity {
  final String? id;
  final String companyName;
  final String companyAddress;
  final String companyMobile;
  final String companyEmail;
  final String companyWebsite;
  final String? companyLogo;

  BusinessDetailsEntity({
    this.id,
    required this.companyName,
    required this.companyAddress,
    required this.companyMobile,
    required this.companyEmail,
    required this.companyWebsite,
    this.companyLogo,
});
}