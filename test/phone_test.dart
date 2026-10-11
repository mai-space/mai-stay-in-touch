import 'package:flutter_test/flutter_test.dart';
import 'package:mai_stay_in_touch/domain/phone.dart';

void main() {
  test('Wählen: nur Ziffern und +', () {
    expect(Phone.dialable(' +49 (171) 123-45 67 '), '+491711234567');
  });

  test('WhatsApp: internationale Nummer ohne +', () {
    expect(Phone.international('+49 171 1234567', '49'), '491711234567');
    expect(Phone.international('0049 171 1234567', '49'), '491711234567');
    expect(Phone.international('0171 1234567', '49'), '491711234567');
    expect(Phone.international('0664 1234567', '43'), '436641234567');
    expect(Phone.international('+49 (0) 171 1234567', '49'), '491711234567');
    expect(Phone.international('+1 415 555 0100', '49'), '14155550100');
    expect(Phone.international('', '49'), isNull);
    expect(Phone.international('112', '49'), isNull);
  });

  test('Ländervorwahl aus der Region', () {
    expect(Phone.countryCodeFor('de_DE'), '49');
    expect(Phone.countryCodeFor('de_AT'), '43');
    expect(Phone.countryCodeFor('en-US'), '1');
    expect(Phone.countryCodeFor('en'), '49');
    expect(Phone.countryCodeFor(null), '49');
  });

  test('Initialen', () {
    expect(Phone.initials('Anna Berger'), 'AB');
    expect(Phone.initials('anna maria berger'), 'AB');
    expect(Phone.initials('Ömer'), 'Ö');
    expect(Phone.initials('  '), '?');
  });
}
