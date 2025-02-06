import 'dart:io';
import 'package:adminmw/db/category.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import'../db/brand.dart';
import '../db/product.dart';

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {

  CategoryService _categoryService = CategoryService();
  BrandService _brandService = BrandService();
  ProductService productService = ProductService();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController productNameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  List<DocumentSnapshot> brands = <DocumentSnapshot>[];
  List<DocumentSnapshot> categories = <DocumentSnapshot>[];
  List<DropdownMenuItem<String>> categoriesDropDown = <
      DropdownMenuItem<String>>[];
  List<DropdownMenuItem<String>> brandsDropDown = <DropdownMenuItem<String>>[];
  String _currentCategory;
  String _currentBrand;
  Color white = Colors.white;
  Color black = Colors.black;
  Color red = Colors.red;
  Color grey = Colors.grey;
  File _image1;
  bool isLoading = false;

  @override
  void initState() {
    _getCategories();
    _getBrands();
  }

  List<DropdownMenuItem<String>> getCategoriesDropdown() {
    List<DropdownMenuItem<String>>items = new List();
    for (int i = 0; i < categories.length; i++) {
      setState(() {
        items.insert(
            0, DropdownMenuItem(child: Text(categories[i].data['category']),
          value: categories[i].data['category'],));
      });
    }
    return items;
  }

  List<DropdownMenuItem<String>> getBrandsDropDown() {
    List<DropdownMenuItem<String>> items = new List();
    for (int i = 0; i < brands.length; i++) {
      setState(() {
        items.insert(0, DropdownMenuItem(child: Text(brands[i].data['brand']),
            value: brands[i].data['brand']));
      });
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0.1,
          backgroundColor: white,
          leading: InkWell(child: Icon(Icons.close, color: black,), onTap: () {
            Navigator.of(context).pop();
            },),
          title: Text("Add Product", style: TextStyle(color: black))
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: isLoading ? CircularProgressIndicator() : Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OutlineButton(
                          borderSide: BorderSide(
                              color: grey.withOpacity(0.5), width: 2.5),
                          onPressed: () {
                            _selectImage(ImagePicker.pickImage(
                                source: ImageSource.gallery));
                          },
                          child: _displayChild1()
                      ),
                    ),
                  ),


                ],
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Enter a Product name with 10 characters maximum',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: red, fontSize: 12.0),),
              ),

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextFormField(
                  controller: productNameController,
                  decoration: InputDecoration(
                      hintText: "Product Name"
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'You must enter the product name';
                    } else if (value.length > 10) {
                      return 'Product name cannot have more than 10 letters';
                    }
                  },
                ),
              ),
//Select category
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Category: ', style: TextStyle(color: red),),
                  ),
                  DropdownButton(items: categoriesDropDown,
                    onChanged: changeSelectedCategory,
                    value: _currentCategory,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Brands: ', style: TextStyle(color: red),),
                  ),
                  DropdownButton(items: brandsDropDown,
                    onChanged: changeSelectedBrand,
                    value: _currentBrand,),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Price",

                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'You must enter the price';
                    }
                  },
                ),
              ),


              FlatButton(
                color: red,
                textColor: white,
                child: Text('Add Products'),
                onPressed: () {
                  validateAndUpload();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  _getCategories() async {
    List<DocumentSnapshot> data = await _categoryService.getCategories();
    print(data.length);
    setState(() {
      categories = data;
      categoriesDropDown = getCategoriesDropdown();
      _currentCategory = categories[0].data['category'];
    });
  }

  _getBrands() async {
    List<DocumentSnapshot> data = await _brandService.getBrands();
    print(data.length);
    setState(() {
      brands = data;
      brandsDropDown = getBrandsDropDown();
      _currentBrand = brands[0].data['brand'];
    });
  }


  changeSelectedCategory(String selectedCategory) {
    setState(() => _currentCategory = selectedCategory);
  }

  changeSelectedBrand(String selectedBrand) {
    setState(() => _currentBrand = selectedBrand);
  }

  void _selectImage(Future<File> pickImage) async {
    File tempImg = await pickImage;
    setState(() => _image1 = tempImg);
  }

  Widget _displayChild1() {
    if (_image1 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 70, 14, 70),
        child: new Icon(Icons.add, color: grey,),
      );
    } else {
      return Image.file(_image1, fit: BoxFit.fill, width: double.infinity,);
    }
  }


  void validateAndUpload() async {
    if (_formKey.currentState.validate()) {
      setState(() => isLoading = true);
      if (_image1 != null) {
        String imageUrl1;

        final FirebaseStorage storage = FirebaseStorage.instance;
        final String picture1 = "1${DateTime
            .now()
            .millisecondsSinceEpoch
            .toString()}.jpg";
        StorageUploadTask task1 = storage.ref().child(picture1).putFile(
            _image1);
        storage.ref().child(picture1).putFile(_image1);

        StorageTaskSnapshot snapshot =
        await task1.onComplete.then((snapshot) => snapshot);

        task1.onComplete.then((snapshot) async {
          imageUrl1 = await snapshot.ref.getDownloadURL();


          productService.uploadProduct(
            productName: productNameController.text,
            price: double.parse(priceController.text),
            picture: imageUrl1,
            brand: _currentBrand.toString(),
            category: _currentCategory.toString(),
          );

          _formKey.currentState.reset();
          setState(() => isLoading = false);

          Fluttertoast.showToast(msg: 'Product Added');
          Navigator.pop(context);
        });
      } else {
        setState(() => isLoading = false);

        Fluttertoast.showToast(msg: 'all the images must be provided');
      }
    }
  }

}