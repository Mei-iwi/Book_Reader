bool checkSourceImage({required String urlImage}) {
  final isAsset = urlImage.startsWith('assets/');
  return isAsset ? true : false;
}
