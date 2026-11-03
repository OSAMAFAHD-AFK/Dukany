import 'package:uuid/uuid.dart';

const Uuid _uuid = Uuid();

/// IDs are created on the device so rows saved offline can be uploaded
/// later without clashing with anything already in Supabase.
String generateId() => _uuid.v4();
