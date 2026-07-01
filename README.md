# Moje Miejsca

Moje Miejsca to prosta aplikacja mobilna Flutter na Androida. Aplikacja dziala jako lokalny notatnik miejsc: pozwala zapisac notatke, dodac zdjecie z aparatu, pobrac lokalizacje GPS i przechowac wszystko lokalnie na urzadzeniu.

## Cel aplikacji

Celem aplikacji jest szybkie zapisywanie miejsc, do ktorych uzytkownik chce pozniej wrocic. Kazdy wpis zawiera tekst notatki, date utworzenia, wspolrzedne GPS oraz opcjonalne zdjecie.

## Funkcje

- wyswietlanie listy zapisanych miejsc,
- pusty stan, gdy nie ma zapisanych miejsc,
- dodawanie notatki tekstowej,
- robienie zdjecia aparatem,
- pobieranie lokalizacji GPS przy zapisie,
- lokalny zapis danych w SQLite,
- wyswietlanie daty, wspolrzednych GPS i miniatury zdjecia,
- usuwanie zapisanych miejsc,
- otwieranie zapisanej lokalizacji w Google Maps.

## Technologie i paczki

- Flutter i Dart,
- `sqflite` - lokalna baza danych SQLite,
- `path` - budowanie sciezek do plikow i bazy,
- `path_provider` - dostep do katalogow aplikacji,
- `geolocator` - lokalizacja GPS i uprawnienia lokalizacji,
- `image_picker` - obsluga aparatu,
- `url_launcher` - otwieranie linku Google Maps.

## Uruchomienie

Wymagania:

- Flutter SDK,
- Android Studio albo Android SDK,
- uruchomiony emulator Androida albo podlaczone urzadzenie.

Pobierz zaleznosci:

```bash
flutter pub get
```

Uruchom aplikacje:

```bash
flutter run
```

Jesli jest podlaczonych kilka urzadzen, sprawdz ich liste:

```bash
flutter devices
```

Nastepnie uruchom aplikacje na wybranym emulatorze, na przyklad:

```bash
flutter run -d emulator-5554
```

## Testowanie na emulatorze

1. Uruchom emulator Androida.
2. Uruchom aplikacje komenda `flutter run`.
3. Na ekranie glownym kliknij przycisk `+`.
4. Wpisz notatke w polu "Notatka".
5. Kliknij "Zrob zdjecie" i wykonaj zdjecie aparatem emulatora.
6. Kliknij "Zapisz miejsce".
7. Jesli Android poprosi o zgode na lokalizacje, zaakceptuj ja.
8. Sprawdz, czy nowe miejsce pojawilo sie na liscie.
9. Kliknij zapisane miejsce, zeby otworzyc jego lokalizacje w Google Maps.
10. Kliknij ikone kosza, zeby usunac zapisane miejsce.

## Sprawdzenie kodu

```bash
flutter analyze
```
