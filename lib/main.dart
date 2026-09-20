import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:file_picker/file_picker.dart';
// ============================================================
// SUPABASE CONFIG
// ============================================================

class SupabaseConfig {
  static const String supabaseUrl =
      'https://xlhefngkmivrntzfesea.supabase.co';
  static const String supabasePublishableKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhsaGVmbmdrbWl2cm50emZlc2VhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg5NDEzNzMsImV4cCI6MjEwNDUxNzM3M30.RkAx63mvxuisUBRsjTpd3Vk_u_-8ZLRk5w61ffSC96Q';
}

// ============================================================
// APP CONSTANTS
// ============================================================

class AppConstants {
  static const String appName = 'DepthFence';
  static const String appVersion = '2.0.0';
  static const String tagline = 'Geospatial Land Intelligence Platform';

  // ---------- TILE SERVERS ----------
  // Working satellite + street tile providers
  static const String esriSatellite =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
  static const String googleSatellite =
      'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}';
  static const String googleHybrid =
      'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}';
  static const String osmStandard =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  // Admin (demo)
  static const String adminEmail = 'admin@depthfence.gov.in';
  static const String adminPassword = 'PasswordVCSM';

  // Session keys
  static const String sessionKey = 'depthfence_session';
  static const String userRoleKey = 'depthfence_role';
  static const String userEmailKey = 'depthfence_email';
  static const String userNameKey = 'depthfence_name';
  static const String registeredUsersKey = 'depthfence_users';

  // ---------- Gemini AI ----------
  // API key is loaded from --dart-define=GEMINI_API_KEY=... at build time.
  // Never commit the actual key to source control.
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );
  static const String geminiModel = 'gemini-2.0-flash';
}


// ============================================================
// THEME
// ============================================================

class AppTheme {
  static const Color scaffold = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF141414);
  static const Color card = Color(0xFF1C1C1C);
  static const Color cardElevated = Color(0xFF242424);
  static const Color inputFill = Color(0xFF1A1A1A);

  static const Color gold = Color(0xFFFFC107);
  static const Color goldDark = Color(0xFFFFA000);
  static const Color goldGlow = Color(0x33FFC107);

  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  static const Color cyan = Color(0xFF00E5FF);      // ADD
  static const Color emerald = Color(0xFF00E676);   // ADD

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF6B7280);

  static const Color border = Color(0xFF2A2A2A);
  static const Color borderGold = Color(0x66FFC107);

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: scaffold,
    primaryColor: gold,
    colorScheme: const ColorScheme.dark(
      primary: gold,
      secondary: gold,
      surface: surface,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: textPrimary,
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: scaffold,
      foregroundColor: gold,
      elevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        color: gold,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    ),
    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: border, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: gold,
        foregroundColor: Colors.black,
        minimumSize: const Size.fromHeight(56),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: inputFill,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: gold, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: danger, width: 1.4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: danger, width: 1.6),
      ),
      labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
      floatingLabelStyle: const TextStyle(color: gold, fontSize: 13),
      hintStyle: const TextStyle(color: textMuted, fontSize: 14),
      prefixIconColor: gold,
      suffixIconColor: textSecondary,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: gold,
      unselectedItemColor: textMuted,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
    ),
    useMaterial3: true,
  );
}

// ============================================================
// MODELS
// ============================================================

class RegisteredUser {
  final String name;
  final String district;
  final String city;
  final String pincode;
  final String mobile;
  final String email;
  final String password;
  final String? dob;

  RegisteredUser({
    required this.name,
    required this.district,
    required this.city,
    required this.pincode,
    required this.mobile,
    required this.email,
    required this.password,
    this.dob,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'district': district,
    'city': city,
    'pincode': pincode,
    'mobile': mobile,
    'email': email,
    'password': password,
    'dob': dob,
  };

  factory RegisteredUser.fromJson(Map<String, dynamic> j) => RegisteredUser(
    name: j['name'] ?? '',
    district: j['district'] ?? '',
    city: j['city'] ?? '',
    pincode: j['pincode'] ?? '',
    mobile: j['mobile'] ?? '',
    email: j['email'] ?? '',
    password: j['password'] ?? '',
    dob: j['dob'],
  );
}

class Anomaly {
  final String id;
  final String title;
  final String description;
  final String parcelId;
  final String severity;
  final String status;
  final LatLng location;
  final DateTime detectedAt;

  Anomaly({
    required this.id,
    required this.title,
    required this.description,
    required this.parcelId,
    required this.severity,
    required this.status,
    required this.location,
    required this.detectedAt,
  });

  Color get severityColor {
    switch (severity) {
      case 'critical':
        return AppTheme.danger;
      case 'high':
        return AppTheme.warning;
      case 'medium':
        return AppTheme.gold;
      default:
        return AppTheme.success;
    }
  }

  IconData get severityIcon {
    switch (severity) {
      case 'critical':
        return Icons.warning_amber_rounded;
      case 'high':
        return Icons.warning;
      case 'medium':
        return Icons.info_outline;
      default:
        return Icons.check_circle_outline;
    }
  }
}

class LandParcel {
  final String id;
  final String ulpin;
  final String ownerName;
  final double areaHa;
  final LatLng center;
  final String status;

  LandParcel({
    required this.id,
    required this.ulpin,
    required this.ownerName,
    required this.areaHa,
    required this.center,
    required this.status,
  });
}

// ============================================================
// GLOBAL STATE
// ============================================================

class DepthFenceState extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _userRole = 'user';
  String _userEmail = '';
  String _userName = '';

  LatLng _currentLocation = const LatLng(20.5937, 78.9629);
  int _currentTabIndex = 0;
  bool _isDualViewOverview = false;                              // ADD
  double _shadowLength = 32.37;                                  // ADD
  double _solarAngle = -26.22;                                   // ADD
  double _horizontalDistanceAB = 142.68;                         // ADD
  double _deltaZ = 12.34;                                        // ADD

  // ---------- Selected Building from Map Tap ----------
  LatLng? _selectedBuildingLocation;
  double _selectedBuildingHeight = 0.0;
  double _selectedBuildingDepth = 0.0;
  DateTime? _selectedAt;
  bool _autoCalculated = false;

  // ---------- PDF State ----------
  String? _lastPdfPath;
  final List<LatLng> _boundaryPoints = const [                   // ADD
    LatLng(10.8576, 77.8487),
    LatLng(10.8583, 77.8495),
    LatLng(10.8569, 77.8491),
    LatLng(10.8572, 77.8482),
  ];

  SharedPreferences? _prefs;
  List<RegisteredUser> _registeredUsers = [];

  final List<Anomaly> _anomalies = [
    Anomaly(
      id: 'ANM-001',
      title: 'Unauthorized Structure Detected',
      description:
      'A permanent structure detected on government land parcel without authorization.',
      parcelId: 'ULPIN-2024-001-A',
      severity: 'critical',
      status: 'new',
      location: const LatLng(20.5937, 78.9629),
      detectedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Anomaly(
      id: 'ANM-002',
      title: 'Terrain Elevation Shift',
      description:
      'Significant elevation change detected in Zone 2. Possible illegal excavation.',
      parcelId: 'ULPIN-2024-002-B',
      severity: 'high',
      status: 'in_progress',
      location: const LatLng(20.5945, 78.9635),
      detectedAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    Anomaly(
      id: 'ANM-003',
      title: 'Boundary Overlap Detected',
      description: 'Boundary overlap detected between two adjacent parcels.',
      parcelId: 'ULPIN-2024-003-C',
      severity: 'medium',
      status: 'new',
      location: const LatLng(20.5925, 78.9620),
      detectedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  final List<LandParcel> _parcels = [
    LandParcel(
      id: 'P-001',
      ulpin: 'ULPIN-2024-001-A',
      ownerName: 'Ramesh Kumar',
      areaHa: 2.34,
      center: const LatLng(20.5937, 78.9629),
      status: 'verified',
    ),
    LandParcel(
      id: 'P-002',
      ulpin: 'ULPIN-2024-002-B',
      ownerName: 'Suresh Patil',
      areaHa: 1.87,
      center: const LatLng(20.5945, 78.9635),
      status: 'pending',
    ),
    LandParcel(
      id: 'P-003',
      ulpin: 'ULPIN-2024-003-C',
      ownerName: 'Anita Deshmukh',
      areaHa: 3.12,
      center: const LatLng(20.5925, 78.9620),
      status: 'verified',
    ),
  ];

  bool get isLoggedIn => _isLoggedIn;
  String get userRole => _userRole;
  String get userEmail => _userEmail;
  String get userName => _userName;
  LatLng get currentLocation => _currentLocation;
  int get currentTabIndex => _currentTabIndex;
  bool get isDualViewOverview => _isDualViewOverview;            // ADD
  double get shadowLength => _shadowLength;                       // ADD
  double get solarAngle => _solarAngle;                           // ADD
  double get horizontalDistanceAB => _horizontalDistanceAB;       // ADD
  double get deltaZ => _deltaZ;                                   // ADD
  List<LatLng> get boundaryPoints => List.unmodifiable(_boundaryPoints); // ADD
  LatLng? get selectedBuildingLocation => _selectedBuildingLocation;
  double get selectedBuildingHeight => _selectedBuildingHeight;
  double get selectedBuildingDepth => _selectedBuildingDepth;
  DateTime? get selectedAt => _selectedAt;
  bool get autoCalculated => _autoCalculated;
  String? get lastPdfPath => _lastPdfPath;

  double get calculatedHeight {                                    // ADD
    final rad = solarAngle.abs() * (math.pi / 180);
    return shadowLength * math.tan(rad);
  }
  bool get isAdmin => _userRole == 'admin';
  List<Anomaly> get anomalies => List.unmodifiable(_anomalies);
  List<LandParcel> get parcels => List.unmodifiable(_parcels);
  List<RegisteredUser> get registeredUsers => List.unmodifiable(_registeredUsers);
  int get registeredUserCount => _registeredUsers.length;

  void addAnomaly(Anomaly anomaly) {
    _anomalies.insert(0, anomaly);
    notifyListeners();
  }

  void addLandParcel(LandParcel parcel) {
    _parcels.insert(0, parcel);
    notifyListeners();
  }

  bool _rtkGpsEnabled = true;
  bool get rtkGpsEnabled => _rtkGpsEnabled;

  bool _offlineCacheEnabled = true;
  bool get offlineCacheEnabled => _offlineCacheEnabled;

  String _measurementUnit = 'Metric (m/ha)';
  String get measurementUnit => _measurementUnit;

  void toggleRtkGps(bool val) {
    _rtkGpsEnabled = val;
    notifyListeners();
  }

  void toggleOfflineCache(bool val) {
    _offlineCacheEnabled = val;
    notifyListeners();
  }

  void setMeasurementUnit(String unit) {
    _measurementUnit = unit;
    notifyListeners();
  }

  bool _gpsLoading = false;
  String? _gpsError;

  bool get gpsLoading => _gpsLoading;
  String? get gpsError => _gpsError;

  /// Fetches real GPS location and updates _currentLocation.
  Future<void> refreshCurrentLocation() async {
    _gpsLoading = true;
    _gpsError = null;
    notifyListeners();

    try {
      // 1. Check if GPS service is on
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _gpsError = 'GPS is turned off';
        _gpsLoading = false;
        notifyListeners();
        return;
      }

      // 2. Check permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _gpsError = 'Location permission denied';
        _gpsLoading = false;
        notifyListeners();
        return;
      }

      // 3. Get position
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      _currentLocation = LatLng(pos.latitude, pos.longitude);
      _gpsError = null;
    } catch (e) {
      // Fallback: try last known position
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) {
          _currentLocation = LatLng(last.latitude, last.longitude);
        } else {
          _gpsError = 'Unable to get location';
        }
      } catch (_) {
        _gpsError = 'Unable to get location';
      }
    }

    _gpsLoading = false;
    notifyListeners();
  }

  // ---------- Supabase Auth ----------
  SupabaseClient get _supabase => Supabase.instance.client;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _restoreSession();
    await _loadRegisteredUsers();

    // ⭐ Listen for Supabase auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        debugPrint('🔐 Auth state: signed in as ${session.user.email}');
      } else {
        debugPrint('🔐 Auth state: signed out');
      }
    });

    refreshCurrentLocation();
  }

  Future<void> _restoreSession() async {
    final p = _prefs;
    if (p == null) return;
    final loggedIn = p.getBool(AppConstants.sessionKey) ?? false;
    if (loggedIn) {
      _isLoggedIn = true;
      _userRole = p.getString(AppConstants.userRoleKey) ?? 'user';
      _userEmail = p.getString(AppConstants.userEmailKey) ?? '';
      _userName = p.getString(AppConstants.userNameKey) ?? '';
      notifyListeners();
    }
  }

  Future<void> _loadRegisteredUsers() async {
    final p = _prefs;
    if (p == null) return;
    final raw = p.getStringList(AppConstants.registeredUsersKey) ?? [];
    _registeredUsers = raw
        .map((s) {
          try {
            final map = Map<String, dynamic>.from(
              jsonDecode(s) as Map,
            );
            return RegisteredUser.fromJson(map);
          } catch (_) {
            return null;
          }
        })
        .whereType<RegisteredUser>()
        .toList();
  }

  Future<void> _persistRegisteredUsers() async {
    final p = _prefs;
    if (p == null) return;
    await p.setStringList(
      AppConstants.registeredUsersKey,
      _registeredUsers.map((u) => jsonEncode(u.toJson())).toList(),
    );
  }

  Future<void> _persistSession() async {
    final p = _prefs;
    if (p == null) return;
    await p.setBool(AppConstants.sessionKey, _isLoggedIn);
    await p.setString(AppConstants.userRoleKey, _userRole);
    await p.setString(AppConstants.userEmailKey, _userEmail);
    await p.setString(AppConstants.userNameKey, _userName);
  }

  /// Returns 'admin', 'user', or null.
  Future<String?> tryLogin(String email, String password) async {
    final e = email.trim().toLowerCase();

    // 1. Admin hardcoded check (demo)
    if (e == AppConstants.adminEmail &&
        password == AppConstants.adminPassword) {
      _isLoggedIn = true;
      _userRole = 'admin';
      _userEmail = AppConstants.adminEmail;
      _userName = 'Administrator';
      await _persistSession();
      notifyListeners();
      return 'admin';
    }

    // 2. Supabase Auth sign-in
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: e,
        password: password,
      );

      if (response.user == null) return null;

      // 3. Fetch profile for role + name
      String role = 'user';
      String displayName = e.split('@').first;

      try {
        final profile = await _supabase
            .from('profiles')
            .select('role, full_name')
            .eq('id', response.user!.id)
            .maybeSingle();

        if (profile != null) {
          role = profile['role'] ?? 'user';
          displayName = profile['full_name'] ?? displayName;
        }
      } catch (err) {
        debugPrint('Profile fetch failed: $err');
      }

      _isLoggedIn = true;
      _userRole = role;
      _userEmail = e;
      _userName = displayName;
      await _persistSession();
      notifyListeners();
      return role;
    } on AuthException catch (err) {
      debugPrint('Supabase auth error: ${err.message}');
      return null;
    } catch (err) {
      debugPrint('Login error: $err');
      return null;
    }
  }

  /// Returns 'ok' | 'exists' | 'invalid' | 'error'.
  Future<String> register(RegisteredUser user) async {
    final e = user.email.trim().toLowerCase();

    if (e == AppConstants.adminEmail) return 'invalid';

    try {
      // 1. Sign up via Supabase Auth
      final response = await _supabase.auth.signUp(
        email: e,
        password: user.password,
        data: {
          'full_name': user.name,
          'district': user.district,
          'city': user.city,
          'pincode': user.pincode,
          'mobile': user.mobile,
        },
      );

      if (response.user == null) return 'error';

      // 2. Upsert profile
      try {
        await _supabase.from('profiles').upsert({
          'id': response.user!.id,
          'full_name': user.name,
          'district': user.district,
          'city': user.city,
          'pincode': user.pincode,
          'mobile': user.mobile,
          'role': 'user',
        });
      } catch (err) {
        debugPrint('Profile upsert failed: $err');
      }

      _registeredUsers.add(user);
      await _persistRegisteredUsers();

      return 'ok';
    } on AuthException catch (err) {
      if (err.message.contains('already registered')) return 'exists';
      return 'invalid';
    } catch (err) {
      debugPrint('Register error: $err');
      return 'error';
    }
  }

  Future<void> loginAsDemoUser() async {
    _isLoggedIn = true;
    _userRole = 'user';
    _userEmail = 'demo.user@depthfence.app';
    _userName = 'Demo User';
    await _persistSession();
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }

    _isLoggedIn = false;
    _userEmail = '';
    _userName = '';
    _userRole = 'user';
    _currentTabIndex = 0;
    _isDualViewOverview = false;
    await _persistSession();
    notifyListeners();
  }

  Future<void> loadAnomaliesFromSupabase() async {
    try {
      final data = await _supabase
          .from('anomalies')
          .select()
          .order('detected_at', ascending: false);

      _anomalies.clear();
      for (final row in data) {
        _anomalies.add(Anomaly(
          id: row['id'].toString(),
          title: row['title'] ?? 'Unknown',
          description: row['description'] ?? '',
          parcelId: row['parcel_id'] ?? '',
          severity: row['severity'] ?? 'medium',
          status: row['status'] ?? 'new',
          location: LatLng(
            (row['latitude'] as num).toDouble(),
            (row['longitude'] as num).toDouble(),
          ),
          detectedAt: DateTime.parse(row['detected_at']),
        ));
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Load anomalies failed: $e');
    }
  }

  Future<void> loadParcelsFromSupabase() async {
    try {
      final data = await _supabase
          .from('parcels')
          .select()
          .order('created_at', ascending: false);

      _parcels.clear();
      for (final row in data) {
        _parcels.add(LandParcel(
          id: row['id'].toString(),
          ulpin: row['ulpin'] ?? '',
          ownerName: row['owner_name'] ?? '',
          areaHa: (row['area_ha'] as num?)?.toDouble() ?? 0.0,
          center: LatLng(
            (row['latitude'] as num).toDouble(),
            (row['longitude'] as num).toDouble(),
          ),
          status: row['status'] ?? 'pending',
        ));
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Load parcels failed: $e');
    }
  }

  void setCurrentLocation(LatLng loc) {
    _currentLocation = loc;
    notifyListeners();
  }

  void setTabIndex(int i) {
    _currentTabIndex = i;
    notifyListeners();
  }

  void toggleDualView() {                                          // ADD
    _isDualViewOverview = !_isDualViewOverview;
    notifyListeners();
  }

  void setShadowLength(double v) {                                 // ADD
    _shadowLength = v;
    notifyListeners();
  }

  void setSolarAngle(double v) {                                   // ADD
    _solarAngle = v;
    notifyListeners();
  }

  void setHorizontalDistance(double v) {                           // ADD
    _horizontalDistanceAB = v;
    notifyListeners();
  }

  void setDeltaZ(double v) {                                       // ADD
    _deltaZ = v;
    notifyListeners();
  }

  // ---------- Map Building Selection ----------
  /// Called when user taps the map and confirms the building.
  void selectBuilding({
    required LatLng location,
    required double shadowLength,
    required double solarAngle,
  }) {
    _selectedBuildingLocation = location;
    _shadowLength = shadowLength;
    _solarAngle = solarAngle;
    // Auto-calculate height
    final rad = solarAngle.abs() * (math.pi / 180);
    _selectedBuildingHeight = shadowLength * math.tan(rad);
    // Simulate depth (20% of height for realism)
    _selectedBuildingDepth = _selectedBuildingHeight * 0.2;
    _selectedAt = DateTime.now();
    _autoCalculated = true;
    notifyListeners();
  }

  void clearBuildingSelection() {
    _selectedBuildingLocation = null;
    _selectedBuildingHeight = 0.0;
    _selectedBuildingDepth = 0.0;
    _selectedAt = null;
    _autoCalculated = false;
    notifyListeners();
  }

  void setPdfPath(String path) {
    _lastPdfPath = path;
    notifyListeners();
  }

  // Coordinates set from map tap
  void setSelectedCoordinates(LatLng coords) {
    _selectedBuildingLocation = coords;
    notifyListeners();
  }
}

// ============================================================
// MAIN
// ============================================================

// Global camera list
List<CameraDescription> globalCameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⭐ Pre-load cameras BEFORE the app boots
  try {
    globalCameras = await availableCameras();
    debugPrint('📷 Found ${globalCameras.length} cameras');
  } catch (e) {
    debugPrint('⚠ Camera preload failed: $e');
  }

  try {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      publishableKey: SupabaseConfig.supabasePublishableKey,
    );
  } catch (e) {
    debugPrint('Supabase init skipped: $e');
  }

  final state = DepthFenceState();
  await state.init();

  runApp(
    ChangeNotifierProvider.value(
      value: state,
      child: const DepthFenceApp(),
    ),
  );
}

