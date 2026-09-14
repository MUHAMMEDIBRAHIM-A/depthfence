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
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
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
  static const String appVersion = '1.1.0-MVP';
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

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _restoreSession();
    await _loadRegisteredUsers();
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
              (const _JsonCodecShim()).decode(s) as Map,
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
    final list = _registeredUsers
        .map((u) => const _JsonCodecShim().encode(u.toJson()))
        .toList();
    await p.setStringList(AppConstants.registeredUsersKey, list);
  }

  Future<void> _persistSession() async {
    final p = _prefs;
    if (p == null) return;
    await p.setBool(AppConstants.sessionKey, _isLoggedIn);
    await p.setString(AppConstants.userRoleKey, _userRole);
    await p.setString(AppConstants.userEmailKey, _userEmail);
    await p.setString(AppConstants.userNameKey, _userName);
  }

  Future<String?> tryLogin(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail == AppConstants.adminEmail &&
        password == AppConstants.adminPassword) {
      _isLoggedIn = true;
      _userRole = 'admin';
      _userEmail = AppConstants.adminEmail;
      _userName = 'Administrator';
      await _persistSession();
      notifyListeners();
      return 'admin';
    }

    final user = _registeredUsers.firstWhere(
      (u) => u.email.toLowerCase() == normalizedEmail,
      orElse: () => RegisteredUser(
        name: '',
        district: '',
        city: '',
        pincode: '',
        mobile: '',
        email: '',
        password: '',
      ),
    );

    if (user.email.isNotEmpty && user.password == password) {
      _isLoggedIn = true;
      _userRole = 'user';
      _userEmail = user.email;
      _userName = user.name;
      await _persistSession();
      notifyListeners();
      return 'user';
    }

    return null;
  }

  Future<String> register(RegisteredUser user) async {
    final email = user.email.trim().toLowerCase();
    if (email == AppConstants.adminEmail) return 'invalid';
    if (_registeredUsers.any((u) => u.email.toLowerCase() == email)) {
      return 'exists';
    }
    _registeredUsers.add(user);
    await _persistRegisteredUsers();
    return 'ok';
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
    _isLoggedIn = false;
    _userEmail = '';
    _userName = '';
    _userRole = 'user';
    _currentTabIndex = 0;
    await _persistSession();
    notifyListeners();
  }

  void setCurrentLocation(LatLng loc) {
    _currentLocation = loc;
    notifyListeners();
  }

  void setTabIndex(int i) {
    _currentTabIndex = i;
    notifyListeners();
  }
}

class _JsonCodecShim {
  const _JsonCodecShim();
  String encode(Object? o) => _encode(o);
  dynamic decode(String s) => _decode(s);

  String _encode(Object? o) {
    if (o == null) return 'null';
    if (o is String) return '"${o.replaceAll('"', '\\"')}"';
    if (o is num || o is bool) return '$o';
    if (o is List) return '[${o.map(_encode).join(',')}]';
    if (o is Map) {
      return '{${o.entries.map((e) => '${_encode(e.key.toString())}:${_encode(e.value)}').join(',')}}';
    }
    return 'null';
  }

  dynamic _decode(String s) => _decodeObj(s.trim());

  dynamic _decodeObj(String s) {
    if (s == 'null') return null;
    if (s.startsWith('"') && s.endsWith('"')) {
      return s.substring(1, s.length - 1).replaceAll('\\"', '"');
    }
    if (s == 'true') return true;
    if (s == 'false') return false;
    final n = num.tryParse(s);
    if (n != null) return n;
    if (s.startsWith('[')) return _decodeList(s);
    if (s.startsWith('{')) return _decodeMap(s);
    return s;
  }

  List _decodeList(String s) {
    final inner = s.substring(1, s.length - 1).trim();
    if (inner.isEmpty) return [];
    return _splitTopLevel(inner).map(_decodeObj).toList();
  }

