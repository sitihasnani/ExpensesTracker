import 'dart:convert';

import 'package:expenses_tracker/core/models/catergory_model.dart';
import 'package:http/http.dart' as http;

class ApiServices {
  final String category_url = 'https://media.halogen.my/experiment/mobile/expenseCategories.json';

  Future<List<CategoryModel>> fetchCategories() async{
    try{
      final response = await http.get(Uri.parse(category_url));
      if(response.statusCode == 200){
        final data = jsonDecode(response.body);
        final List<dynamic> categoryList = data['expenseCategories'];
        return categoryList.map((json) => CategoryModel.fromJson(json)).toList();
      } else{
        throw Exception('Failes to load categories: ${response.statusCode}');
      }
    } catch(e){
      throw Exception('Error fetching categories: $e');
    }
    

  }
}