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
