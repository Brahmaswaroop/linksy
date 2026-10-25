import 'dart:typed_data';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PickedContactData {
  final String id;
  final String displayName;
  final String? phoneNumber;
  final String? email;
  final Uint8List? photoThumbnail;

  PickedContactData({
    required this.id,
    required this.displayName,
    this.phoneNumber,
    this.email,
    this.photoThumbnail,
  });
}

class ContactsService {
  /// Request system permission to read contacts
  Future<bool> requestPermission() async {
    final status =
        await FlutterContacts.permissions.request(PermissionType.read);
    return status == PermissionStatus.granted;
  }

  /// Check whether contacts permission is already granted
  Future<bool> hasPermission() async {
    return await FlutterContacts.permissions.has(PermissionType.read);
  }

  /// Open the native device contact picker (Google Contacts / System Contacts)
  /// and return the selected contact's details.
  Future<PickedContactData?> pickDeviceContact() async {
    final hasPerm = await hasPermission();
    if (!hasPerm) {
      await requestPermission();
    }

    final contact = await FlutterContacts.native.showPicker(
      properties: {
        ContactProperty.phone,
        ContactProperty.email,
        ContactProperty.photoThumbnail,
      },
    );
    if (contact == null) return null;

    final primaryPhone =
        contact.phones.isNotEmpty ? contact.phones.first.number : null;
    final primaryEmail =
        contact.emails.isNotEmpty ? contact.emails.first.address : null;

    return PickedContactData(
      id: contact.id ?? '',
      displayName: (contact.displayName ?? '').trim(),
      phoneNumber: primaryPhone,
      email: primaryEmail,
      photoThumbnail: contact.photo?.thumbnail ?? contact.photo?.fullSize,
    );
  }

  /// Fetch all device/Google contacts with phone, email, and thumbnail for bulk onboarding
  Future<List<PickedContactData>> fetchAllDeviceContacts() async {
    final hasPerm = await hasPermission();
    if (!hasPerm) {
      final granted = await requestPermission();
      if (!granted) return [];
    }

    final contacts = await FlutterContacts.getAll(
      properties: {
        ContactProperty.phone,
        ContactProperty.email,
        ContactProperty.photoThumbnail,
      },
    );

    return contacts.map((c) {
      final primaryPhone =
          c.phones.isNotEmpty ? c.phones.first.number : null;
      final primaryEmail =
          c.emails.isNotEmpty ? c.emails.first.address : null;

      return PickedContactData(
        id: c.id ?? '',
        displayName: (c.displayName ?? '').trim(),
        phoneNumber: primaryPhone,
        email: primaryEmail,
        photoThumbnail: c.photo?.thumbnail ?? c.photo?.fullSize,
      );
    }).where((c) => c.displayName.isNotEmpty).toList();
  }
}

final contactsServiceProvider = Provider<ContactsService>((ref) {
  return ContactsService();
});

