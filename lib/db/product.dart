import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class ProductService{
  Firestore _firestore= Firestore.instance;
  String ref='products';

  void uploadProduct({String productName,String brand, String category,String picture, double price}){
    var id=Uuid();
    String productId=id.v1();
    _firestore.collection(ref).document(productId).setData({
      'name':productName,
      'id':productId,
      'brand':brand,
      'category':category,
      'price':price,
      'picture':picture
    });
  }

}