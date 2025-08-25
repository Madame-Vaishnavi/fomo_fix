enum ServerEnvironment {
  localhost,
  androidEmulator,
  iosSimulator,
  physicalDevice,
  production,
}

class AppConfig {
  // Server Configuration
  static const bool useLocalServer = true; // Set to false for production

  // Choose your server environment here
  static const ServerEnvironment serverEnvironment =
      ServerEnvironment.localhost;

  // Server URLs for different environments
  static const String localhostUrl = 'http://localhost:8080/api';
  static const String androidEmulatorUrl = 'http://10.0.2.2:8080/api';
  static const String iosSimulatorUrl = 'http://localhost:8080/api';

  // Get the appropriate base URL based on platform and configuration
  static String get baseUrl {
    if (!useLocalServer) {
      return 'https://your-production-server.com/api';
    }

    // For development - choose your environment
    switch (serverEnvironment) {
      case ServerEnvironment.localhost:
        return localhostUrl; // http://localhost:8080/api
      case ServerEnvironment.androidEmulator:
        return androidEmulatorUrl; // http://10.0.2.2:8080/api
      case ServerEnvironment.iosSimulator:
        return iosSimulatorUrl; // http://localhost:8080/api
      case ServerEnvironment.physicalDevice:
        // You'll need to set this to your computer's IP address
        return 'http://192.168.96.1:8080/api'; // Replace with your IP
      case ServerEnvironment.production:
        return 'https://your-production-server.com/api';
    }
  }

  // Helper function to get complete image URL from relative path
  static String getImageUrl(String? relativeImageUrl) {
    if (relativeImageUrl == null || relativeImageUrl.isEmpty) {
      return 'https://picsum.photos/300/200?random=1'; // Default placeholder
    }

    // If it's already a complete URL, return as is
    if (relativeImageUrl.startsWith('http://') ||
        relativeImageUrl.startsWith('https://')) {
      return relativeImageUrl;
    }

    // If it's a relative path, combine with base URL
    // Remove the /api prefix from baseUrl since relativeImageUrl already includes it
    String baseUrlWithoutApi = baseUrl.replaceAll('/api', '');
    return '$baseUrlWithoutApi$relativeImageUrl';
  }

  // Helper function to get authenticated image URL with token
  static String getAuthenticatedImageUrl(
    String? relativeImageUrl,
    String? token,
  ) {
    if (relativeImageUrl == null || relativeImageUrl.isEmpty) {
      return 'https://picsum.photos/300/200?random=1'; // Default placeholder
    }

    // If it's already a complete URL, return as is
    if (relativeImageUrl.startsWith('http://') ||
        relativeImageUrl.startsWith('https://')) {
      return relativeImageUrl;
    }

    // If it's a relative path, combine with base URL
    String baseUrlWithoutApi = baseUrl.replaceAll('/api', '');
    String fullUrl = '$baseUrlWithoutApi$relativeImageUrl';

    // Add token as query parameter if available
    if (token != null && token.isNotEmpty) {
      final uri = Uri.parse(fullUrl);
      final queryParams = Map<String, String>.from(uri.queryParameters);
      queryParams['token'] = token;
      return uri.replace(queryParameters: queryParams).toString();
    }

    return fullUrl;
  }

  // API Endpoints
  static const String eventsEndpoint = '/events';
  static const String usersEndpoint = '/users';
  static const String bookingsEndpoint = '/bookings';

  // App Configuration
  static const String appName = 'FOMO Fix';
  static const String appVersion = '1.0.0';

  // Timeout Configuration
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
