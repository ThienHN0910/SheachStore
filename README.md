# SheachStore

SheachStore la ung dung Flutter ket noi voi `SheachStore.WebApi` cho bookstore. Repo hien co hai phan chinh:

- Flutter mobile/client app trong `lib/`.
- ASP.NET Core .NET 8 WebApi trong `SheachStore.WebApi/`.

## Flutter client

Client dung Flutter thuan, `http` de goi REST API va `flutter_secure_storage` de luu JWT.

`lib/` duoc chia theo cac nhom:

- `core/api/`: `ApiClient`, base URL config, API exception.
- `core/storage/`: JWT token storage.
- `models/`: DTO models va enums khop voi WebApi.
- `services/`: service layer cho auth, books, categories, authors, cart, orders, reviews.
- `screens/`: customer screens cho login/register, catalog, book detail, cart checkout, my orders.
- `widgets/`: loading, empty, error states va formatter helpers.

## Customer flow

- Login/register bang `AuthService`.
- Xem danh sach sach va chi tiet sach.
- Doc va gui review cho sach.
- Them sach vao cart, doi quantity, xoa item, clear cart.
- Checkout tu cart bang shipping address va payment method.
- Sau checkout thanh cong, Flutter clear cart va order xuat hien trong My Orders.

## Local API URL

`ApiConfig` dang dung port `5202`:

- Android emulator: `http://10.0.2.2:5202`
- Platform khac: `http://localhost:5202`

Hay chay WebApi truoc khi chay Flutter app.

## Run

WebApi:

```powershell
cd SheachStore.WebApi
dotnet restore
dotnet run
```

Flutter:

```powershell
flutter pub get
flutter run
```

Quality checks:

```powershell
dart format lib test
flutter analyze
flutter test
```
