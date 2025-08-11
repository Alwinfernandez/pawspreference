// model of cat
// fetch img url from api provider and store it in cat class

class Cat {
  final String imgUrl; // img that are transmitted in url in string format

  Cat({required this.imgUrl});
}

class CatService {
  // static function to fetch 15 cat images from cataas link
  static Future<List<Cat>> fetchRandomCats({int count = 15}) async {
    List<Cat> cats = [];
// random timestamp required to avoid duplication link
    for (int i = 0; i < count; i++) {
      final timestamp = DateTime.now().millisecondsSinceEpoch + i;
      cats.add(Cat(
          imgUrl:
              'https://cataas.com/cat?width=600&height=400&random=$timestamp'));
    }
    return cats;
  }
}
