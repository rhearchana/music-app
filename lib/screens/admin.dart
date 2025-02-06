import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../db/category.dart';
import '../db/brand.dart';
import 'add_product.dart';

enum Page { dashboard, manage }

class Admin extends StatefulWidget {
  @override
  _AdminState createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  Page _selectedPage = Page.dashboard;
  MaterialColor active = Colors.red;
  MaterialColor notActive = Colors.grey;
  TextEditingController categoryController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  GlobalKey<FormState> _categoryFormKey = GlobalKey();
  GlobalKey<FormState> _brandFormKey = GlobalKey();
  BrandService _brandService = BrandService();
  CategoryService _categoryService = CategoryService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Admin Panel',style: TextStyle(color: Colors.deepOrange),),
          elevation: 0.0,
          backgroundColor: Colors.white,
        ),
        body: _loadScreen());
  }

  Widget _loadScreen() {
    return ListView(
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.add),
          title: Text("Add product"),
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => AddProduct()));
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.add_circle),
          title: Text("Add category"),
          onTap: () {
            _categoryAlert();
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.add_circle_outline),
          title: Text("Add brand"),
          onTap: () {
            _brandAlert();
          },
        ),
        Divider(),
        ],
    );
  }

  void _categoryAlert() {
    var alert = new AlertDialog(
      content: Form(
        key: _categoryFormKey,
        child: TextFormField(
          controller: categoryController,
          validator: (value) {
            if (value.isEmpty) {
              return 'category cannot be empty';
            }
          },
          decoration: InputDecoration(hintText: "add category"),
        ),
      ),
      actions: <Widget>[
        FlatButton(
            onPressed: () {
              if (categoryController.text != null) {
                _categoryService.createCategory(categoryController.text);
              }
              Fluttertoast.showToast(msg: 'category created');
              Navigator.pop(context);
            },
            child: Text('ADD')),
        FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('CANCEL')),
      ],
    );

    showDialog(context: context, builder: (_) => alert);
  }
  void _brandAlert() {
    var alert = new AlertDialog(
      content: Form(
        key: _brandFormKey,
        child: TextFormField(
          controller: brandController,
          validator: (value){
            if(value.isEmpty){
              return 'category cannot be empty';
            }
          },
          decoration: InputDecoration(
              hintText: "add brand"
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(onPressed: (){
          if(brandController.text != null){
            _brandService.createBrand(brandController.text);
          }
          Fluttertoast.showToast(msg: 'brand added');
          Navigator.pop(context);
        }, child: Text('ADD')),
        FlatButton(onPressed: (){
          Navigator.pop(context);
        }, child: Text('CANCEL')),

      ],
    );

    showDialog(context: context, builder: (_) => alert);
  }
}
