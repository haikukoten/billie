import 'package:contacts_service/contacts_service.dart';

class ContactServiceProxy {

  static ContactServiceProxy sContactServiceProxy;

  static ContactServiceProxy getInstance() {
    return sContactServiceProxy == null
        ? ContactServiceProxy()
        : sContactServiceProxy;
  }


  Future<Iterable<Contact>> searchContact (String query) async {
    return await ContactsService.getContacts(query: query,photoHighResolution: false, withThumbnails: true);
  }

  Future<Iterable<Contact>> getContacts () async {
    return await ContactsService.getContacts(withThumbnails: false, photoHighResolution: false);
  }

}