  Map<String, dynamic> _decodeMap(String s) {
    final inner = s.substring(1, s.length - 1).trim();
    final out = <String, dynamic>{};
    if (inner.isEmpty) return out;
    for (final pair in _splitTopLevel(inner)) {
      final idx = pair.indexOf(':');
      if (idx < 0) continue;
      final k = _decodeObj(pair.substring(0, idx).trim()) as String;
      final v = _decodeObj(pair.substring(idx + 1).trim());
      out[k] = v;
    }
    return out;
  }

  List<String> _splitTopLevel(String s) {
    final parts = <String>[];
    var depth = 0;
    var inStr = false;
    var start = 0;
    for (var i = 0; i < s.length; i++) {
      final c = s[i];
      if (c == '"' && (i == 0 || s[i - 1] != '\\')) inStr = !inStr;
      if (inStr) continue;
      if (c == '{' || c == '[') depth++;
      if (c == '}' || c == ']') depth--;
      if (c == ',' && depth == 0) {
        parts.add(s.substring(start, i));
        start = i + 1;
      }
    }
    parts.add(s.substring(start));
    return parts;
  }
}

// ============================================================
// MAIN
// ============================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        '/delta_z_scanner': (context) => const DeltaZScreen(),
        '/anomaly_detection': (context) => const AnomalyDetectionScreen(),
        '/blueprint': (context) => const BlueprintDownloadScreen(),
        '/permissions': (context) => const PermissionsScreen(),
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
    final state = Provider.of<DepthFenceState>(context, listen: false);
    await state.loginAsDemoUser();
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
                          if (!RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w+$')
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
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager_only_labels/{z}/{x}/{y}{r}.png';

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
        '&limit=6'
        '&addressdetails=1',
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'DepthFence-App/1.0 (com.depthfence.app)',
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

    final screens = const [
      HomeMapScreen(),
      AnomalyDetectionScreen(),
      TerrainAnalysisScreen(),
      ProfileScreen(),
    ];

    const items = [
      {'icon': Icons.map_outlined, 'active': Icons.map, 'label': 'Map'},
      {'icon': Icons.warning_amber_outlined, 'active': Icons.warning_amber, 'label': 'Anomalies'},
      {'icon': Icons.terrain_outlined, 'active': Icons.terrain, 'label': 'Terrain'},
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
                  onPressed: () {
                    final title = _titleController.text.trim().isNotEmpty
                        ? _titleController.text.trim()
                        : '$_type Detected';
                    final desc = _descController.text.trim().isNotEmpty
                        ? _descController.text.trim()
                        : 'Manual field observation logged at current location.';

                    final idNum =
                        (100 + DateTime.now().millisecond % 900).toString();
                    final newAnomaly = Anomaly(
                      id: 'ANM-$idNum',
                      title: title,
                      description: desc,
                      parcelId: _selectedParcelId,
                      severity: _severity,
                      status: 'new',
                      location: state.currentLocation,
                      detectedAt: DateTime.now(),
                    );

                    state.addAnomaly(newAnomaly);

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🚨 Anomaly report ANM-$idNum saved!'),
                        backgroundColor: AppTheme.success,
                        behavior: SnackBarBehavior.floating,
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
                    onPressed: _points.length >= 3 ? () {} : null,
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
          _tile(Icons.history, 'Activity History', 'View recent actions'),
          _tile(
            Icons.security_rounded,
            'Permissions',
            'Manage app access',
            onTap: () => Navigator.pushNamed(context, '/permissions'),
          ),
          _tile(
            Icons.settings,
            'Settings',
            'App preferences',
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) => const SettingsSheet(),
              );
            },
          ),
          _tile(Icons.help_outline, 'Help & Support', 'FAQs and contact'),
          _tile(Icons.info_outline, 'About DepthFence',
              'Version ${AppConstants.appVersion}'),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String title, String subtitle,
      {VoidCallback? onTap}) {
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