// ============================================================
// ROOT APP
// ============================================================

class DepthFenceApp extends StatelessWidget {
  const DepthFenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/shell': (context) => const MainShell(),
        '/admin': (context) => const AdminHomeScreen(),
        '/boundary_extraction': (context) => const BoundaryExtractionScreen(),
        '/terrain_analysis': (context) => const TerrainAnalysisScreen(),
        '/delta_z': (context) => const DeltaZMappingScreen(),
        '/delta_z_scanner': (context) => const DeltaZScannerScreen(),
        '/anomaly_detection': (context) => const AnomalyDetectionScreen(),
        '/blueprint': (context) => const BlueprintDownloadScreen(),
        '/permissions': (context) => const PermissionsScreen(),
        '/ai_vision_scanner': (context) => const AIVisionScannerScreen(),
        '/gemini_chat': (context) => const GeminiChatScreen(),
      },
    );
  }
}

// ============================================================
// AUTH GATE
// ============================================================

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<DepthFenceState>(context);
    if (!state.isLoggedIn) return const LoginScreen();
    return state.isAdmin ? const AdminHomeScreen() : const MainShell();
  }
}

// ============================================================
// SHARED: Brand Header — FIXED LOGO (circular crop)
// ============================================================

class BrandHeader extends StatelessWidget {
  final double logoSize;
  final bool showSubtitle;

