import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config/config.dart';

class AuthenticatedImage extends StatefulWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final Widget? placeholder;

  const AuthenticatedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.errorBuilder,
    this.placeholder,
  });

  @override
  State<AuthenticatedImage> createState() => _AuthenticatedImageState();
}

class _AuthenticatedImageState extends State<AuthenticatedImage> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  Uint8List? _imageData;
  bool _isLoading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(AuthenticatedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _imageData = null;
    });

    try {
      final token = await _secureStorage.read(key: 'token');
      final imageUrl = widget.imageUrl;

      if (imageUrl == null || imageUrl.isEmpty) {
        // Use placeholder image
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Try to load the image with authentication
      final response = await _fetchImageWithAuth(imageUrl, token);

      if (mounted) {
        setState(() {
          _imageData = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _isLoading = false;
        });
      }
    }
  }

  Future<Uint8List> _fetchImageWithAuth(String imageUrl, String? token) async {
    // First try with query parameter
    if (token != null) {
      try {
        final urlWithToken = AppConfig.getAuthenticatedImageUrl(
          imageUrl,
          token,
        );
        final response = await http.get(Uri.parse(urlWithToken));

        if (response.statusCode == 200) {
          return response.bodyBytes;
        }
      } catch (e) {
        // Fall through to try with headers
      }
    }

    // Try with headers
    final fullUrl = AppConfig.getImageUrl(imageUrl);
    final headers = <String, String>{};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.get(Uri.parse(fullUrl), headers: headers);

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.placeholder ??
          Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey[300],
            child: const Center(child: CircularProgressIndicator()),
          );
    }

    if (_error != null) {
      return widget.errorBuilder?.call(context, _error!, StackTrace.current) ??
          Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey[800],
            child: const Center(
              child: Icon(Icons.broken_image, color: Colors.white54, size: 32),
            ),
          );
    }

    if (_imageData != null) {
      return Image.memory(
        _imageData!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: widget.errorBuilder,
      );
    }

    // Fallback to placeholder
    return widget.placeholder ??
        Container(
          width: widget.width,
          height: widget.height,
          color: Colors.grey[800],
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.white54, size: 32),
          ),
        );
  }
}
