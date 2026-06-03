bool checkSourceImage({required String urlImage}) {
  return !urlImage.startsWith('http://') && !urlImage.startsWith('https://');
}
