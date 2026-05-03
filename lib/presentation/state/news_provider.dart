import 'dart:convert';

import 'package:book_reader/data/models/news_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NewsProvider extends ChangeNotifier {
  // Base URL của LitHub
  final String _baseUrl = 'https://lithub.com'; 
  final String _endpoint = '/wp-json/wp/v2/posts';

  bool isLoading = false;
  String? errorMessage;
  
  List<NewsModel> _allNews = [];
  List<NewsModel> displayNews = [];

  Future<void> fetchNews() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      final uri = Uri.parse('$_baseUrl$_endpoint?per_page=15');
      final res = await http.get(uri);
      if (res.statusCode == 200) {
         final List<dynamic> data = jsonDecode(res.body);
         _allNews = data.map((json) => NewsModel.fromJson(json)).toList();
         displayNews = List.from(_allNews);
      } else {
         throw Exception('Lỗi server');
      }
      
    } catch (e) {
      errorMessage = 'Không thể tải tin tức từ LitHub. Vui lòng kiểm tra mạng.';
      print(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void searchNews(String keyword) {
    if (keyword.trim().isEmpty) {
      displayNews = List.from(_allNews);
    } else {
      final query = keyword.toLowerCase();
      displayNews = _allNews.where((news) {
        return news.title.toLowerCase().contains(query) || 
               news.description.toLowerCase().contains(query);
      }).toList();
    }
    notifyListeners();
  }
}