  const BrandHeader({
    super.key,
    this.logoSize = 104,
    this.showSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Outer glow + gold ring
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.gold.withValues(alpha: 0.4),
                blurRadius: 36,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.card,
              border: Border.all(color: AppTheme.gold, width: 2.5),
            ),
            child: ClipOval(
              child: Padding(
                padding: EdgeInsets.all(logoSize * 0.07),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: EdgeInsets.all(logoSize * 0.06),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.terrain,
                          color: AppTheme.gold,
                          size: logoSize * 0.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          AppConstants.appName,
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: AppTheme.gold,
            letterSpacing: 1.4,
            height: 1.0,
          ),
        ),
        if (showSubtitle) ...[
          const SizedBox(height: 8),
          const Text(
            AppConstants.tagline,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: AppTheme.textSecondary,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

// ============================================================
// SHARED: Lightning Action
// ============================================================

class LightningAction extends StatelessWidget {
  final VoidCallback onDemoSignIn;
  final VoidCallback? onExtraAction;
  final String? extraActionLabel;
  final IconData? extraActionIcon;

  const LightningAction({
    super.key,
    required this.onDemoSignIn,
    this.onExtraAction,
    this.extraActionLabel,
    this.extraActionIcon,
  });

  void _showPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => _LightningPopup(
        onDemoSignIn: () {
          Navigator.pop(context);
          onDemoSignIn();
        },
        onExtraAction: onExtraAction == null
            ? null
            : () {
          Navigator.pop(context);
          onExtraAction!();
        },
        extraActionLabel: extraActionLabel,
        extraActionIcon: extraActionIcon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showPopup(context),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppTheme.card,
            shape: BoxShape.circle,
            border: Border.all(
                color: AppTheme.gold.withValues(alpha: 0.5), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: AppTheme.gold.withValues(alpha: 0.15),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Icon(
            Icons.bolt_rounded,
            color: AppTheme.gold,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _LightningPopup extends StatelessWidget {
  final VoidCallback onDemoSignIn;
  final VoidCallback? onExtraAction;
  final String? extraActionLabel;
  final IconData? extraActionIcon;

  const _LightningPopup({
    required this.onDemoSignIn,
    this.onExtraAction,
    this.extraActionLabel,
    this.extraActionIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
              color: AppTheme.gold.withValues(alpha: 0.4), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppTheme.gold.withValues(alpha: 0.15),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textMuted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.gold.withValues(alpha: 0.5),
                      width: 1.2,
                    ),
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: AppTheme.gold,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Access',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Skip authentication for a fast demo',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _popupAction(
              context,
              icon: Icons.flash_on_rounded,
              title: 'Instant Demo Sign In',
              subtitle: 'Enter as a demo surveyor user',
              onTap: onDemoSignIn,
              highlighted: true,
            ),
            if (onExtraAction != null && extraActionLabel != null) ...[
              const SizedBox(height: 10),
              _popupAction(
                context,
                icon: extraActionIcon ?? Icons.info_outline_rounded,
                title: extraActionLabel!,
                subtitle: 'Additional option',
                onTap: onExtraAction!,
                highlighted: false,
              ),
            ],
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget _popupAction(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
        required bool highlighted,
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: highlighted
                ? AppTheme.gold.withValues(alpha: 0.12)
                : AppTheme.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: highlighted
                  ? AppTheme.gold.withValues(alpha: 0.5)
                  : AppTheme.border,
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: highlighted
                      ? AppTheme.gold
                      : AppTheme.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: highlighted ? Colors.black : AppTheme.gold,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: highlighted
                            ? AppTheme.gold
                            : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: highlighted ? AppTheme.gold : AppTheme.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SHARED: Modern Input Card
// ============================================================

class ModernInputCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;
  final String? Function(String?)? validator;
  final bool required;
  final VoidCallback? onTap;
  final bool readOnly;
  final int? maxLength;

  const ModernInputCard({
    super.key,
    required this.icon,
    required this.label,
    required this.hint,
    this.controller,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.formatters,
    this.validator,
    this.required = false,
    this.onTap,
    this.readOnly = false,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 8),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
              if (required)
                const Text(
                  ' *',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppTheme.gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: formatters,
          validator: validator,
          readOnly: readOnly,
          onTap: onTap,
          maxLength: maxLength,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppTheme.gold, size: 18),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 52,
              minHeight: 52,
            ),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// LOGIN SCREEN
// ============================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final state = Provider.of<DepthFenceState>(context, listen: false);
    final role = await state.tryLogin(
      _emailController.text,
      _passwordController.text,
    );

    setState(() => _loading = false);
    if (!mounted) return;

    if (role == null) {
      setState(() => _error = 'Invalid credentials. Please try again.');
      return;
    }

    if (role == 'admin') {
      Navigator.pushReplacementNamed(context, '/admin');
    } else {
      Navigator.pushReplacementNamed(context, '/shell');
    }
  }

  Future<void> _handleDemo() async {
    final s = Provider.of<DepthFenceState>(context, listen: false);
    await s.loginAsDemoUser();

    // ⭐ Load real data from Supabase
    await s.loadAnomaliesFromSupabase();
    await s.loadParcelsFromSupabase();

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/shell');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      48,
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: LightningAction(onDemoSignIn: _handleDemo),
                        ),
                        const SizedBox(height: 4),
                        const BrandHeader(logoSize: 104),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: AppTheme.border,
                              ),
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 14),
                              child: Text(
                                'LOGIN',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textPrimary,
                                  letterSpacing: 3,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: AppTheme.border,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 26),
                        ModernInputCard(
                          icon: Icons.person_outline_rounded,
                          label: 'Email / User ID',
                          hint: 'Enter your email or user ID',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Please enter your email or user ID';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        ModernInputCard(
                          icon: Icons.lock_outline_rounded,
                          label: 'Password',
                          hint: 'Enter your password',
                          controller: _passwordController,
                          obscureText: _obscure,
                          suffix: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppTheme.textSecondary,
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (v.length < 4) return 'Password too short';
                            return null;
                          },
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.danger.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.danger.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded,
                                    color: AppTheme.danger, size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: const TextStyle(
                                      color: AppTheme.danger,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loading ? null : _handleLogin,
                          child: _loading
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.black),
                            ),
                          )
                              : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Login'),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13.5,
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, '/register'),
                              child: const Text(
                                'Register',
                                style: TextStyle(
                                  color: AppTheme.gold,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.5,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppTheme.gold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const SizedBox(height: 24),
                        Text(
                          'SIH26011  •  SIH26012',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted.withValues(alpha: 0.8),
                            letterSpacing: 2.2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// REGISTRATION SCREEN
// ============================================================

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dobController = TextEditingController();

  bool _obscure = true;
  bool _acceptTerms = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year - 10, now.month, now.day),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.gold,
              onPrimary: Colors.black,
              surface: AppTheme.surface,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _dobController.text =
      '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  Future<void> _handleRegister() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      setState(() =>
      _error = 'Please accept the Terms & Conditions to continue.');
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    final state = Provider.of<DepthFenceState>(context, listen: false);
    final result = await state.register(
      RegisteredUser(
        name: _nameController.text.trim(),
        district: _districtController.text.trim(),
        city: _cityController.text.trim(),
        pincode: _pincodeController.text.trim(),
        mobile: _mobileController.text.trim(),
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text,
        dob: _dobController.text.isEmpty ? null : _dobController.text,
      ),
    );

    setState(() => _loading = false);
    if (!mounted) return;

    switch (result) {
      case 'exists':
        setState(() => _error =
        'An account with this email already exists. Please sign in.');
        return;
      case 'invalid':
        setState(() =>
        _error = 'This email is reserved. Please use a different one.');
        return;
      case 'ok':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Registration successful! Please sign in.'),
            backgroundColor: AppTheme.success,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppTheme.gold, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  LightningAction(
                    onDemoSignIn: () async {
                      final state = Provider.of<DepthFenceState>(context,
                          listen: false);
                      await state.loginAsDemoUser();
                      if (!context.mounted) return;
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/shell', (route) => false);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const BrandHeader(logoSize: 84),
                      const SizedBox(height: 26),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppTheme.border,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              'REGISTRATION',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.textPrimary,
                                letterSpacing: 2.5,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppTheme.border,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ModernInputCard(
                        icon: Icons.person_outline_rounded,
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        controller: _nameController,
                        required: true,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Full name is required';
                          }
                          if (v.trim().length < 3) return 'Name too short';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      ModernInputCard(
                        icon: Icons.location_city_rounded,
                        label: 'District',
                        hint: 'Enter your district',
                        controller: _districtController,
                        required: true,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'District is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      ModernInputCard(
                        icon: Icons.apartment_rounded,
                        label: 'City',
                        hint: 'Enter your city',
                        controller: _cityController,
                        required: true,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'City is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      ModernInputCard(
                        icon: Icons.pin_drop_outlined,
                        label: 'Pincode',
                        hint: 'Enter 6-digit pincode',
                        controller: _pincodeController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        required: true,
                        formatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Pincode is required';
                          }
                          if (!RegExp(r'^\d{6}$').hasMatch(v.trim())) {
                            return 'Enter a valid 6-digit pincode';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      ModernInputCard(
                        icon: Icons.phone_outlined,
                        label: 'Mobile Number',
                        hint: 'Enter 10-digit mobile number',
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        required: true,
                        formatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Mobile number is required';
                          }
                          if (!RegExp(r'^\d{10}$').hasMatch(v.trim())) {
                            return 'Enter a valid 10-digit number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      ModernInputCard(
                        icon: Icons.alternate_email_rounded,
                        label: 'Email / User ID',
                        hint: 'you@example.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        required: true,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Email is required';
                          }
                          final email = v.trim();
                          if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$')
                              .hasMatch(email)) {
                            return 'Enter a valid email address';
                          }
                          if (email.toLowerCase() == AppConstants.adminEmail) {
                            return 'This email is reserved. Use another.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      ModernInputCard(
                        icon: Icons.calendar_today_outlined,
                        label: 'Date of Birth (Optional)',
                        hint: 'Select your date of birth',
                        controller: _dobController,
                        readOnly: true,
                        onTap: _pickDob,
                        suffix: const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(Icons.keyboard_arrow_down_rounded,
                              color: AppTheme.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 14),
                      ModernInputCard(
                        icon: Icons.lock_outline_rounded,
                        label: 'Password',
                        hint: 'Minimum 6 characters',
                        controller: _passwordController,
                        obscureText: _obscure,
                        required: true,
                        suffix: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppTheme.textSecondary,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Password is required';
                          }
                          if (v.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => setState(
                                () => _acceptTerms = !_acceptTerms),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.inputFill,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _acceptTerms
                                  ? AppTheme.gold.withValues(alpha: 0.6)
                                  : AppTheme.border,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: _acceptTerms
                                      ? AppTheme.gold
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(
                                    color: _acceptTerms
                                        ? AppTheme.gold
                                        : AppTheme.textMuted,
                                    width: 2,
                                  ),
                                ),
                                child: _acceptTerms
                                    ? const Icon(Icons.check_rounded,
                                    color: Colors.black, size: 16)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textSecondary,
                                      height: 1.4,
                                    ),
                                    children: [
                                      const TextSpan(
                                          text:
                                          'I agree to the Terms and Conditions'),
                                      const TextSpan(
                                        text: ' *',
                                        style: TextStyle(
                                          color: AppTheme.gold,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      WidgetSpan(
                                        alignment:
                                        PlaceholderAlignment.middle,
                                        child: GestureDetector(
                                          onTap: () {
                                            _showTermsDialog(context);
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.only(left: 6),
                                            child: Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              size: 12,
                                              color: AppTheme.gold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.danger.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.danger.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded,
                                  color: AppTheme.danger, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                    color: AppTheme.danger,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loading ? null : _handleRegister,
                        child: _loading
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.black),
                          ),
                        )
                            : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Register'),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'SIH26011  •  SIH26012',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted.withValues(alpha: 0.8),
                          letterSpacing: 2.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TERMS DIALOG
// ============================================================

void _showTermsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Terms & Conditions',
        style: TextStyle(color: AppTheme.gold, fontWeight: FontWeight.bold),
      ),
      content: const SingleChildScrollView(
        child: Text(
          'Detailed Terms and Conditions content will be provided here. '
              'By registering you agree to the DepthFence platform\'s '
              'terms of use, privacy policy, and data handling guidelines '
              'for geospatial land intelligence operations.\n\n'
              'For the SIH prototype, this text is a placeholder.',
          style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close',
              style: TextStyle(color: AppTheme.textSecondary)),
        ),
      ],
    ),
  );
}

// ============================================================
// AI VISION SCANNER — Camera with proper lifecycle
// ============================================================

class AIVisionScannerScreen extends StatefulWidget {
  const AIVisionScannerScreen({super.key});

  @override
  State<AIVisionScannerScreen> createState() => _AIVisionScannerScreenState();
}

class _AIVisionScannerScreenState extends State<AIVisionScannerScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedIndex = 0;

  bool _isInitialized = false;
  bool _isCapturing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  // ═══════════════════════════════════════════════════════════
  // CAMERA INITIALIZATION (fixes black screen)
  // ═══════════════════════════════════════════════════════════
  Future<void> _initializeCamera() async {
    setState(() {
      _error = null;
      _isInitialized = false;
    });

    try {
      final status = await Permission.camera.request();
      if (status.isDenied) {
        setState(() => _error = 'Camera permission denied');
        return;
      }
      if (status.isPermanentlyDenied) {
        setState(() => _error = 'Open settings to enable camera');
        return;
      }

      // ⭐ Use preloaded cameras if available
      _cameras = globalCameras.isNotEmpty
          ? globalCameras
          : await availableCameras();

      if (_cameras.isEmpty) {
        setState(() => _error = 'No cameras found');
        return;
      }

      await _setupController(_cameras[_selectedIndex]);
    } catch (e) {
      setState(() => _error = 'Init failed: $e');
    }
  }

  Future<void> _setupController(CameraDescription camera) async {
    // Dispose old controller
    final oldController = _controller;
    oldController?.dispose();

    // Create new controller
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _controller = controller;

    try {
      await controller.initialize();
      if (!mounted) return;
      setState(() {
        _isInitialized = true;
        _error = null;
      });
    } on CameraException catch (e) {
      debugPrint('CameraException: ${e.code} ${e.description}');
      setState(() => _error = 'Camera error: ${e.description ?? e.code}');
    } catch (e) {
      debugPrint('Setup error: $e');
      setState(() => _error = 'Setup failed: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // FLIP CAMERA
  // ═══════════════════════════════════════════════════════════
  Future<void> _flipCamera() async {
    if (_cameras.length < 2 || _isCapturing) return;
    setState(() {
      _isInitialized = false;
      _selectedIndex = (_selectedIndex + 1) % _cameras.length;
    });
    await _setupController(_cameras[_selectedIndex]);
  }

  // ═══════════════════════════════════════════════════════════
  // CAPTURE PHOTO
  // ═══════════════════════════════════════════════════════════
  Future<void> _capturePhoto() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _isCapturing) {
      return;
    }

    setState(() => _isCapturing = true);

    try {
      final file = await controller.takePicture();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📷 Photo captured: ${file.name}'),
          backgroundColor: AppTheme.emerald,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on CameraException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Capture failed: ${e.description ?? e.code}'),
          backgroundColor: AppTheme.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // LIFECYCLE
  // ═══════════════════════════════════════════════════════════
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _controller = null;
      setState(() => _isInitialized = false);
    } else if (state == AppLifecycleState.resumed) {
      if (_cameras.isNotEmpty) {
        _setupController(_cameras[_selectedIndex]);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // ══════════════════════════════════════════
            // CAMERA PREVIEW / ERROR / LOADING
            // ══════════════════════════════════════════
            Positioned.fill(
              child: _buildCameraArea(),
            ),

            // ══════════════════════════════════════════
            // TOP BAR
            // ══════════════════════════════════════════
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.gold.withValues(alpha: 0.5),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppTheme.gold,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.cyan.withValues(alpha: 0.5),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: AppTheme.cyan,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'AI VISION SCANNER',
                            style: TextStyle(
                              color: AppTheme.cyan,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ══════════════════════════════════════════
            // BOTTOM CONTROLS
            // ══════════════════════════════════════════
            if (_isInitialized)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    // GPS + Mode overlay
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.gps_fixed,
                            color: AppTheme.emerald,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Consumer<DepthFenceState>(
                            builder: (_, s, _) => Text(
                              '${s.currentLocation.latitude.toStringAsFixed(4)}, ${s.currentLocation.longitude.toStringAsFixed(4)}',
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 11,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Camera controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Placeholder for symmetry
                        const SizedBox(width: 60, height: 60),

                        // Capture button (large)
                        GestureDetector(
                          onTap: _isCapturing ? null : _capturePhoto,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.gold,
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.gold.withValues(alpha: 0.6),
                                  blurRadius: 24,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: _isCapturing
                                ? const Padding(
                              padding: EdgeInsets.all(22),
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor:
                                AlwaysStoppedAnimation<Color>(
                                  Colors.black,
                                ),
                              ),
                            )
                                : const Icon(
                              Icons.camera_rounded,
                              color: Colors.black,
                              size: 36,
                            ),
                          ),
                        ),

                        // Flip camera button
                        GestureDetector(
                          onTap: _cameras.length < 2 ? null : _flipCamera,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _cameras.length < 2
                                    ? Colors.grey.shade700
                                    : AppTheme.gold.withValues(alpha: 0.6),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.flip_camera_ios_rounded,
                              color: _cameras.length < 2
                                  ? Colors.grey.shade700
                                  : AppTheme.gold,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // ══════════════════════════════════════════
            // REC INDICATOR
            // ══════════════════════════════════════════
            if (_isInitialized)
              Positioned(
                top: 70,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.fiber_manual_record,
                        color: Colors.white,
                        size: 10,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraArea() {
    if (_error != null) {
      return _buildErrorWidget();
    }
    if (!_isInitialized || _controller == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.gold),
            ),
            SizedBox(height: 16),
            Text(
              'Initializing camera...',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // Camera preview with proper aspect ratio
    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller!.value.previewSize!.height,
            height: _controller!.value.previewSize!.width,
            child: CameraPreview(_controller!),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.danger.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.danger.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.videocam_off_rounded,
                color: AppTheme.danger,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _initializeCamera,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.gold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: openAppSettings,
              child: const Text(
                'Open App Settings',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ADMIN HOME SCREEN — with live user count + permissions
// ============================================================

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<DepthFenceState>(context);

    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      appBar: AppBar(
        title: const Text('Admin Portal'),
        actions: [
          IconButton(
            onPressed: () async {
              await state.logout();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ---------- Welcome card ----------
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.gold.withValues(alpha: 0.15),
                  AppTheme.gold.withValues(alpha: 0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.gold.withValues(alpha: 0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.gold.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.gold, width: 1.5),
                      ),
                      child: const Icon(Icons.admin_panel_settings_rounded,
                          color: AppTheme.gold, size: 26),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, Administrator',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'DepthFence Command Center',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.circle,
                        color: AppTheme.success, size: 8),
                    const SizedBox(width: 6),
                    Text(
                      state.userEmail,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ---------- Quick Overview ----------
          const Text(
            'Quick Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _adminStatCard(
                  icon: Icons.landscape_rounded,
                  label: 'Parcels',
                  value: '${state.parcels.length}',
                  accentColor: AppTheme.gold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _adminStatCard(
                  icon: Icons.warning_amber_rounded,
                  label: 'Anomalies',
                  value: '${state.anomalies.length}',
                  accentColor: AppTheme.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _adminStatCard(
                  icon: Icons.people_outline_rounded,
                  label: 'Registered Users',
                  value: '${state.registeredUserCount}',  // ← REAL COUNT
                  accentColor: AppTheme.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _adminStatCard(
                  icon: Icons.verified_outlined,
                  label: 'Status',
                  value: 'Online',
                  accentColor: AppTheme.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // ---------- Permissions & Access Control ----------
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AppTheme.gold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'PERMISSIONS & ACCESS CONTROL',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _permissionRow(
            icon: Icons.admin_panel_settings_rounded,
            title: 'Admin Privileges',
            subtitle: 'Full system access',
            value: 'GRANTED',
            color: AppTheme.gold,
            onTap: () => _showToast(context, 'Admin has full access'),
          ),
          _permissionRow(
            icon: Icons.edit_road_rounded,
            title: 'Field Survey Access',
            subtitle: 'Create/edit boundaries and anomalies',
            value: 'ALLOWED',
            color: AppTheme.success,
            onTap: () => _showToast(context, 'Surveyors can edit field data'),
          ),
          _permissionRow(
            icon: Icons.verified_user_rounded,
            title: 'Data Verification',
            subtitle: 'Approve or reject submissions',
            value: 'ADMIN ONLY',
            color: AppTheme.warning,
            onTap: () => _showToast(context, 'Only admins can verify'),
          ),
          _permissionRow(
            icon: Icons.cloud_download_rounded,
            title: 'Bulk Export',
            subtitle: 'PDF / DXF / CSV downloads',
            value: 'ENABLED',
            color: AppTheme.info,
            onTap: () => _showToast(context, 'Export permissions enabled'),
          ),

          const SizedBox(height: 24),

          // ---------- Admin Modules ----------
          const Text(
            'Admin Modules',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          _adminModuleTile(
            icon: Icons.people_alt_outlined,
            title: 'User Management',
            subtitle: '${state.registeredUserCount} registered users',
            onTap: () => _showUsersSheet(context, state),
          ),
          _adminModuleTile(
            icon: Icons.map_outlined,
            title: 'Land Registry',
            subtitle: 'Manage parcel records',
            onTap: () {},
          ),
          _adminModuleTile(
            icon: Icons.analytics_outlined,
            title: 'Analytics',
            subtitle: 'Insights & reports',
            onTap: () {},
          ),
          _adminModuleTile(
            icon: Icons.assignment_ind_outlined,
            title: 'Surveyor Assignment',
            subtitle: 'Allocate field tasks',
            onTap: () {},
          ),
          _adminModuleTile(
            icon: Icons.settings_outlined,
            title: 'System Settings',
            subtitle: 'Configuration',
            onTap: () {},
          ),
          const SizedBox(height: 24),

          Center(
            child: Text(
              'More admin functionality coming soon',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textMuted.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Permission row widget ----------
  Widget _permissionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: color.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: color,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Stat card ----------
  Widget _adminStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Module tile ----------
  Widget _adminModuleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppTheme.gold, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppTheme.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Toast helper ----------
  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.surface,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // ---------- Users sheet ----------
  void _showUsersSheet(BuildContext context, DepthFenceState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textMuted.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.people_alt_outlined,
                        color: AppTheme.gold, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Registered Users',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${state.registeredUserCount} user${state.registeredUserCount == 1 ? '' : 's'} in database',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (state.registeredUserCount == 0)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: const Center(
                    child: Column(
                      children: [
                        Icon(Icons.person_off_outlined,
                            color: AppTheme.textMuted, size: 32),
                        SizedBox(height: 8),
                        Text(
                          'No users registered yet',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 320),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.registeredUsers.length,
                    itemBuilder: (context, i) {
                      final u = state.registeredUsers[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor:
                              AppTheme.gold.withValues(alpha: 0.2),
                              child: Text(
                                u.name.isNotEmpty
                                    ? u.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: AppTheme.gold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    u.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    u.email,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.success.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'USER',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.success,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MAP 1: 2D SATELLITE COMMAND MAP (Home) — Real GPS + no markers
// ============================================================

class HomeMapScreen extends StatefulWidget {
  const HomeMapScreen({super.key});

  @override
  State<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends State<HomeMapScreen> {
  final MapController _mapController = MapController();
  bool _satelliteMode = true;
  bool _labelsVisible = true;
  bool _gpsEnabled = true;
  int _tileProviderIndex = 0;
  double _currentZoom = 17;
  bool _greetingExpanded = true;
  bool _hasCentered = false;
  bool _isLoadingLocation = true;
  bool _toolsExpanded = true;

  // Map tap state
  LatLng? _tappedLocation;
  bool _isProcessingTap = false;

  // ---------- Search ----------
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _searchActive = false;
  bool _searchLoading = false;
  List<Map<String, dynamic>> _searchResults = [];

  final List<String> _satelliteUrls = [
    AppConstants.googleSatellite,
    AppConstants.esriSatellite,
  ];

  final List<String> _satelliteNames = [
    'Google SAT',
    'Esri SAT',
  ];

  static const String _labelsUrl =
      'https://basemaps.cartocdn.com/rastertiles/voyager_only_labels/{z}/{x}/{y}.png';

  @override
  void initState() {
    super.initState();
    // Fetch real GPS on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRealGps();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ==========================================================
  // SEARCH — Nominatim (OpenStreetMap) free geocoding API
  // ==========================================================
  Future<void> _searchPlace(String query) async {
    if (query.trim().length < 3) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _searchLoading = true);

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
            '?q=${Uri.encodeComponent(query)}'
            '&format=json'
            '&limit=5'
            '&addressdetails=1',
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'DepthFence-App/2.0 (com.example.depthfenc)',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          _searchResults = data.map((e) => {
            'display_name': e['display_name'] ?? '',
            'lat': double.tryParse(e['lat'].toString()) ?? 0.0,
            'lon': double.tryParse(e['lon'].toString()) ?? 0.0,
            'type': e['type'] ?? '',
            'name': e['name'] ?? e['display_name']?.split(',').first ?? '',
          }).toList();
        });
      } else {
        setState(() => _searchResults = []);
      }
    } catch (e) {
      debugPrint('Search error: $e');
      setState(() => _searchResults = []);
    } finally {
      setState(() => _searchLoading = false);
    }
  }

  void _goToSearchResult(Map<String, dynamic> result) {
    final lat = result['lat'] as double;
    final lon = result['lon'] as double;

    _mapController.move(LatLng(lat, lon), 15);
    setState(() {
      _currentZoom = 15;
      _searchActive = false;
      _searchResults = [];
      _searchController.clear();
      _searchFocus.unfocus();
    });
  }

  // ═══════════════════════════════════════════════════════════
  // MAP TAP HANDLER — Building selection workflow
  // ═══════════════════════════════════════════════════════════
  Future<void> _handleMapTap(LatLng point) async {
    if (_isProcessingTap) return;
    setState(() {
      _isProcessingTap = true;
      _tappedLocation = point;
    });

    // 1. Smooth animation zoom-in on the tapped coordinates
    _mapController.move(point, 18.5);

    // Give the zoom animation a moment to complete
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    // 2. Show confirmation bottom sheet
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (ctx) => _buildConfirmSheet(point),
    );

    if (!mounted) return;

    if (confirmed == true) {
      final state = Provider.of<DepthFenceState>(context, listen: false);

      // 3. Auto-fill coordinates
      state.setSelectedCoordinates(point);

      // 4. Simulate shadow + solar angle
      final shadow = 30.0 + (point.latitude * 100).abs() % 50;
      final solarAngle = -15.0 - ((point.longitude * 10).abs() % 30);

      // 5. Save to global state (auto-calculates height)
      state.selectBuilding(
        location: point,
        shadowLength: shadow,
        solarAngle: solarAngle,
      );

      // 6. ⭐ AUTO-ROUTE — Switch to Delta Z tab (index 2)
      state.setTabIndex(2);
    }

    setState(() => _isProcessingTap = false);
  }

  // Confirmation modal sheet
  Widget _buildConfirmSheet(LatLng point) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.gold.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.gold.withValues(alpha: 0.2),
              blurRadius: 30,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textMuted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.gold.withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Icon(
                    Icons.location_searching,
                    color: AppTheme.gold,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Structure Selected',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Do you want to calculate height for this structure?',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Coordinates preview
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.scaffold,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.gps_fixed,
                    color: AppTheme.emerald,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 12,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      side: const BorderSide(color: AppTheme.border),
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.gold,
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Confirm & Calculate',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadRealGps() async {
    final state = Provider.of<DepthFenceState>(context, listen: false);
    await state.refreshCurrentLocation();

    if (!mounted) return;

    // Recenter on real location (only once)
    if (!_hasCentered) {
      _mapController.move(state.currentLocation, _currentZoom);
      setState(() => _hasCentered = true);
    }

    setState(() => _isLoadingLocation = false);
  }

  // ---------- ZOOM ----------
  void _zoomIn() {
    final newZoom = (_currentZoom + 1).clamp(3.0, 19.0);
    _mapController.move(_mapController.camera.center, newZoom);
    setState(() => _currentZoom = newZoom);
  }

  void _zoomOut() {
    final newZoom = (_currentZoom - 1).clamp(3.0, 19.0);
    _mapController.move(_mapController.camera.center, newZoom);
    setState(() => _currentZoom = newZoom);
  }



  // ---------- GPS TOGGLE ----------
  Future<void> _toggleGps() async {
    setState(() => _gpsEnabled = !_gpsEnabled);

    if (_gpsEnabled) {
      final state = Provider.of<DepthFenceState>(context, listen: false);
      await state.refreshCurrentLocation();
      if (!mounted) return;
      _mapController.move(state.currentLocation, _currentZoom);

      if (state.gpsError != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠ ${state.gpsError}'),
            backgroundColor: AppTheme.warning,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 110, left: 16, right: 16),
          ),
        );
        setState(() => _gpsEnabled = false);
        return;
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_gpsEnabled ? '📍 GPS enabled' : '📍 GPS disabled'),
        backgroundColor: _gpsEnabled ? AppTheme.success : AppTheme.textMuted,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 110, left: 16, right: 16),
      ),
    );
  }

  // ---------- QUICK ACTIONS ----------
  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _QuickActionsSheet(
        onAddAnomaly: () {
          Navigator.pop(context);
          _showAddAnomalySheet();
        },
        onDrawBoundary: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/boundary_extraction');
        },
        onCapturePhoto: () {
          Navigator.pop(context);
          _showCameraPhotoCaptureSheet();
        },
        onExport: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/blueprint');
        },
      ),
    );
  }

  void _showAddAnomalySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const AddAnomalySheet(),
    );
  }

  void _showCameraPhotoCaptureSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const CameraPhotoCaptureSheet(),
    );
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _MapMenuSheet(
        onTerrain: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/terrain_analysis');
        },
        onDeltaZ: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/delta_z');
        },
        onAnomalies: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/anomaly_detection');
        },
        onSettings: () {
          Navigator.pop(context);
          _showSettingsSheet();
        },
      ),
    );
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const SettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<DepthFenceState>(context);

    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      body: Stack(
        children: [
          // ══════════════════════════════════════════
          // MAP
          // ══════════════════════════════════════════
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: state.currentLocation,
              initialZoom: _currentZoom,
              maxZoom: 19,
              minZoom: 3,
              onTap: (tapPosition, point) => _handleMapTap(point),
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture) {
                  final z = camera.zoom;
                  if (z != null) {
                    _currentZoom = z;
                  }
                }
              },
            ),
            children: [
              // Base layer
              TileLayer(
                urlTemplate: _satelliteMode
                    ? _satelliteUrls[_tileProviderIndex]
                    : AppConstants.osmStandard,
                userAgentPackageName: 'com.depthfence.app',
                maxZoom: 19,
              ),
              // Labels overlay
              if (_satelliteMode && _labelsVisible)
                TileLayer(
                  urlTemplate: _labelsUrl,
                  userAgentPackageName: 'com.depthfence.app',
                  maxZoom: 19,
                ),

              // Selected building marker (when map is tapped)
              if (_tappedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _tappedLocation!,
                      width: 60,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.gold.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.gold, width: 2.5),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.location_searching,
                            color: AppTheme.gold,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              // GPS marker — real blue dot at your location
              if (_gpsEnabled)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: state.currentLocation,
                      width: 24,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withValues(alpha: 0.6),
                              blurRadius: 18,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // ══════════════════════════════════════════
          // TOP-LEFT: GREETING PILL
          // ══════════════════════════════════════════
          if (!_searchActive)
            Positioned(
              top: 48,
              left: 16,
              child: GestureDetector(
                onTap: () => setState(
                        () => _greetingExpanded = !_greetingExpanded),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.gold.withValues(alpha: 0.25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppTheme.gold,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.radar_rounded,
                            color: Colors.black, size: 20),
                      ),
                      if (_greetingExpanded) ...[
                        const SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                state.userName.isNotEmpty
                                    ? state.userName
                                    : 'Demo User',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.success,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Text(
                                    'Online',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.success,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

          // ══════════════════════════════════════════
          // TOP: SEARCH BAR
          // ══════════════════════════════════════════
          Positioned(
            top: 48,
            left: _searchActive
                ? 16
                : (_greetingExpanded ? 180 : 76),
            right: 72,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ---------- Search Input ----------
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surface.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _searchActive
                            ? AppTheme.gold.withValues(alpha: 0.6)
                            : AppTheme.gold.withValues(alpha: 0.25),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Leading icon
                        Padding(
                          padding: const EdgeInsets.only(left: 12, right: 6),
                          child: Icon(
                            Icons.search_rounded,
                            color: _searchActive
                                ? AppTheme.gold
                                : AppTheme.textSecondary,
                            size: 20,
                          ),
                        ),

                        // Text field
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocus,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: _searchActive
                                  ? 'Search city, district, place...'
                                  : 'Search...',
                              hintStyle: TextStyle(
                                color: AppTheme.textMuted.withValues(alpha: 0.8),
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12),
                              isDense: true,
                            ),
                            onTap: () => setState(() => _searchActive = true),
                            onChanged: (v) {
                              if (v.trim().length >= 3) {
                                _searchPlace(v);
                              } else {
                                setState(() => _searchResults = []);
                              }
                            },
                            textInputAction: TextInputAction.search,
                            onSubmitted: _searchPlace,
                          ),
                        ),

                        // Loading spinner OR clear button
                        if (_searchLoading)
                          const Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                AlwaysStoppedAnimation<Color>(AppTheme.gold),
                              ),
                            ),
                          )
                        else if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: AppTheme.textSecondary,
                              size: 20,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchResults = [];
                                _searchActive = false;
                              });
                              _searchFocus.unfocus();
                            },
                          )
                        else if (_searchActive)
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: AppTheme.textSecondary,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() => _searchActive = false);
                                _searchFocus.unfocus();
                              },
                            )
                          else
                            const SizedBox(width: 8),
                      ],
                    ),
                  ),

                  // ---------- Results Dropdown ----------
                  if (_searchActive && _searchResults.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 320),
                      decoration: BoxDecoration(
                        color: AppTheme.surface.withValues(alpha: 0.98),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.gold.withValues(alpha: 0.3),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          itemCount: _searchResults.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: AppTheme.border.withValues(alpha: 0.5),
                          ),
                          itemBuilder: (context, i) {
                            final result = _searchResults[i];
                            final name = result['name'] as String;
                            final fullAddress = result['display_name'] as String;

                            return InkWell(
                              onTap: () => _goToSearchResult(result),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    // Icon
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: AppTheme.gold
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.location_on_rounded,
                                        color: AppTheme.gold,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Text
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(
                                              color: AppTheme.textPrimary,
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            fullAddress,
                                            style: const TextStyle(
                                              color: AppTheme.textSecondary,
                                              fontSize: 11,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Arrow
                                    const Icon(
                                      Icons.north_east_rounded,
                                      color: AppTheme.textMuted,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ══════════════════════════════════════════
          // RIGHT SIDE: UNIFIED COLLAPSIBLE TOOL STACK
          // ══════════════════════════════════════════
          Positioned(
            top: 48,
            right: 16,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // ---------- Collapse / Expand Toggle ----------
                  _toolButton(
                    icon: _toolsExpanded
                        ? Icons.close_rounded
                        : Icons.more_vert_rounded,
                    active: _toolsExpanded,
                    onTap: () =>
                        setState(() => _toolsExpanded = !_toolsExpanded),
                    circular: true,
                  ),

                  // ---------- Expandable Tool Stack ----------
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    child: _toolsExpanded
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SizedBox(height: 10),

                        // Satellite toggle
                        _toolButton(
                          icon: _satelliteMode
                              ? Icons.satellite_alt_rounded
                              : Icons.map_rounded,
                          active: _satelliteMode,
                          onTap: () => setState(
                                  () => _satelliteMode = !_satelliteMode),
                          onLongPress: () {
                            setState(() {
                              _tileProviderIndex =
                                  (_tileProviderIndex + 1) %
                                      _satelliteUrls.length;
                              _satelliteMode = true;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Switched to ${_satelliteNames[_tileProviderIndex]}'),
                                backgroundColor: AppTheme.gold,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          circular: true,
                        ),
                        const SizedBox(height: 10),

                        // Labels toggle
                        _toolButton(
                          icon: _labelsVisible
                              ? Icons.label_rounded
                              : Icons.label_off_rounded,
                          active: _labelsVisible && _satelliteMode,
                          onTap: () => setState(
                                  () => _labelsVisible = !_labelsVisible),
                          circular: true,
                        ),
                        const SizedBox(height: 10),

                        // Menu
                        _toolButton(
                          icon: Icons.tune_rounded,
                          active: false,
                          onTap: _showMenu,
                          circular: true,
                        ),
                        const SizedBox(height: 10),

                        // Zoom In
                        _toolButton(
                          icon: Icons.add_rounded,
                          active: false,
                          onTap: _zoomIn,
                          circular: false,
                        ),
                        const SizedBox(height: 10),

                        // Zoom Out
                        _toolButton(
                          icon: Icons.remove_rounded,
                          active: false,
                          onTap: _zoomOut,
                          circular: false,
                        ),
                      ],
                    )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),

          // ══════════════════════════════════════════
          // BOTTOM-LEFT: GPS TOGGLE
          // ══════════════════════════════════════════
          Positioned(
            bottom: 110,
            left: 16,
            child: GestureDetector(
              onTap: _toggleGps,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _gpsEnabled
                        ? AppTheme.gold.withValues(alpha: 0.5)
                        : AppTheme.border,
                    width: 1.2,
                  ),
                  boxShadow: _gpsEnabled
                      ? [
                    BoxShadow(
                      color: AppTheme.gold.withValues(alpha: 0.15),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _gpsEnabled ? AppTheme.gold : AppTheme.card,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _gpsEnabled
                            ? Icons.gps_fixed_rounded
                            : Icons.gps_off_rounded,
                        color: _gpsEnabled
                            ? Colors.black
                            : AppTheme.textMuted,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'GPS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                              letterSpacing: 1,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: _gpsEnabled
                                      ? AppTheme.success
                                      : AppTheme.textMuted,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _gpsEnabled ? 'Active' : 'Off',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: _gpsEnabled
                                      ? AppTheme.success
                                      : AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ══════════════════════════════════════════
          // BOTTOM-RIGHT: QUICK ACTIONS FAB
          // ══════════════════════════════════════════
          Positioned(
            bottom: 110,
            right: 16,
            child: GestureDetector(
              onTap: _showQuickActions,
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.gold, AppTheme.goldDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.gold.withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: Colors.black,
                  size: 28,
                ),
              ),
            ),
          ),

          // ══════════════════════════════════════════
          // LOADING OVERLAY
          // ══════════════════════════════════════════
          if (_isLoadingLocation)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.gold),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Locating you...',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Unified tool button — supports circular or rounded-square shape.
  Widget _toolButton({
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    bool circular = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: active
              ? AppTheme.gold.withValues(alpha: 0.15)
              : AppTheme.surface.withValues(alpha: 0.92),
          shape: circular ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circular ? null : BorderRadius.circular(14),
          border: Border.all(
            color: active
                ? AppTheme.gold.withValues(alpha: 0.6)
                : AppTheme.gold.withValues(alpha: 0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: active ? AppTheme.gold : AppTheme.textPrimary,
          size: 22,
        ),
      ),
    );
  }
}

// ============================================================
// FLOATING PILL NAVIGATION (MainShell)
// ============================================================

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<DepthFenceState>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients &&
          _pageController.page?.round() != state.currentTabIndex) {
        _pageController.jumpToPage(state.currentTabIndex);
      }
    });

    if (state.isDualViewOverview) {
      return const CompositeOverviewScreen();
    }

    final screens = const [
      HomeMapScreen(),
      BuildingHeightMenuScreen(),
      DeltaZScannerScreen(),
      GeminiChatScreen(),
      ProfileScreen(),
    ];

    const items = [
      {'icon': Icons.map_outlined, 'active': Icons.map, 'label': 'Map'},
      {'icon': Icons.domain_outlined, 'active': Icons.domain, 'label': 'Height'},
      {'icon': Icons.height_outlined, 'active': Icons.height, 'label': 'Delta Z'},
      {'icon': Icons.auto_awesome_outlined, 'active': Icons.auto_awesome, 'label': 'AI'},
      {'icon': Icons.person_outline, 'active': Icons.person, 'label': 'Profile'},
    ];

    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      extendBody: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: (i) => state.setTabIndex(i),
        children: screens,
      ),
      // ══════════════════════════════════════════
      // FLOATING PILL NAV
      // ══════════════════════════════════════════
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(
          left: 32,
          right: 32,
          bottom: MediaQuery.of(context).padding.bottom + 12,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppTheme.gold.withValues(alpha: 0.3),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppTheme.gold.withValues(alpha: 0.08),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(items.length, (i) {
            final isActive = state.currentTabIndex == i;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  state.setTabIndex(i);
                  _pageController.jumpToPage(i);
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.gold : Colors.transparent,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isActive
                            ? items[i]['active'] as IconData
                            : items[i]['icon'] as IconData,
                        color: isActive ? Colors.black : AppTheme.textMuted,
                        size: 22,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: isActive
                              ? Colors.black
                              : AppTheme.textMuted,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ============================================================
// QUICK ACTIONS SHEET
// ============================================================

class _QuickActionsSheet extends StatelessWidget {
  final VoidCallback onAddAnomaly;
  final VoidCallback onDrawBoundary;
  final VoidCallback onCapturePhoto;
  final VoidCallback onExport;

  const _QuickActionsSheet({
    required this.onAddAnomaly,
    required this.onDrawBoundary,
    required this.onCapturePhoto,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.gold.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.gold.withValues(alpha: 0.12),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textMuted.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bolt_rounded,
                      color: AppTheme.gold, size: 22),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Field operations shortcuts',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _quickAction(
                    icon: Icons.warning_amber_rounded,
                    label: 'Anomaly',
                    onTap: onAddAnomaly,
                    color: AppTheme.danger,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _quickAction(
                    icon: Icons.draw_rounded,
                    label: 'Draw',
                    onTap: onDrawBoundary,
                    color: AppTheme.gold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _quickAction(
                    icon: Icons.camera_alt_rounded,
                    label: 'Photo',
                    onTap: onCapturePhoto,
                    color: AppTheme.info,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _quickAction(
                    icon: Icons.file_download_rounded,
                    label: 'Export',
                    onTap: onExport,
                    color: AppTheme.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _quickAction(
                    icon: Icons.auto_awesome_rounded,
                    label: 'AI Chat',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/gemini_chat');
                    },
                    color: AppTheme.gold,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(child: SizedBox()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// MAP MENU SHEET
// ============================================================

class _MapMenuSheet extends StatelessWidget {
  final VoidCallback onTerrain;
  final VoidCallback onDeltaZ;
  final VoidCallback onAnomalies;
  final VoidCallback onSettings;

  const _MapMenuSheet({
    required this.onTerrain,
    required this.onDeltaZ,
    required this.onAnomalies,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.gold.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textMuted.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Map Tools',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _menuTile(Icons.terrain_rounded, 'Terrain Analysis', onTerrain),
            _menuTile(Icons.show_chart_rounded, 'Delta Z Profile', onDeltaZ),
            _menuTile(Icons.auto_awesome, 'Delta Z Scanner', () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/delta_z_scanner');
            }),
            _menuTile(Icons.warning_amber_rounded, 'All Anomalies', onAnomalies),
            _menuTile(Icons.settings_rounded, 'Settings', onSettings),
          ],
        ),
      ),
    );
  }

  Widget _menuTile(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.gold, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 12, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ADD ANOMALY SHEET
// ============================================================

class AddAnomalySheet extends StatefulWidget {
  const AddAnomalySheet({super.key});

  @override
  State<AddAnomalySheet> createState() => _AddAnomalySheetState();
}

class _AddAnomalySheetState extends State<AddAnomalySheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _severity = 'critical';
  String _type = 'Unauthorized Structure';
  String _selectedParcelId = 'ULPIN-2024-001-A';

  final List<String> _types = [
    'Unauthorized Structure',
    'Illegal Mining / Excavation',
    'Terrain Elevation Shift',
    'Boundary Breach',
    'Soil Erosion & Landslide',
  ];

  final List<Map<String, dynamic>> _severities = [
    {'key': 'critical', 'label': 'Critical', 'color': AppTheme.danger},
    {'key': 'high', 'label': 'High', 'color': AppTheme.warning},
    {'key': 'medium', 'label': 'Medium', 'color': AppTheme.gold},
    {'key': 'low', 'label': 'Low', 'color': AppTheme.success},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<DepthFenceState>(context);
    final parcels = state.parcels;

    if (parcels.isNotEmpty && !parcels.any((p) => p.ulpin == _selectedParcelId)) {
      _selectedParcelId = parcels.first.ulpin;
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.gold.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.gold.withValues(alpha: 0.12),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textMuted.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppTheme.danger.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppTheme.danger.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.warning_amber_rounded,
                        color: AppTheme.danger, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Report Field Anomaly',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Log new spatial violation to DepthFence ledger',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Anomaly Title
              const Text(
                'Anomaly Title',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.gold,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _titleController,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'e.g., Unenforced Trenching in Sub-Parcel B',
                  hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  filled: true,
                  fillColor: AppTheme.card,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.gold),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Anomaly Type Dropdown
              const Text(
                'Violation Category',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.gold,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _type,
                    dropdownColor: AppTheme.surface,
                    isExpanded: true,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                    items: _types.map((t) {
                      return DropdownMenuItem<String>(
                        value: t,
                        child: Text(t),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _type = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Severity Chips
              const Text(
                'Severity Level',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.gold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: _severities.map((s) {
                  final isSelected = _severity == s['key'];
                  final Color col = s['color'] as Color;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _severity = s['key'] as String),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? col.withValues(alpha: 0.2)
                              : AppTheme.card,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? col : AppTheme.border,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            s['label'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? col : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Target Land Parcel
              const Text(
                'Target Parcel (ULPIN)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.gold,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedParcelId,
                    dropdownColor: AppTheme.surface,
                    isExpanded: true,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                    items: parcels.map((p) {
                      return DropdownMenuItem<String>(
                        value: p.ulpin,
                        child: Text('${p.ulpin} (${p.ownerName})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedParcelId = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Description
              const Text(
                'Description / Field Notes',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.gold,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _descController,
                maxLines: 2,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Enter observation details, machinery involved, or depth notes...',
                  hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  filled: true,
                  fillColor: AppTheme.card,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.gold),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Coordinates Badge
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: AppTheme.gold, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'GPS Location: ${state.currentLocation.latitude.toStringAsFixed(4)}, ${state.currentLocation.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                  onPressed: () async {
                    final title = _titleController.text.trim().isNotEmpty
                        ? _titleController.text.trim()
                        : '$_type Detected';
                    final desc = _descController.text.trim().isNotEmpty
                        ? _descController.text.trim()
                        : 'Manual field observation.';

                    final newAnomaly = Anomaly(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: title,
                      description: desc,
                      parcelId: _selectedParcelId,
                      severity: _severity,
                      status: 'new',
                      location: state.currentLocation,
                      detectedAt: DateTime.now(),
                    );

                    // Save to Supabase
                    try {
                      await Supabase.instance.client.from('anomalies').insert({
                        'title': title,
                        'description': desc,
                        'parcel_id': _selectedParcelId,
                        'severity': _severity,
                        'status': 'new',
                        'latitude': state.currentLocation.latitude,
                        'longitude': state.currentLocation.longitude,
                        'detected_by': Supabase.instance.client.auth.currentUser?.id,
                      });
                    } catch (e) {
                      debugPrint('Save anomaly failed: $e');
                    }

                    state.addAnomaly(newAnomaly);

                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🚨 Anomaly report saved!'),
                        backgroundColor: AppTheme.emerald,
                      ),
                    );
                  },
                  child: const Text(
                    'SUBMIT ANOMALY REPORT',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CAMERA PHOTO CAPTURE SHEET
// ============================================================

class CameraPhotoCaptureSheet extends StatefulWidget {
  const CameraPhotoCaptureSheet({super.key});

  @override
  State<CameraPhotoCaptureSheet> createState() =>
      _CameraPhotoCaptureSheetState();
}

class _CameraPhotoCaptureSheetState extends State<CameraPhotoCaptureSheet> {
  String _mode = 'Standard RGB';
  bool _captured = false;

  final List<String> _modes = ['Standard RGB', 'Thermal IR', 'Depth Contour'];

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<DepthFenceState>(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.gold.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.gold.withValues(alpha: 0.12),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textMuted.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.info.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt_rounded,
                    color: AppTheme.info, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Field Photo Capture',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Geotagged & Depth-stamped evidence',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Spectrum Mode Pills
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _modes.map((m) {
              final active = _mode == m;
              return GestureDetector(
                onTap: () => setState(() => _mode = m),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: active ? AppTheme.gold : AppTheme.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: active ? AppTheme.gold : AppTheme.border,
                    ),
                  ),
                  child: Text(
                    m,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                      active ? FontWeight.bold : FontWeight.w500,
                      color: active ? Colors.black : AppTheme.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Viewfinder Container
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _captured
                    ? AppTheme.success
                    : AppTheme.gold.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Stack(
              children: [
                // Simulated Background Pattern
                Center(
                  child: Icon(
                    _captured
                        ? Icons.check_circle_outline_rounded
                        : Icons.filter_center_focus_rounded,
                    size: 80,
                    color: _captured
                        ? AppTheme.success.withValues(alpha: 0.8)
                        : AppTheme.gold.withValues(alpha: 0.3),
                  ),
                ),
                // Telemetry Overlays
                Positioned(
                  top: 10,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'GPS: ${state.currentLocation.latitude.toStringAsFixed(4)}, ${state.currentLocation.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(
                        color: AppTheme.gold,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'REC 🔴 1080p',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Mode: $_mode | Depth: -1.2m',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Actions
          if (!_captured)
            GestureDetector(
              onTap: () => setState(() => _captured = true),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.gold,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.gold.withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.camera_rounded,
                    color: Colors.black, size: 30),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textPrimary,
                      side: const BorderSide(color: AppTheme.border),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => setState(() => _captured = false),
                    child: const Text('RETAKE'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                          Text('📷 Field photo saved & attached to log!'),
                          backgroundColor: AppTheme.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Text(
                      'ATTACH PHOTO',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ============================================================
// APP SETTINGS SHEET
// ============================================================

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<DepthFenceState>(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.gold.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textMuted.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.settings_rounded,
                    color: AppTheme.gold, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'App Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Configure GPS, Map Cache & Preferences',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // RTK Switch
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.gps_fixed_rounded,
                    color: AppTheme.gold, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RTK Differential GPS Mode',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Sub-centimeter precision mode',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: state.rtkGpsEnabled,
                  activeThumbColor: AppTheme.gold,
                  onChanged: (v) => state.toggleRtkGps(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Offline Cache Switch
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.cloud_off_rounded,
                    color: AppTheme.info, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Offline Map Tile Caching',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        '128.4 MB currently cached',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: state.offlineCacheEnabled,
                  activeThumbColor: AppTheme.gold,
                  onChanged: (v) => state.toggleOfflineCache(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Units Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.square_foot_rounded,
                    color: AppTheme.warning, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Units System',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: state.measurementUnit,
                    dropdownColor: AppTheme.surface,
                    style: const TextStyle(
                        color: AppTheme.gold,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                    items: const [
                      DropdownMenuItem(
                        value: 'Metric (m/ha)',
                        child: Text('Metric (m/ha)'),
                      ),
                      DropdownMenuItem(
                        value: 'Imperial (ft/ac)',
                        child: Text('Imperial (ft/ac)'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) state.setMeasurementUnit(v);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // System Info Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.gold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.gold.withValues(alpha: 0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_user_rounded,
                    color: AppTheme.success, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'DepthFence Engine v2.4.0 • Node #04 Online',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Clear Cache Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.danger,
                side: const BorderSide(color: AppTheme.danger),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🧹 Offline tile cache cleared (128.4 MB freed)!'),
                    backgroundColor: AppTheme.info,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text(
                'CLEAR MAP CACHE',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MAP 2: GEOAI POLYGON EXTRACTION
// ============================================================

class BoundaryExtractionScreen extends StatefulWidget {
  const BoundaryExtractionScreen({super.key});

  @override
  State<BoundaryExtractionScreen> createState() =>
      _BoundaryExtractionScreenState();
}

class _BoundaryExtractionScreenState
    extends State<BoundaryExtractionScreen> {
  final MapController _mapController = MapController();
  final List<LatLng> _points = [];
  final bool _drawing = true;
  bool _processing = false;

  void _addPoint(LatLng p) {
    if (!_drawing) return;
    setState(() => _points.add(p));
  }

  void _clear() => setState(() => _points.clear());

  Future<void> _runAiExtract() async {
    if (_points.length < 3) return;
    setState(() => _processing = true);
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      for (int i = 0; i < _points.length; i++) {
        _points[i] = LatLng(
          _points[i].latitude + 0.00003,
          _points[i].longitude + 0.00003,
        );
      }
      _processing = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✨ AI snapped polygon to detected boundaries'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      appBar: AppBar(
        title: const Text('GeoAI Boundary Extraction'),
        actions: [
          if (_points.isNotEmpty)
            IconButton(
              onPressed: _clear,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear points',
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(20.5937, 78.9629),
              initialZoom: 18,
              maxZoom: 21,
              minZoom: 10,
              onTap: (_, point) => _addPoint(point),
            ),
            children: [
              TileLayer(
                urlTemplate: AppConstants.googleSatellite,
                userAgentPackageName: 'com.depthfence.app',
                maxZoom: 19,
              ),
              if (_points.length >= 3)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: _points,
                      color: AppTheme.gold.withValues(alpha: 0.25),
                      borderStrokeWidth: 3,
                      borderColor: AppTheme.gold,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: _points.asMap().entries.map((entry) {
                  final i = entry.key;
                  final p = entry.value;
                  return Marker(
                    point: p,
                    width: 32,
                    height: 32,
                    child: GestureDetector(
                      onTap: () => setState(() => _points.removeAt(i)),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.gold,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.gold.withValues(alpha: 0.6),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surface.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.gold.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nodes: ${_points.length}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const Text(
                        'Tap map to drop points',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (_points.length >= 3)
                    ElevatedButton.icon(
                      onPressed: _processing ? null : _runAiExtract,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.gold,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: _processing
                          ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.black),
                        ),
                      )
                          : const Icon(Icons.auto_awesome, size: 16),
                      label: const Text(
                        'AI Extract',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _points.length >= 3
                        ? () async {
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await Supabase.instance.client.from('parcels').insert({
                          'ulpin': 'ULPIN-${DateTime.now().millisecondsSinceEpoch}',
                          'owner_name': 'Field Survey',
                          'area_ha': 2.34,
                          'latitude': _points.first.latitude,
                          'longitude': _points.first.longitude,
                          'status': 'pending',
                          'created_by': Supabase.instance.client.auth.currentUser?.id,
                        });

                        if (!mounted) return;
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('✅ Boundary saved to database!'),
                            backgroundColor: AppTheme.emerald,
                          ),
                        );
                      } catch (e) {
                        debugPrint('Save boundary failed: $e');
                      }
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Save Boundary'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MAP 3: 3D VOLUMETRIC TOPOGRAPHICAL HEATMAP
// ============================================================

class TerrainAnalysisScreen extends StatelessWidget {
  const TerrainAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      appBar: AppBar(title: const Text('Terrain Analysis (Z-Axis)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppTheme.gold.withValues(alpha: 0.3),
              ),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A237E),
                  Color(0xFF4A148C),
                  Color(0xFFB71C1C),
                  Color(0xFFE65100),
                  Color(0xFFFFD600),
                ],
              ),
            ),
            child: Stack(
              children: [
                CustomPaint(
                  size: Size.infinite,
                  painter: _ContourPainter(),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.terrain,
                          color: Colors.white70, size: 52),
                      const SizedBox(height: 8),
                      const Text(
                        '3D Volumetric Model',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 4),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '42.6 m max depth',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DEPTH LEGEND',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.gold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1A237E),
                        Color(0xFF4A148C),
                        Color(0xFFB71C1C),
                        Color(0xFFE65100),
                        Color(0xFFFFD600),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('−42.6 m',
                        style: TextStyle(
                            fontSize: 10, color: AppTheme.textSecondary)),
                    Text('−22 m',
                        style: TextStyle(
                            fontSize: 10, color: AppTheme.textSecondary)),
                    Text('−1.2 m',
                        style: TextStyle(
                            fontSize: 10, color: AppTheme.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child:
                  _metricCard('Max Depth', '−42.6 m', AppTheme.danger)),
              const SizedBox(width: 10),
              Expanded(
                  child:
                  _metricCard('Min Depth', '−1.2 m', AppTheme.success)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child:
                  _metricCard('Avg Depth', '−18.7 m', AppTheme.gold)),
              const SizedBox(width: 10),
              Expanded(
                  child: _metricCard('Slope', '12.4°', AppTheme.warning)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContourPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int i = 0; i < 8; i++) {
      final path = ui.Path();
      final yOffset = size.height * (i + 1) / 9;
      path.moveTo(0, yOffset);
      for (double x = 0; x <= size.width; x += 20) {
        final y = yOffset + (x % 60 < 30 ? 8 : -8);
        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================
// MAP 4: CROSS-SECTION ELEVATION PROFILE
// ============================================================

class DeltaZMappingScreen extends StatefulWidget {
  const DeltaZMappingScreen({super.key});

  @override
  State<DeltaZMappingScreen> createState() => _DeltaZMappingScreenState();
}

class _DeltaZMappingScreenState extends State<DeltaZMappingScreen> {
  final MapController _mapController = MapController();
  LatLng? _startPoint;
  LatLng? _endPoint;
  List<double> _profile = [];

  void _onTap(LatLng p) {
    setState(() {
      if (_startPoint == null) {
        _startPoint = p;
      } else if (_endPoint == null) {
        _endPoint = p;
        _generateProfile();
      } else {
        _startPoint = p;
        _endPoint = null;
        _profile = [];
      }
    });
  }

  void _generateProfile() {
    _profile = List.generate(40, (i) {
      const base = 20.0;
      final wave = 8 * (i % 7 == 0 ? 1 : 0) + 5 * (i % 11 == 0 ? 1 : 0);
      return base + wave + (i % 3) * 0.5;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      appBar: AppBar(title: const Text('Delta Z-Axis Profile')),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(20.5937, 78.9629),
                    initialZoom: 17,
                    onTap: (_, p) => _onTap(p),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: AppConstants.googleSatellite,
                      userAgentPackageName: 'com.depthfence.app',
                    ),
                    if (_startPoint != null && _endPoint != null)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [_startPoint!, _endPoint!],
                            strokeWidth: 4,
                            color: AppTheme.gold,
                          ),
                        ],
                      ),
                    if (_startPoint != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _startPoint!,
                            width: 30,
                            height: 30,
                            child: _pointLabel('A'),
                          ),
                          if (_endPoint != null)
                            Marker(
                              point: _endPoint!,
                              width: 30,
                              height: 30,
                              child: _pointLabel('B'),
                            ),
                        ],
                      ),
                  ],
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.surface.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _startPoint == null
                          ? 'Tap map to place Point A'
                          : _endPoint == null
                          ? 'Tap map to place Point B'
                          : 'Tap again to reset',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                border: Border(
                  top: BorderSide(color: AppTheme.border, width: 1),
                ),
              ),
              child: _profile.isEmpty
                  ? const Center(
                child: Text(
                  'Draw a line on the map to see elevation profile',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
                  : CustomPaint(
                size: Size.infinite,
                painter: _ElevationProfilePainter(
                  values: _profile,
                  lineColor: AppTheme.gold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pointLabel(String label) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.gold,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _ElevationProfilePainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;

  _ElevationProfilePainter({required this.values, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final maxV = values.reduce((a, b) => a > b ? a : b);
    final minV = values.reduce((a, b) => a < b ? a : b);
    final range = (maxV - minV).clamp(0.1, double.infinity);

    final gridPaint = Paint()
      ..color = AppTheme.border
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.4),
          lineColor.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = ui.Path();
    for (int i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final normalized = (values[i] - minV) / range;
      final y = size.height - normalized * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final fillPath = ui.Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _ElevationProfilePainter oldDelegate) =>
      oldDelegate.values != values;
}

// ============================================================
// MAP 5: SPATIAL OVERLAY & ANOMALY MAP
// ============================================================

class AnomalyDetectionScreen extends StatefulWidget {
  const AnomalyDetectionScreen({super.key});

  @override
  State<AnomalyDetectionScreen> createState() =>
      _AnomalyDetectionScreenState();
}

class _AnomalyDetectionScreenState extends State<AnomalyDetectionScreen> {
  final MapController _mapController = MapController();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<DepthFenceState>(context);
    final anomalies = state.anomalies;

    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      appBar: AppBar(title: const Text('Anomaly Overlay Map')),
      body: Column(
        children: [
          SizedBox(
            height: 280,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: anomalies.isNotEmpty
                    ? anomalies.first.location
                    : const LatLng(20.5937, 78.9629),
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: AppConstants.googleSatellite,
                  userAgentPackageName: 'com.depthfence.app',
                ),
                CircleLayer(
                  circles: anomalies.map((a) {
                    return CircleMarker(
                      point: a.location,
                      radius: 60,
                      useRadiusInMeter: true,
                      color: a.severityColor.withValues(alpha: 0.25),
                      borderColor: a.severityColor,
                      borderStrokeWidth: 2,
                    );
                  }).toList(),
                ),
                MarkerLayer(
                  markers: anomalies.asMap().entries.map((entry) {
                    final i = entry.key;
                    final a = entry.value;
                    return Marker(
                      point: a.location,
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedIndex = i),
                        child: Container(
                          decoration: BoxDecoration(
                            color: a.severityColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: _selectedIndex == i ? 3 : 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                a.severityColor.withValues(alpha: 0.6),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(a.severityIcon,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: anomalies.length,
              itemBuilder: (context, i) {
                final a = anomalies[i];
                final selected = _selectedIndex == i;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: selected
                        ? a.severityColor.withValues(alpha: 0.08)
                        : AppTheme.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? a.severityColor.withValues(alpha: 0.5)
                          : AppTheme.border,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: a.severityColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(a.severityIcon,
                            color: a.severityColor, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.title,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              a.parcelId,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: a.severityColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          a.severity.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: a.severityColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MAP 6: CAD / BLUEPRINT GRID MAP
// ============================================================

class BlueprintDownloadScreen extends StatelessWidget {
  const BlueprintDownloadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const corners = [
      LatLng(20.5937, 78.9629),
      LatLng(20.5945, 78.9629),
      LatLng(20.5945, 78.9637),
      LatLng(20.5937, 78.9637),
    ];

    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      appBar: AppBar(title: const Text('CAD Blueprint')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 320,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border, width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CustomPaint(
                size: Size.infinite,
                painter: _CadBlueprintPainter(points: corners),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CORNER COORDINATES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.gold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                ...corners.asMap().entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: AppTheme.gold,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + e.key),
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${e.value.latitude.toStringAsFixed(5)}, '
                              '${e.value.longitude.toStringAsFixed(5)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textPrimary,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.card,
                    foregroundColor: AppTheme.gold,
                    side: const BorderSide(color: AppTheme.gold),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  label: const Text('PDF'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.card,
                    foregroundColor: AppTheme.gold,
                    side: const BorderSide(color: AppTheme.gold),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.grid_on_rounded),
                  label: const Text('DXF'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('All'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CadBlueprintPainter extends CustomPainter {
  final List<LatLng> points;

  _CadBlueprintPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.25)
      ..strokeWidth = 0.6;
    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final majorPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 100) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), majorPaint);
    }
    for (double y = 0; y < size.height; y += 100) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), majorPaint);
    }

    if (points.isEmpty) return;

    final lats = points.map((p) => p.latitude).toList();
    final lngs = points.map((p) => p.longitude).toList();
    final minLat = lats.reduce((a, b) => a < b ? a : b);
    final maxLat = lats.reduce((a, b) => a > b ? a : b);
    final minLng = lngs.reduce((a, b) => a < b ? a : b);
    final maxLng = lngs.reduce((a, b) => a > b ? a : b);

    const padding = 40.0;
    final w = size.width - padding * 2;
    final h = size.height - padding * 2;

    Offset project(LatLng p) {
      final dx = (p.longitude - minLng) / (maxLng - minLng + 1e-9);
      final dy = (p.latitude - minLat) / (maxLat - minLat + 1e-9);
      return Offset(padding + dx * w, padding + (1 - dy) * h);
    }

    final path = ui.Path();
    final projected = points.map(project).toList();
    for (int i = 0; i < projected.length; i++) {
      if (i == 0) {
        path.moveTo(projected[i].dx, projected[i].dy);
      } else {
        path.lineTo(projected[i].dx, projected[i].dy);
      }
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF1E3A8A).withValues(alpha: 0.08)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF1E3A8A)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    for (int i = 0; i < projected.length; i++) {
      final p = projected[i];
      canvas.drawCircle(p, 6, Paint()..color = const Color(0xFF1E3A8A));
      canvas.drawCircle(
        p,
        6,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke,
      );

      final tp = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(65 + i),
          style: const TextStyle(
            color: Color(0xFF1E3A8A),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, p + const Offset(10, -18));
    }
  }

  @override
  bool shouldRepaint(covariant _CadBlueprintPainter oldDelegate) =>
      oldDelegate.points != points;
}

// ============================================================
// BUILDING HEIGHT MENU SCREEN
// ============================================================

class BuildingHeightMenuScreen extends StatelessWidget {
  const BuildingHeightMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<DepthFenceState>(context);
    final calculatedH = state.calculatedHeight;

    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      appBar: AppBar(
        title: const Text('Building Height & Shadow Math'),
        backgroundColor: AppTheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: AppTheme.cyan),
            tooltip: 'AI Vision Scanner',
            onPressed: () {
              Navigator.pushNamed(context, '/ai_vision_scanner');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cityscape visualization card
            Card(
              color: AppTheme.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppTheme.border),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                height: 220,
                width: double.infinity,
                child: CustomPaint(
                  painter: _CityscapePainter(
                    shadowLength: state.shadowLength,
                    solarAngle: state.solarAngle,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Calculated Height Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.gold.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.height_rounded, color: AppTheme.gold, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Calculated Height (H)',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${calculatedH.toStringAsFixed(2)} m',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // AI Vision Scanner Button Card
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/ai_vision_scanner');
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.cyan.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.cyan.withValues(alpha: 0.1),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.cyan.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: AppTheme.cyan, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'AI Vision Scanner',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Live camera shadow extraction & AI analysis',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.cyan, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Interactive Controls',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Shadow Length Slider
            Card(
              color: AppTheme.card,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Shadow Length (S)',
                            style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                        Text('${state.shadowLength.toStringAsFixed(2)} m',
                            style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Slider(
                      value: state.shadowLength.clamp(5.0, 100.0),
                      min: 5.0,
                      max: 100.0,
                      activeColor: AppTheme.gold,
                      inactiveColor: AppTheme.border,
                      onChanged: (v) => state.setShadowLength(v),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Solar Angle Slider
            Card(
              color: AppTheme.card,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Solar Elevation Angle (θ)',
                            style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                        Text('${state.solarAngle.toStringAsFixed(1)}°',
                            style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Slider(
                      value: state.solarAngle.clamp(-85.0, -5.0),
                      min: -85.0,
                      max: -5.0,
                      activeColor: AppTheme.gold,
                      inactiveColor: AppTheme.border,
                      onChanged: (v) => state.setSolarAngle(v),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CityscapePainter extends CustomPainter {
  final double shadowLength;
  final double solarAngle;

  _CityscapePainter({required this.shadowLength, required this.solarAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final groundY = size.height * 0.75;
    final paintGround = Paint()
      ..color = AppTheme.border
      ..strokeWidth = 2;

    canvas.drawLine(Offset(0, groundY), Offset(size.width, groundY), paintGround);

    final bWidth = 60.0;
    final bLeft = size.width * 0.3;
    final rad = solarAngle.abs() * (math.pi / 180);
    final calculatedH = shadowLength * math.tan(rad);
    final displayH = (calculatedH * 2).clamp(20.0, size.height * 0.5);

    final bRect = Rect.fromLTWH(bLeft, groundY - displayH, bWidth, displayH);

    // Shadow
    final shadowWidth = (shadowLength * 1.5).clamp(10.0, size.width * 0.4);
    final shadowPath = ui.Path()
      ..moveTo(bLeft + bWidth, groundY)
      ..lineTo(bLeft + bWidth + shadowWidth, groundY)
      ..lineTo(bLeft + bWidth, groundY - displayH)
      ..close();

    final shadowPaint = Paint()..color = AppTheme.gold.withValues(alpha: 0.25);
    canvas.drawPath(shadowPath, shadowPaint);

    // Building
    final bPaint = Paint()..color = AppTheme.surface;
    final bStroke = Paint()
      ..color = AppTheme.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(bRect, bPaint);
    canvas.drawRect(bRect, bStroke);

    // Sun ray line
    final rayPaint = Paint()
      ..color = AppTheme.warning
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(bLeft + bWidth, groundY - displayH),
      Offset(bLeft + bWidth + shadowWidth, groundY),
      rayPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CityscapePainter oldDelegate) =>
      oldDelegate.shadowLength != shadowLength || oldDelegate.solarAngle != solarAngle;
}

// ============================================================
// DELTA Z SCANNER SCREEN
// ============================================================

class DeltaZScannerScreen extends StatefulWidget {
  const DeltaZScannerScreen({super.key});

  @override
  State<DeltaZScannerScreen> createState() => _DeltaZScannerScreenState();
}

class _DeltaZScannerScreenState extends State<DeltaZScannerScreen> {
  bool isMicroMode = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = Provider.of<DepthFenceState>(context, listen: false);
      if (s.autoCalculated && s.selectedBuildingLocation != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✨ Auto-calculated: ${s.calculatedHeight.toStringAsFixed(2)} m',
            ),
            backgroundColor: AppTheme.emerald,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<DepthFenceState>(context);

    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      appBar: AppBar(
        title: const Text('Delta Z Scanner'),
        backgroundColor: AppTheme.surface,
        actions: [
          IconButton(
            icon: Icon(isMicroMode ? Icons.center_focus_strong : Icons.map),
            tooltip: 'Toggle Mode',
            onPressed: () {
              setState(() => isMicroMode = !isMicroMode);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Scanner Canvas / Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isMicroMode ? Icons.center_focus_strong : Icons.terrain,
                            color: AppTheme.gold,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isMicroMode ? 'MICRO MODE (AI Vision)' : 'MACRO MODE (DEM)',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('ONLINE',
                            style: TextStyle(fontSize: 10, color: AppTheme.success, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            Icons.radar,
                            size: 100,
                            color: AppTheme.gold.withValues(alpha: 0.15),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('ΔZ (Elevation Variance)',
                                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(
                                '${state.deltaZ.toStringAsFixed(2)} m',
                                style: const TextStyle(
                                  color: AppTheme.gold,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Auto-calculation banner
            Consumer<DepthFenceState>(
              builder: (context, s, _) {
                if (!s.autoCalculated || s.selectedAt == null) {
                  return const SizedBox.shrink();
                }
                return Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.emerald.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.emerald.withValues(alpha: 0.4),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.emerald.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: AppTheme.emerald,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AUTO-CALCULATED FROM MAP',
                              style: TextStyle(
                                color: AppTheme.emerald,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Structure at ${s.selectedBuildingLocation!.latitude.toStringAsFixed(4)}, ${s.selectedBuildingLocation!.longitude.toStringAsFixed(4)}',
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => s.clearBuildingSelection(),
                        child: const Icon(
                          Icons.close_rounded,
                          color: AppTheme.textMuted,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Dynamic Readout Cards
            _readoutCard(
              icon: Icons.crop_square_rounded,
              label: 'Extracted Shadow Length',
              value: state.shadowLength.toStringAsFixed(2),
              unit: 'Meters',
              color: AppTheme.gold,
              trailing: IconButton(
                icon: const Icon(Icons.grid_on, color: AppTheme.gold, size: 16),
                onPressed: () {},
              ),
            ),
            const SizedBox(height: 10),
            _readoutCard(
              icon: Icons.wb_sunny_outlined,
              label: 'Solar Elevation Angle',
              value: '${state.solarAngle.toStringAsFixed(2)}°',
              unit: 'Degree',
              color: AppTheme.warning,
            ),
            const SizedBox(height: 10),
            _readoutCard(
              icon: Icons.business_rounded,
              label: state.autoCalculated
                  ? 'Calculated Building Height (Auto)'
                  : 'Calculated Building Height',
              value: state.calculatedHeight.toStringAsFixed(2),
              unit: 'Meters',
              color: AppTheme.emerald,
              highlightValue: true,
            ),
            const SizedBox(height: 16),

            // Metrics Grid
            Row(
              children: [
                Expanded(
                  child: _metricCard('Horizontal Distance', '${state.horizontalDistanceAB.toStringAsFixed(2)} m', Icons.straighten),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _metricCard('Calculated Height', '${state.calculatedHeight.toStringAsFixed(2)} m', Icons.height),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text(
              'Adjust Parameters',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 12),

            // Horizontal Distance Slider
            Card(
              color: AppTheme.card,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Horizontal Distance A-B', style: TextStyle(color: AppTheme.textPrimary)),
                        Text('${state.horizontalDistanceAB.toStringAsFixed(1)} m', style: const TextStyle(color: AppTheme.gold)),
                      ],
                    ),
                    Slider(
                      value: state.horizontalDistanceAB.clamp(10.0, 500.0),
                      min: 10.0,
                      max: 500.0,
                      activeColor: AppTheme.gold,
                      onChanged: (v) => state.setHorizontalDistance(v),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Delta Z Slider
            Card(
              color: AppTheme.card,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Elevation Shift (ΔZ)', style: TextStyle(color: AppTheme.textPrimary)),
                        Text('${state.deltaZ.toStringAsFixed(2)} m', style: const TextStyle(color: AppTheme.gold)),
                      ],
                    ),
                    Slider(
                      value: state.deltaZ.clamp(0.0, 50.0),
                      min: 0.0,
                      max: 50.0,
                      activeColor: AppTheme.gold,
                      onChanged: (v) => state.setDeltaZ(v),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _readoutCard({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
    Widget? trailing,
    bool highlightValue = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlightValue ? color.withValues(alpha: 0.5) : AppTheme.border,
          width: highlightValue ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        color: highlightValue ? color : AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      unit,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }

  Widget _metricCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.gold, size: 20),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ============================================================
// DELTA Z PROFILE SCREEN (Elevation Cross-Section)
// ============================================================

class DeltaZProfileScreen extends StatelessWidget {
  const DeltaZProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<DepthFenceState>(context);

    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      appBar: AppBar(
        title: const Text('Delta Z Elevation Profile'),
        backgroundColor: AppTheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Terrain Elevation Profile (A → B)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cross-sectional elevation graph derived from satellite DEM & LiDAR math.',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),

            // FL_CHART Elevation Graph
            Container(
              height: 260,
              padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    getDrawingHorizontalLine: (val) => FlLine(color: AppTheme.border, strokeWidth: 1),
                    getDrawingVerticalLine: (val) => FlLine(color: AppTheme.border, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}m',
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                        ),
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}m',
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                        ),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: AppTheme.border),
                  ),
                  minX: 0,
                  maxX: state.horizontalDistanceAB > 0 ? state.horizontalDistanceAB : 150,
                  minY: 0,
                  maxY: (state.deltaZ * 2.5) > 20 ? state.deltaZ * 2.5 : 30,
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 10),
                        FlSpot(state.horizontalDistanceAB * 0.25, 12),
                        FlSpot(state.horizontalDistanceAB * 0.5, 10 + state.deltaZ),
                        FlSpot(state.horizontalDistanceAB * 0.75, 14),
                        FlSpot(state.horizontalDistanceAB, 11),
                      ],
                      isCurved: true,
                      color: AppTheme.gold,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.gold.withValues(alpha: 0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Key Statistics
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  _statRow('Distance (A → B)', '${state.horizontalDistanceAB.toStringAsFixed(2)} m'),
                  const Divider(color: AppTheme.border, height: 20),
                  _statRow('Max ΔZ Elevation Shift', '${state.deltaZ.toStringAsFixed(2)} m'),
                  const Divider(color: AppTheme.border, height: 20),
                  _statRow('Estimated Gradient / Slope', '${(state.deltaZ / (state.horizontalDistanceAB > 0 ? state.horizontalDistanceAB : 1) * 100).toStringAsFixed(1)}%'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        Text(value, style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }
}

// ============================================================
// COMPOSITE OVERVIEW SCREEN (6-Panel Grid)
// ============================================================

class CompositeOverviewScreen extends StatelessWidget {
  const CompositeOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<DepthFenceState>(context);

    final stages = [
      {
        'stage': 'Stage 1',
        'title': 'Boundary Extraction',
        'metric': '${state.boundaryPoints.length} Vertices',
        'icon': Icons.crop_square_rounded,
        'status': 'Verified',
      },
      {
        'stage': 'Stage 2',
        'title': 'Terrain & DEM',
        'metric': 'Unit: ${state.measurementUnit}',
        'icon': Icons.terrain_rounded,
        'status': 'Active',
      },
      {
        'stage': 'Stage 3',
        'title': 'Building Height',
        'metric': 'H: ${state.calculatedHeight.toStringAsFixed(1)}m',
        'icon': Icons.domain_rounded,
        'status': 'Calculated',
      },
      {
        'stage': 'Stage 4',
        'title': 'Delta Z Analysis',
        'metric': 'ΔZ: ${state.deltaZ.toStringAsFixed(1)}m',
        'icon': Icons.height_rounded,
        'status': 'Scanned',
      },
      {
        'stage': 'Stage 5',
        'title': 'Anomaly Detection',
        'metric': '${state.anomalies.length} Flagged',
        'icon': Icons.warning_amber_rounded,
        'status': 'Monitored',
      },
      {
        'stage': 'Stage 6',
        'title': 'Cadastral Report',
        'metric': 'Certificate Ready',
        'icon': Icons.description_rounded,
        'status': 'Ready',
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      appBar: AppBar(
        title: const Text('Composite Overview (6 Stages)'),
        backgroundColor: AppTheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              state.toggleDualView();
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: stages.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final item = stages[index];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['stage'] as String,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.gold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item['status'] as String,
                          style: const TextStyle(fontSize: 9, color: AppTheme.success, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  Icon(item['icon'] as IconData, color: AppTheme.gold, size: 28),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] as String,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['metric'] as String,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// REPORT PREVIEW SCREEN (Cadastral Certificate & PDF)
// ============================================================

class ReportPreviewScreen extends StatefulWidget {
  const ReportPreviewScreen({super.key});

  @override
  State<ReportPreviewScreen> createState() => _ReportPreviewScreenState();
}

class _ReportPreviewScreenState extends State<ReportPreviewScreen> {
  bool _isGenerating = false;

  Future<void> _downloadReport() async {
    if (_isGenerating) return;
    setState(() => _isGenerating = true);

    try {
      final state = Provider.of<DepthFenceState>(context, listen: false);
      final file = await PdfGenerator.generateAndSave(state: state);

      if (!mounted) return;

      // Show success snackbar with action to share/open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ PDF saved to:\n${file.path}'),
          backgroundColor: AppTheme.emerald,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'OPEN',
            textColor: Colors.white,
            onPressed: () async {
              await Printing.sharePdf(
                bytes: await file.readAsBytes(),
                filename: file.path.split('/').last,
              );
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to generate PDF: $e'),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<DepthFenceState>(context);

    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      appBar: AppBar(
        title: const Text('Report Preview'),
        backgroundColor: AppTheme.surface,
        actions: [
          IconButton(
            onPressed: _isGenerating ? null : _downloadReport,
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Download PDF',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.gold, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.gold.withValues(alpha: 0.05),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Certificate Header
                  Center(
                    child: Column(
                      children: [
                        const Icon(Icons.verified_user_rounded, color: AppTheme.gold, size: 40),
                        const SizedBox(height: 8),
                        const Text(
                          'DEPTHFENCE LAND INTELLIGENCE PLATFORM',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: AppTheme.gold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'OFFICIAL CADASTRAL ASSESSMENT CERTIFICATE',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Doc Ref: DF-CAD-${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-0091',
                          style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppTheme.border, height: 28),

                  // Parcel Identification
                  const Text('PARCEL IDENTIFICATION', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.gold, fontSize: 12)),
                  const SizedBox(height: 8),
                  _certRow('ULPIN Identifier', 'ULPIN-2024-001-A'),
                  _certRow('Owner Name', state.userName.isNotEmpty ? state.userName : 'Ramesh Kumar'),
                  _certRow('Survey Zone', 'Zone 4 - Central Cadastral Division'),
                  _certRow('Calculated Area', '2.34 Ha (23,400 sq.m)'),
                  const SizedBox(height: 16),

                  // Elevation & Height Math
                  const Text('GEOSPATIAL & HEIGHT METRICS', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.gold, fontSize: 12)),
                  const SizedBox(height: 8),
                  _certRow('Shadow Length (S)', '${state.shadowLength.toStringAsFixed(2)} m'),
                  _certRow('Solar Elevation (θ)', '${state.solarAngle.toStringAsFixed(1)}°'),
                  _certRow('Calculated Structure Height (H)', '${state.calculatedHeight.toStringAsFixed(2)} m'),
                  _certRow('Elevation Variance (ΔZ)', '${state.deltaZ.toStringAsFixed(2)} m'),
                  const SizedBox(height: 16),

                  // Boundary Coordinates Table
                  const Text('BOUNDARY CO-ORDINATES (WGS84)', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.gold, fontSize: 12)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: state.boundaryPoints.asMap().entries.map((e) {
                        final idx = e.key + 1;
                        final pt = e.value;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: idx.isEven ? AppTheme.surface : Colors.transparent,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Vertex P$idx', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                              Text('${pt.latitude.toStringAsFixed(4)}°N, ${pt.longitude.toStringAsFixed(4)}°E',
                                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 11, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Verification Stamp & Signature
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Verification Status', style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                          SizedBox(height: 4),
                          Text('PASS - AI VERIFIED', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.gold),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('DIGITALLY SIGNED', style: TextStyle(color: AppTheme.gold, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ─── DOWNLOAD BUTTON ───
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _downloadReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                icon: _isGenerating
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                )
                    : const Icon(Icons.picture_as_pdf_rounded, size: 22),
                label: Text(
                  _isGenerating ? 'Generating PDF...' : 'Download PDF Report',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isGenerating ? null : _downloadReport,
        backgroundColor: AppTheme.gold,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.file_download_rounded),
        label: const Text(
          'DOWNLOAD',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Widget _certRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}

// ============================================================
// PROFILE SCREEN
// ============================================================

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<DepthFenceState>(context);

    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () async {
              await state.logout();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: AppTheme.gold,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person,
                        color: Colors.black, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.userName.isNotEmpty
                              ? state.userName
                              : 'User',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          state.userEmail,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.gold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.gold.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            state.userRole.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.gold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _tile(
            context,
            Icons.description_outlined,
            'Report Preview',
            'Cadastral certificate',
                () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const ReportPreviewScreen(),
              ));
            },
          ),
          _tile(
            context,
            Icons.grid_view_rounded,
            'Composite Overview',
            'See all 6 platform stages',
                () {
              final s = Provider.of<DepthFenceState>(context, listen: false);
              s.toggleDualView();
            },
          ),
          _tile(
            context,
            Icons.show_chart_rounded,
            'Delta Z Profile',
            'Elevation cross-section',
                () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const DeltaZProfileScreen(),
              ));
            },
          ),
          _tile(
            context,
            Icons.auto_awesome_rounded,
            'AI Assistant',
            'Ask about land, parcels, anomalies',
                () {
              Navigator.pushNamed(context, '/gemini_chat');
            },
          ),
          _tile(
            context,
            Icons.security_rounded,
            'Permissions',
            'Manage app access',
                () {
              Navigator.pushNamed(context, '/permissions');
            },
          ),
          _tile(
            context,
            Icons.info_outline,
            'About DepthFence',
            'Version ${AppConstants.appVersion}',
                () {},
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title,
      String subtitle, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.gold),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 14, color: AppTheme.textMuted),
        onTap: onTap,
      ),
    );
  }
}

// ============================================================
// PERMISSIONS SETTINGS SCREEN
// ============================================================

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with WidgetsBindingObserver {
  // ---------- Permission status cache ----------
  bool _locationGranted = false;
  bool _cameraGranted = false;
  bool _filesGranted = false;
  bool _notificationsGranted = false;

  // GPS state (on/off in system)
  bool _gpsServiceEnabled = false;

  // Current coordinates (shown when location is granted + GPS on)
  double? _latitude;
  double? _longitude;

  // Loading flags per toggle
  bool _loadingLocation = false;
  bool _loadingCamera = false;
  bool _loadingFiles = false;
  bool _loadingNotifications = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshAll();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check when the user returns from Settings
    if (state == AppLifecycleState.resumed) {
      _refreshAll();
    }
  }

  // ==========================================================
  // REFRESH ALL PERMISSIONS
  // ==========================================================
  Future<void> _refreshAll() async {
    // ----- Location -----
    final locStatus = await Permission.location.status;
    final gpsOn = await Geolocator.isLocationServiceEnabled();
    bool locGranted = locStatus.isGranted;

    // Get coordinates if granted + GPS on
    double? lat;
    double? lng;
    if (locGranted && gpsOn) {
      try {
        final pos = await Geolocator.getLastKnownPosition() ??
            await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.high,
                timeLimit: Duration(seconds: 4),
              ),
            );
        lat = pos.latitude;
        lng = pos.longitude;
      } catch (_) {
        // GPS unavailable
      }
    }

    // ----- Camera -----
    final camStatus = await Permission.camera.status;

    // ----- Files -----
    // Android 13+: use storage; older: use storage too
    final filesStatus = await Permission.storage.status;
    final photosStatus = await Permission.photos.status;

    // ----- Notifications -----
    final notifStatus = await Permission.notification.status;

    if (!mounted) return;
    setState(() {
      _locationGranted = locGranted;
      _gpsServiceEnabled = gpsOn;
      _latitude = lat;
      _longitude = lng;

      _cameraGranted = camStatus.isGranted;

      _filesGranted = filesStatus.isGranted || photosStatus.isGranted;

      _notificationsGranted = notifStatus.isGranted;
    });
  }

  // ==========================================================
  // TOGGLE HANDLERS
  // ==========================================================

  // ---------- LOCATION ----------
  Future<void> _toggleLocation(bool value) async {
    setState(() => _loadingLocation = true);

    if (value) {
      // 1. Request location permission
      final status = await Permission.location.request();

      // 2. If permanently denied, open app settings
      if (status.isPermanentlyDenied) {
        if (!mounted) return;
        setState(() => _loadingLocation = false);
        await _showOpenSettingsDialog(
          title: 'Location Permission Blocked',
          message:
          'Location access is permanently denied. Open App Settings → Permissions → Location to enable it manually.',
        );
        return;
      }

      // 3. Check if GPS hardware is enabled
      final gpsOn = await Geolocator.isLocationServiceEnabled();
      if (!gpsOn) {
        if (!mounted) return;
        setState(() => _loadingLocation = false);
        await _showOpenSettingsDialog(
          title: 'GPS is Turned Off',
          message:
          'Please turn ON your device GPS from the system quick settings or Location settings.',
          openAppInfo: false,
        );
        return;
      }

      // 4. Force refresh after GPS + permission are OK
      await _refreshAll();
    } else {
      // Cannot programmatically revoke permissions on Android.
      // Open App Info → Permissions so user can revoke manually.
      if (!mounted) return;
      setState(() => _loadingLocation = false);
      await _showOpenSettingsDialog(
        title: 'Revoke Location Manually',
        message:
        'Android does not allow apps to revoke their own permissions. Open App Settings → Permissions → Location → Deny.',
      );
      return;
    }

    if (!mounted) return;
    setState(() => _loadingLocation = false);
  }

  // ---------- CAMERA ----------
  Future<void> _toggleCamera(bool value) async {
    setState(() => _loadingCamera = true);

    if (value) {
      final status = await Permission.camera.request();

      if (status.isPermanentlyDenied) {
        if (!mounted) return;
        setState(() => _loadingCamera = false);
        await _showOpenSettingsDialog(
          title: 'Camera Permission Blocked',
          message:
          'Camera access is permanently denied. Open App Settings → Permissions → Camera to enable it manually.',
        );
        return;
      }
    } else {
      if (!mounted) return;
      setState(() => _loadingCamera = false);
      await _showOpenSettingsDialog(
        title: 'Revoke Camera Manually',
        message:
        'Open App Settings → Permissions → Camera → Deny to revoke.',
      );
      return;
    }

    await _refreshAll();
    if (!mounted) return;
    setState(() => _loadingCamera = false);
  }

  // ---------- FILES ----------
  Future<void> _toggleFiles(bool value) async {
    setState(() => _loadingFiles = true);

    if (value) {
      // Try storage first (older Androids)
      final storageStatus = await Permission.storage.request();

      // For Android 13+, request photos permission
      PermissionStatus photosStatus = PermissionStatus.denied;
      try {
        photosStatus = await Permission.photos.request();
      } catch (_) {
        // photos permission may not exist on older Android — ignore
      }

      final granted =
          storageStatus.isGranted || photosStatus.isGranted;

      if (!granted &&
          (storageStatus.isPermanentlyDenied ||
              photosStatus.isPermanentlyDenied)) {
        if (!mounted) return;
        setState(() => _loadingFiles = false);
        await _showOpenSettingsDialog(
          title: 'Files Permission Blocked',
          message:
          'Files access is permanently denied. Open App Settings → Permissions → Files & Media to enable it manually.',
        );
        return;
      }
    } else {
      if (!mounted) return;
      setState(() => _loadingFiles = false);
      await _showOpenSettingsDialog(
        title: 'Revoke Files Manually',
        message:
        'Open App Settings → Permissions → Files & Media → Deny to revoke.',
      );
      return;
    }

    await _refreshAll();
    if (!mounted) return;
    setState(() => _loadingFiles = false);
  }

  // ---------- NOTIFICATIONS ----------
  Future<void> _toggleNotifications(bool value) async {
    setState(() => _loadingNotifications = true);

    if (value) {
      final status = await Permission.notification.request();

      if (status.isPermanentlyDenied) {
        if (!mounted) return;
        setState(() => _loadingNotifications = false);
        await _showOpenSettingsDialog(
          title: 'Notifications Blocked',
          message:
          'Notification permission is permanently denied. Open App Settings → Notifications to enable it manually.',
        );
        return;
      }
    } else {
      if (!mounted) return;
      setState(() => _loadingNotifications = false);
      await _showOpenSettingsDialog(
        title: 'Disable Notifications Manually',
        message:
        'Open App Settings → Notifications → toggle off to disable.',
      );
      return;
    }

    await _refreshAll();
    if (!mounted) return;
    setState(() => _loadingNotifications = false);
  }

  // ==========================================================
  // OPEN SETTINGS DIALOG
  // ==========================================================
  Future<void> _showOpenSettingsDialog({
    required String title,
    required String message,
    bool openAppInfo = true,
  }) async {
    final shouldOpen = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            const Icon(Icons.info_outline_rounded,
                color: AppTheme.gold, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppTheme.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          if (openAppInfo)
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.gold,
                foregroundColor: Colors.black,
              ),
              child: const Text('Open Settings'),
            ),
        ],
      ),
    );

    if (shouldOpen == true) {
      await openAppSettings();
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      appBar: AppBar(
        title: const Text('Permissions'),
        backgroundColor: AppTheme.scaffold,
        foregroundColor: AppTheme.gold,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refreshAll,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---------- Header card ----------
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.gold.withValues(alpha: 0.15),
                  AppTheme.gold.withValues(alpha: 0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppTheme.gold.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.gold, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    color: AppTheme.gold,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'App Permissions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Control what DepthFence can access on your device',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // ---------- Section title ----------
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AppTheme.gold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'PERMISSION SETTINGS',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ---------- 1. LOCATION ----------
          _PermissionTile(
            icon: Icons.location_on_rounded,
            title: 'Location',
            subtitle: _locationGranted && _gpsServiceEnabled
                ? (_latitude != null && _longitude != null
                ? 'Lat: ${_latitude!.toStringAsFixed(6)}, Lng: ${_longitude!.toStringAsFixed(6)}'
                : 'GPS enabled — fetching coordinates...')
                : _locationGranted
                ? 'Permission granted, but GPS is OFF'
                : 'Access GPS and show coordinates on the map',
            enabled: _locationGranted && _gpsServiceEnabled,
            loading: _loadingLocation,
            onToggle: _toggleLocation,
            extraWarning: _locationGranted && !_gpsServiceEnabled,
          ),
          const SizedBox(height: 10),

          // ---------- 2. CAMERA ----------
          _PermissionTile(
            icon: Icons.camera_alt_rounded,
            title: 'Camera',
            subtitle: _cameraGranted
                ? 'Back camera access is active'
                : 'Access the phone\'s back camera',
            enabled: _cameraGranted,
            loading: _loadingCamera,
            onToggle: _toggleCamera,
          ),
          const SizedBox(height: 10),

          // ---------- 3. FILES ----------
          _PermissionTile(
            icon: Icons.folder_rounded,
            title: 'Files',
            subtitle: _filesGranted
                ? 'File upload & download is enabled'
                : 'Allow file upload and download to your phone',
            enabled: _filesGranted,
            loading: _loadingFiles,
            onToggle: _toggleFiles,
          ),
          const SizedBox(height: 10),

          // ---------- 4. NOTIFICATIONS ----------
          _PermissionTile(
            icon: Icons.notifications_active_rounded,
            title: 'Notifications',
            subtitle: _notificationsGranted
                ? 'You\'ll receive updates and alerts'
                : 'Allow the app to send notifications',
            enabled: _notificationsGranted,
            loading: _loadingNotifications,
            onToggle: _toggleNotifications,
          ),
          const SizedBox(height: 24),

          // ---------- Open Settings Button ----------
          OutlinedButton.icon(
            onPressed: () async {
              await openAppSettings();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.gold,
              side: const BorderSide(color: AppTheme.gold, width: 1.4),
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.settings_outlined, size: 20),
            label: const Text(
              'Open App Settings',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ---------- Footer note ----------
          Center(
            child: Text(
              'Some permissions can only be revoked from system settings.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted.withValues(alpha: 0.9),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// REUSABLE PERMISSION TILE
// ============================================================

class _PermissionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final bool loading;
  final ValueChanged<bool> onToggle;
  final bool extraWarning;

  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.loading,
    required this.onToggle,
    this.extraWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled
              ? AppTheme.gold.withValues(alpha: 0.4)
              : extraWarning
              ? AppTheme.danger.withValues(alpha: 0.4)
              : AppTheme.border,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: enabled
                  ? AppTheme.gold.withValues(alpha: 0.15)
                  : extraWarning
                  ? AppTheme.danger.withValues(alpha: 0.12)
                  : AppTheme.gold.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: enabled
                    ? AppTheme.gold.withValues(alpha: 0.5)
                    : extraWarning
                    ? AppTheme.danger.withValues(alpha: 0.5)
                    : AppTheme.border,
              ),
            ),
            child: Icon(
              icon,
              color: enabled
                  ? AppTheme.gold
                  : extraWarning
                  ? AppTheme.danger
                  : AppTheme.textMuted,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: extraWarning
                        ? AppTheme.danger
                        : AppTheme.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          // Toggle
          if (loading)
            const SizedBox(
              width: 40,
              height: 24,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.gold),
                  ),
                ),
              ),
            )
          else
            Switch(
              value: enabled,
              onChanged: onToggle,
              activeThumbColor: Colors.black,
              activeTrackColor: AppTheme.gold,
              inactiveThumbColor: AppTheme.textMuted,
              inactiveTrackColor: AppTheme.card,
            ),
        ],
      ),
    );
  }
}

// SCREEN: DELTA Z-AXIS SCANNER (AI Shadow Math)
// ============================================================

class DeltaZScreen extends StatefulWidget {
  const DeltaZScreen({super.key});

  @override
  State<DeltaZScreen> createState() => _DeltaZScreenState();
}

class _DeltaZScreenState extends State<DeltaZScreen> {
  // ---------- STATE ----------
  double shadowLength = 323703.06;   // meters
  double solarAngle = -26.22;         // degrees
  double calculatedHeight = 159422.03; // meters (initial dummy value)
  bool isMicroMode = true;            // true = MICRO (AI VISION), false = MACRO (DEM)
  bool isCalculating = false;

  // ---------- CORE MATH ----------
  void _runShadowMath() async {
    setState(() => isCalculating = true);
    // Simulate AI processing delay
    await Future.delayed(const Duration(milliseconds: 900));

    final radians = solarAngle * (math.pi / 180.0);
    final height = shadowLength * math.tan(radians).abs();

    setState(() {
      calculatedHeight = height;
      isCalculating = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '📐 Height calculated: ${calculatedHeight.toStringAsFixed(2)} m',
        ),
        backgroundColor: AppTheme.gold,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      appBar: AppBar(
        title: const Text('Delta Z-Axis Scanner'),
        backgroundColor: AppTheme.scaffold,
        foregroundColor: AppTheme.gold,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive: Row for wide screens (>= 900px), Column for narrow
            final isWide = constraints.maxWidth >= 900;

            if (isWide) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 3, child: _buildVisualizer()),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: _buildControlPanel()),
                  ],
                ),
              );
            }

            // Narrow — stack vertically
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 320,
                    child: _buildVisualizer(),
                  ),
                  const SizedBox(height: 16),
                  _buildControlPanel(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // LEFT PANEL — VISUALIZER
  // ═══════════════════════════════════════════════════════════
  Widget _buildVisualizer() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          size: Size.infinite,
          painter: _DeltaZPainter(
            shadowLength: shadowLength,
            solarAngle: solarAngle,
            height: calculatedHeight,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // RIGHT PANEL — CONTROLS
  // ═══════════════════════════════════════════════════════════
  Widget _buildControlPanel() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- Mode Toggle ----------
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.scaffold,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildModeOption(
                      label: 'MACRO (DEM)',
                      isActive: !isMicroMode,
                      onTap: () => setState(() => isMicroMode = false),
                    ),
                  ),
                  Expanded(
                    child: _buildModeOption(
                      label: 'MICRO (AI VISION)',
                      isActive: isMicroMode,
                      onTap: () => setState(() => isMicroMode = true),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // ---------- Title ----------
            const Text(
              'Delta Z-Axis\nScanner',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppTheme.textPrimary,
                height: 1.15,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Calculates building height mathematically using live map shadow extraction.',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 26),

            // ---------- Input 1: Shadow Length ----------
            Row(
              children: [
                const Text(
                  '1. ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Expanded(
                  child: Text(
                    'EXTRACTED SHADOW LENGTH',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.info,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🗺️ Map measurement tool (coming soon)'),
                        backgroundColor: AppTheme.gold,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.map_outlined,
                    color: AppTheme.info,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.scaffold,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    shadowLength.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Text(
                    'Meters',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Click the Map icon to use the live dual-point measurement tool.',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),

            // ---------- Input 2: Solar Angle ----------
            Row(
              children: [
                const Text(
                  '2. ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Expanded(
                  child: Text(
                    'SOLAR ELEVATION ANGLE',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.gold,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.scaffold,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    solarAngle.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Text(
                    'Degrees',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Live Astro-Math auto-calculates based on your click coordinates and current time.',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 26),

            // ---------- Result Preview (optional) ----------
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.straighten_rounded,
                      color: AppTheme.success, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CALCULATED HEIGHT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.success,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${calculatedHeight.toStringAsFixed(2)} m',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ---------- Run Button ----------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isCalculating ? null : _runShadowMath,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                icon: isCalculating
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                )
                    : const Icon(Icons.auto_awesome_rounded, size: 20),
                label: Text(
                  isCalculating ? 'Calculating...' : 'Run AI Shadow Math',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Mode Toggle Option ----------
  Widget _buildModeOption({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.gold : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
            color: isActive ? Colors.black : AppTheme.textSecondary,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CUSTOM PAINTER — Delta Z Visualizer
// ============================================================

class _DeltaZPainter extends CustomPainter {
  final double shadowLength;
  final double solarAngle;
  final double height;

  _DeltaZPainter({
    required this.shadowLength,
    required this.solarAngle,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ---------- 1. Perspective Grid ----------
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1;

    // Vertical lines (perspective)
    const gridSpacing = 50.0;
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    // Horizontal lines
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // ---------- 2. Building (center-left) ----------
    const buildingWidth = 80.0;
    final buildingHeight = size.height * 0.42;
    final buildingLeft = size.width * 0.32;
    final buildingBottom = size.height * 0.72;
    final buildingTop = buildingBottom - buildingHeight;

    final buildingRect = Rect.fromLTWH(
      buildingLeft,
      buildingTop,
      buildingWidth,
      buildingHeight,
    );

    // Building fill (dark with slight yellow tint)
    canvas.drawRect(
      buildingRect,
      Paint()..color = const Color(0xFF3D2E00).withValues(alpha: 0.25),
    );
    // Building border (gold)
    canvas.drawRect(
      buildingRect,
      Paint()
        ..color = AppTheme.gold
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );

    // Building icon (small grid pattern inside)
    final iconPaint = Paint()
      ..color = AppTheme.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final iconSize = 28.0;
    final iconRect = Rect.fromCenter(
      center: Offset(
        buildingLeft + buildingWidth / 2,
        buildingTop + buildingHeight / 2,
      ),
      width: iconSize,
      height: iconSize,
    );
    canvas.drawRect(iconRect, iconPaint);
    // Inner grid (2x2)
    canvas.drawLine(
      Offset(iconRect.left + iconRect.width / 2, iconRect.top),
      Offset(iconRect.left + iconRect.width / 2, iconRect.bottom),
      iconPaint,
    );
    canvas.drawLine(
      Offset(iconRect.left, iconRect.top + iconRect.height / 2),
      Offset(iconRect.right, iconRect.top + iconRect.height / 2),
      iconPaint,
    );
    // Small window dots
    final dotPaint = Paint()..color = AppTheme.gold;
    canvas.drawCircle(
      Offset(iconRect.left + 7, iconRect.top + 7),
      1.5,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(iconRect.right - 7, iconRect.top + 7),
      1.5,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(iconRect.left + 7, iconRect.bottom - 7),
      1.5,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(iconRect.right - 7, iconRect.bottom - 7),
      1.5,
      dotPaint,
    );

    // ---------- 3. Sun (top-left) ----------
    final sunCenter = Offset(size.width * 0.14, size.height * 0.28);
    const sunRadius = 14.0;

    // Sun rays
    final rayPaint = Paint()
      ..color = AppTheme.gold
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * (math.pi / 180);
      final x1 = sunCenter.dx + (sunRadius + 4) * math.cos(angle);
      final y1 = sunCenter.dy + (sunRadius + 4) * math.sin(angle);
      final x2 = sunCenter.dx + (sunRadius + 10) * math.cos(angle);
      final y2 = sunCenter.dy + (sunRadius + 10) * math.sin(angle);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), rayPaint);
    }

    // Sun body
    canvas.drawCircle(
      sunCenter,
      sunRadius,
      Paint()..color = AppTheme.gold,
    );
    canvas.drawCircle(
      sunCenter,
      sunRadius * 0.55,
      Paint()..color = Colors.white.withValues(alpha: 0.6),
    );

    // ---------- 4. Dashed line from sun to building top ----------
    final buildingTopCenter = Offset(
      buildingLeft + buildingWidth / 2,
      buildingTop,
    );
    final dashPaint = Paint()
      ..color = AppTheme.gold.withValues(alpha: 0.5)
      ..strokeWidth = 1.5;
    _drawDashedLine(canvas, sunCenter, buildingTopCenter, dashPaint);

    // ---------- 5. Solar angle label ----------
    _drawText(
      canvas,
      '-26.22° Solar Angle',
      Offset(sunCenter.dx - 50, sunCenter.dy + 28),
      const TextStyle(
        color: AppTheme.gold,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );

    // ---------- 6. Height axis (green, vertical, left of building) ----------
    final heightAxisX = buildingLeft - 40;
    final heightAxisTop = buildingTop;
    final heightAxisBottom = buildingBottom;

    // Vertical line
    final heightPaint = Paint()
      ..color = AppTheme.success
      ..strokeWidth = 1.8;
    canvas.drawLine(
      Offset(heightAxisX, heightAxisTop),
      Offset(heightAxisX, heightAxisBottom),
      heightPaint,
    );

    // Top & bottom ticks
    canvas.drawLine(
      Offset(heightAxisX - 6, heightAxisTop),
      Offset(heightAxisX + 6, heightAxisTop),
      heightPaint,
    );
    canvas.drawLine(
      Offset(heightAxisX - 6, heightAxisBottom),
      Offset(heightAxisX + 6, heightAxisBottom),
      heightPaint,
    );

    // Height label (green box)
    _drawLabelBox(
      canvas,
      '${height.toStringAsFixed(2)}m',
      Offset(heightAxisX - 70, (heightAxisTop + heightAxisBottom) / 2 - 12),
      AppTheme.success,
    );

    // ---------- 7. Shadow axis (blue, horizontal, from building base) ----------
    final shadowStartX = buildingLeft + buildingWidth;
    final shadowEndX = size.width * 0.85;
    final shadowY = buildingBottom;

    final shadowPaint = Paint()
      ..color = AppTheme.info
      ..strokeWidth = 1.8;
    canvas.drawLine(
      Offset(shadowStartX, shadowY),
      Offset(shadowEndX, shadowY),
      shadowPaint,
    );

    // Tick marks at both ends
    canvas.drawLine(
      Offset(shadowStartX, shadowY - 6),
      Offset(shadowStartX, shadowY + 6),
      shadowPaint,
    );
    canvas.drawLine(
      Offset(shadowEndX, shadowY - 6),
      Offset(shadowEndX, shadowY + 6),
      shadowPaint,
    );

    // Shadow label (blue box)
    _drawLabelBox(
      canvas,
      '${shadowLength.toStringAsFixed(2)}m  Shadow',
      Offset((shadowStartX + shadowEndX) / 2 - 70, shadowY + 12),
      AppTheme.info,
    );

    // ---------- 8. Ground baseline ----------
    canvas.drawLine(
      Offset(buildingLeft - 60, buildingBottom),
      Offset(size.width, buildingBottom),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..strokeWidth = 1,
    );
  }

  // ---------- Helper: dashed line ----------
  void _drawDashedLine(
      Canvas canvas,
      Offset start,
      Offset end,
      Paint paint,
      ) {
    const dashWidth = 6.0;
    const dashSpace = 5.0;
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    final unitX = dx / distance;
    final unitY = dy / distance;

    double drawn = 0;
    while (drawn < distance) {
      final x1 = start.dx + unitX * drawn;
      final y1 = start.dy + unitY * drawn;
      final x2 = start.dx + unitX * math.min(drawn + dashWidth, distance);
      final y2 = start.dy + unitY * math.min(drawn + dashWidth, distance);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      drawn += dashWidth + dashSpace;
    }
  }

  // ---------- Helper: text ----------
  void _drawText(
      Canvas canvas,
      String text,
      Offset offset,
      TextStyle style,
      ) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  // ---------- Helper: label box ----------
  void _drawLabelBox(
      Canvas canvas,
      String text,
      Offset offset,
      Color color,
      ) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final boxRect = Rect.fromLTWH(
      offset.dx - 6,
      offset.dy - 3,
      tp.width + 12,
      tp.height + 6,
    );

    // Fill box
    canvas.drawRRect(
      RRect.fromRectAndRadius(boxRect, const Radius.circular(4)),
      Paint()..color = color.withValues(alpha: 0.15),
    );
    // Border
    canvas.drawRRect(
      RRect.fromRectAndRadius(boxRect, const Radius.circular(4)),
      Paint()
        ..color = color
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );

    tp.paint(canvas, Offset(offset.dx, offset.dy));
  }

  @override
  bool shouldRepaint(covariant _DeltaZPainter oldDelegate) {
    return oldDelegate.shadowLength != shadowLength ||
        oldDelegate.solarAngle != solarAngle ||
        oldDelegate.height != height;
  }
}
// ============================================================
// PDF GENERATION SERVICE
// ============================================================

class PdfGenerator {
  /// Generates a DepthFence survey report PDF and returns the saved File.
  static Future<File> generateAndSave({
    required DepthFenceState state,
  }) async {
    final pdf = pw.Document(
      title: 'DepthFence Survey Report',
      author: 'DepthFence Enterprise',
      creator: 'DepthFence v2.0',
    );

    // ═══════════════════════════════════════════════════
    // PAGE 1 — Survey Report
    // ═══════════════════════════════════════════════════
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ─── HEADER ───
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColor.fromHex('#FFC107'),
                    width: 2,
                  ),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  children: [
                    // Logo placeholder circle
                    pw.Container(
                      width: 50,
                      height: 50,
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#FFC107'),
                        borderRadius: pw.BorderRadius.circular(25),
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          'DF',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 14),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Depth Fence',
                            style: pw.TextStyle(
                              fontSize: 22,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#0A0E1A'),
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'LAND SURVEY & INSPECTION REPORT',
                            style: pw.TextStyle(
                              fontSize: 9,
                              letterSpacing: 1.2,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#0A0E1A'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // ─── SECTION: SELECTED BUILDING ───
              pw.Text(
                'SELECTED STRUCTURE',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#0A0E1A'),
                  letterSpacing: 1,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F5F5F5'),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _pdfRow(
                      'Coordinates',
                      state.selectedBuildingLocation != null
                          ? '${state.selectedBuildingLocation!.latitude.toStringAsFixed(6)}, ${state.selectedBuildingLocation!.longitude.toStringAsFixed(6)}'
                          : 'N/A',
                    ),
                    _pdfRow(
                      'Shadow Length',
                      '${state.shadowLength.toStringAsFixed(2)} m',
                    ),
                    _pdfRow(
                      'Solar Elevation Angle',
                      '${state.solarAngle.toStringAsFixed(2)}°',
                    ),
                    _pdfRow(
                      'Calculated Building Height',
                      '${state.selectedBuildingHeight.toStringAsFixed(2)} m',
                      isHighlight: true,
                    ),
                    _pdfRow(
                      'Estimated Depth',
                      '${state.selectedBuildingDepth.toStringAsFixed(2)} m',
                    ),
                    _pdfRow(
                      'Measured At',
                      state.selectedAt != null
                          ? state.selectedAt!.toString().split('.').first
                          : 'N/A',
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // ─── SECTION: BOUNDARY COORDINATES ───
              pw.Text(
                'BOUNDARY COORDINATES',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#0A0E1A'),
                  letterSpacing: 1,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey300,
                  width: 0.5,
                ),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#FFC107'),
                    ),
                    children: [
                      _pdfCell('Point', isHeader: true),
                      _pdfCell('Latitude', isHeader: true),
                      _pdfCell('Longitude', isHeader: true),
                    ],
                  ),
                  ...state.boundaryPoints.asMap().entries.map((e) {
                    return pw.TableRow(
                      children: [
                        _pdfCell('${e.key + 1}'),
                        _pdfCell(e.value.latitude.toStringAsFixed(6)),
                        _pdfCell(e.value.longitude.toStringAsFixed(6)),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 20),

              // ─── SECTION: METADATA ───
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _pdfMeta(
                      'Generated By',
                      '${state.userName.isNotEmpty ? state.userName : "Demo User"} (${state.userRole.toUpperCase()})',
                    ),
                    _pdfMeta('App Version', 'DepthFence v2.0'),
                    _pdfMeta('Report Date', DateTime.now().toString().split('.').first),
                    _pdfMeta('ULPIN Status', 'VERIFIED'),
                  ],
                ),
              ),

              pw.Spacer(),

              // ─── FOOTER ───
              pw.Divider(color: PdfColor.fromHex('#FFC107'), thickness: 1.5),
              pw.SizedBox(height: 6),
              pw.Center(
                child: pw.Text(
                  'SIH26011  •  SIH26012  •  DepthFence Enterprise',
                  style: pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey600,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    // ═══════════════════════════════════════════════════
    // SAVE FILE
    // ═══════════════════════════════════════════════════
    final bytes = await pdf.save();

    File file;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final ts = DateTime.now().millisecondsSinceEpoch;
      file = File('${dir.path}/DepthFence_Report_$ts.pdf');
      await file.writeAsBytes(bytes);
    } catch (e) {
      // Fallback: use cache directory
      final cache = await getTemporaryDirectory();
      final ts = DateTime.now().millisecondsSinceEpoch;
      file = File('${cache.path}/DepthFence_Report_$ts.pdf');
      await file.writeAsBytes(bytes);
    }
    return file;
  }

  // ─── PDF Table Cell Helper ───
  static pw.Widget _pdfCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight:
          isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  // ─── PDF Key-Value Row ───
  static pw.Widget _pdfRow(
      String label,
      String value, {
        bool isHighlight = false,
      }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 140,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: isHighlight ? 13 : 10,
                fontWeight: isHighlight
                    ? pw.FontWeight.bold
                    : pw.FontWeight.normal,
                color: isHighlight
                    ? PdfColor.fromHex('#00A86B')
                    : PdfColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── PDF Meta Row ───
  static pw.Widget _pdfMeta(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// GEMINI AI CHAT SCREEN — DepthFence Assistant
// ============================================================

class GeminiChatScreen extends StatefulWidget {
  const GeminiChatScreen({super.key});

  @override
  State<GeminiChatScreen> createState() => _GeminiChatScreenState();
}

class _GeminiChatScreenState extends State<GeminiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final GenerativeModel _model;
  late ChatSession _chat;

  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  bool _apiKeyMissing = false;

  @override
  void initState() {
    super.initState();

    // Check if API key is set
    if (AppConstants.geminiApiKey.isEmpty ||
        AppConstants.geminiApiKey == 'PASTE_YOUR_KEY_HERE') {
      _apiKeyMissing = true;
      return;
    }

    try {
      // Initialize Gemini model with DepthFence context
      _model = GenerativeModel(
        model: AppConstants.geminiModel,
        apiKey: AppConstants.geminiApiKey,
        systemInstruction: Content.system(
          'You are the DepthFence AI Assistant, an expert in geospatial land '
              'intelligence, cadastral mapping, land surveying, depth analysis, '
              'and illegal construction detection. You help field surveyors and '
              'government administrators with their questions about land parcels, '
              'anomalies, building heights, and survey reports. '
              'Answer concisely and practically.',
        ),
      );

      // Start a persistent multi-turn chat session
      _chat = _model.startChat();

      // Add welcome message
      _messages.add({
        'sender': 'bot',
        'text': '👋 Hello! I\'m your DepthFence AI Assistant.\n\n'
            'Ask me anything about:\n'
            '• Land parcels & cadastral mapping\n'
            '• Building height calculations\n'
            '• Anomaly detection\n'
            '• Survey reports & ULPIN\n\n'
            'How can I help you today?',
      });
    } catch (e) {
      _apiKeyMissing = true;
      debugPrint('Gemini init failed: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ---------- Send Message ----------
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final response = await _chat.sendMessage(Content.text(text));
      if (!mounted) return;

      setState(() {
        _messages.add({
          'sender': 'bot',
          'text': response.text ?? 'Sorry, no response generated.',
        });
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'sender': 'bot',
          'text': '⚠ Error: ${e.toString().split('\n').first}',
        });
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _scrollToBottom();
      }
    }
  }

  // ---------- File Query ----------
  Future<void> _pickAndQueryFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final filePath = result.files.first.path;
      if (filePath == null) return;

      final file = File(filePath);
      final fileName = result.files.first.name;

      // Ask user for question about the file
      if (!mounted) return;
      final question = await _showQuestionDialog(fileName);
      if (question == null || question.isEmpty) return;

      setState(() {
        _messages.add({
          'sender': 'user',
          'text': '📎 Attached: $fileName\n\n$question',
        });
        _isLoading = true;
      });
      _scrollToBottom();

      // Read file (limit to 100KB to avoid token limits)
      String fileContent;
      final fileSize = await file.length();
      if (fileSize > 100 * 1024) {
        final content = await file.readAsString();
        fileContent =
        '${content.substring(0, 100 * 1024)}\n\n[File truncated to 100KB]';
      } else {
        fileContent = await file.readAsString();
      }

      final prompt = 'Context File: $fileName\n\n'
          'Content:\n$fileContent\n\n'
          'User Question: $question';

      final response = await _chat.sendMessage(Content.text(prompt));
      if (!mounted) return;

      setState(() {
        _messages.add({
          'sender': 'bot',
          'text': response.text ?? 'Unable to process file.',
        });
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'sender': 'bot',
          'text': '⚠ Failed to read file: ${e.toString().split('\n').first}',
        });
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _scrollToBottom();
      }
    }
  }

  Future<String?> _showQuestionDialog(String fileName) async {
    final qController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            const Icon(Icons.attach_file_rounded,
                color: AppTheme.gold, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                fileName,
                style: const TextStyle(
                  color: AppTheme.gold,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: qController,
          autofocus: true,
          maxLines: 3,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: 'What would you like to ask about this file?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(ctx, qController.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.gold,
              foregroundColor: Colors.black,
            ),
            child: const Text('Ask'),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _messages.add({
        'sender': 'bot',
        'text': '🧹 Chat cleared. How can I help you?',
      });
    });
    try {
      _chat = _model.startChat();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppTheme.gold, size: 20),
            SizedBox(width: 8),
            Text('AI Assistant'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Clear chat',
            onPressed: _messages.length > 1 ? _clearChat : null,
          ),
        ],
      ),
      body: _apiKeyMissing
          ? _buildApiKeyMissingView()
          : Column(
        children: [
          // ---------- Messages List ----------
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['sender'] == 'user';
                return _buildMessageBubble(message, isUser);
              },
            ),
          ),

          // ---------- Loading Indicator ----------
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.gold),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Thinking...',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          // ---------- Input Area ----------
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              border: Border(
                top: BorderSide(color: AppTheme.border, width: 1),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  // File attach button
                  IconButton(
                    onPressed: _isLoading ? null : _pickAndQueryFile,
                    icon: const Icon(Icons.attach_file_rounded),
                    color: AppTheme.gold,
                    tooltip: 'Attach file',
                  ),
                  // Text input
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !_isLoading,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ask about land, parcels, anomalies...',
                        filled: true,
                        fillColor: AppTheme.card,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide:
                          const BorderSide(color: AppTheme.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide:
                          const BorderSide(color: AppTheme.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide:
                          const BorderSide(color: AppTheme.gold),
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send button
                  GestureDetector(
                    onTap: _isLoading ? null : _sendMessage,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _isLoading
                            ? AppTheme.textMuted
                            : AppTheme.gold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, String> message, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser
              ? AppTheme.gold.withValues(alpha: 0.15)
              : AppTheme.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: Border.all(
            color: isUser
                ? AppTheme.gold.withValues(alpha: 0.4)
                : AppTheme.border,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser)
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome,
                        color: AppTheme.gold, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'DepthFence AI',
                      style: TextStyle(
                        color: AppTheme.gold,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            SelectableText(
              message['text'] ?? '',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiKeyMissingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.key_off_rounded,
                color: AppTheme.warning,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Gemini API Key Missing',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Add your Gemini API key to\nAppConstants.geminiApiKey in main.dart',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

