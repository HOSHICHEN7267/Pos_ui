class ItemData{
  String pic;
  String name;
  int price;
  int oz;
  String origin;
  int inventory;
  String id;
  String type;

  ItemData({this.pic, this.name, this.price, this.oz, this.origin, this.inventory, this.id, this.type});

  factory ItemData.fromJson(Map<String, dynamic> json){
    return ItemData(
      pic: json['pic'] as String,
      name: json['name'] as String,
      price: json['price'] as int,
      oz: json['oz'] as int,
      origin: json['origin'] as String,
      inventory: json['inventory'] as int,
      id: json['id'] as String,
      type: json['type'] as String,
    );
  }
}

class InCartData{
  String phone;
  String item;
  int number;
  int price;
  int inventory;
  String id;
  String time;

  InCartData({this.phone, this.item, this.number, this.price, this.inventory, this.id, this.time});

  Map toJson() => {
    'phone': phone,
    'item': item,
    'number': number.toString(),
    'time': time,
  };
}

class DiscountData{
  String discountName;
  int discountPrice;

  DiscountData(this.discountName, this.discountPrice);
}

List<DiscountData> discountDatas = [
  DiscountData('生日優惠', 0),
  DiscountData('週年慶優惠', 0),
];