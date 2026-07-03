import 'package:flutter_test/flutter_test.dart';
import 'package:src/models/api_enums.dart';
import 'package:src/widgets/formatters.dart';

void main() {
  group('[Unit Test] Formatters', () {
    group('formatMoney', () {
      test('TC-U35: formatMoney(0) trả về "0 VND"', () {
        expect(formatMoney(0), '0 VND');
      });

      test('TC-U36: formatMoney(15000) trả về "15000 VND"', () {
        expect(formatMoney(15000), '15000 VND');
      });

      test('TC-U37: formatMoney(250000.5) làm tròn thành "250001 VND"', () {
        expect(formatMoney(250000.5), '250001 VND');
      });
    });

    group('formatDate', () {
      test('TC-U38: formatDate(DateTime(2026, 1, 5)) trả về "05/01/2026"', () {
        final date = DateTime(2026, 1, 5);
        expect(formatDate(date), '05/01/2026');
      });

      test('TC-U39: formatDate(DateTime(2026, 12, 25)) trả về "25/12/2026"', () {
        final date = DateTime(2026, 12, 25);
        expect(formatDate(date), '25/12/2026');
      });
    });

    group('orderStatusLabel', () {
      test('TC-U40: orderStatusLabel(pending) trả về "Pending"', () {
        expect(orderStatusLabel(OrderStatus.pending), 'Pending');
      });

      test('TC-U41: orderStatusLabel(paid) trả về "Paid"', () {
        expect(orderStatusLabel(OrderStatus.paid), 'Paid');
      });

      test('TC-U42: orderStatusLabel(cancelled) trả về "Cancelled"', () {
        expect(orderStatusLabel(OrderStatus.cancelled), 'Cancelled');
      });
    });
  });
}
