# Books on Wheels Driver - App Store Connect Submission

Updated: July 24, 2026

## App Record

- App name: `Books on Wheels Driver`
- Bundle ID: `com.najwafth.booksonwheelsdriver`
- SKU suggestion: `books-on-wheels-driver-ios`
- Primary language: French
- Platforms: iPhone and iPad
- Primary category: Business
- Secondary category: Navigation
- Version: `1.0.0`
- Build: increment the `+1` suffix in `pubspec.yaml` for every upload
- Copyright: `2026 Books on Wheels`
- Content rights: confirm Books on Wheels owns or licenses all displayed content
- Age rating: answer "None" for violence, sexual content, gambling, drugs, profanity, horror, and unrestricted web access; use the rating Apple calculates

Do not change the bundle ID after creating the App Store Connect record. Confirm that this identifier exists in the correct Apple Developer team before archiving.

## French Listing

Subtitle (30 characters maximum):

`Livraisons pour librairies`

Promotional text (170 characters maximum):

`Acceptez les demandes, suivez vos livraisons et ouvrez rapidement chaque itinéraire avec Books on Wheels Driver.`

Description:

`Books on Wheels Driver accompagne les coursiers partenaires dans leurs livraisons de livres pour les librairies locales.`

`Consultez les demandes disponibles, acceptez une mission, retrouvez les informations de retrait et de livraison, ouvrez l'itinéraire dans votre application de cartographie et mettez à jour le statut jusqu'à la remise de la commande.`

`L'application permet également de consulter les livraisons actives et terminées, de gérer les informations du profil coursier, de choisir le français ou l'anglais et de recevoir les notifications liées aux missions.`

`Un compte coursier Books on Wheels est nécessaire.`

Keywords (100 bytes maximum):

`livraison,coursier,livres,librairie,missions,itinéraires`

## English Listing

Subtitle (30 characters maximum):

`Book delivery for drivers`

Promotional text (170 characters maximum):

`Accept requests, manage active deliveries, and open every route quickly with Books on Wheels Driver.`

Description:

`Books on Wheels Driver helps partner drivers deliver books from local bookstores.`

`View available requests, accept an assignment, access pickup and delivery information, open the route in your preferred maps app, and update progress through final delivery.`

`The app also provides active and completed delivery history, driver profile management, French and English language options, and assignment notifications.`

`A Books on Wheels driver account is required.`

Keywords (100 bytes maximum):

`delivery,driver,books,bookstore,courier,routes,orders`

## URLs

These become valid after deploying the updated backend:

- Privacy Policy URL: `https://api.booksonwheeels.com/public/driver/privacy.html`
- Support URL: `https://api.booksonwheeels.com/public/driver/support.html`
- Marketing URL: optional; do not use the current main website until its forced sign-in/localhost redirect is fixed

Verify both URLs in a private browser window before submission. They must open without authentication.

## App Privacy Answers

Tracking:

- Data used to track the user: No
- App Tracking Transparency prompt: Not used

Data linked to the driver and used for App Functionality:

- Contact Info: Name, Email Address, Phone Number, Physical Address
- User Content: Photos (optional profile photo)
- Identifiers: User ID
- Other Data: driver ID, entrepreneur status, vehicle type, vehicle plate number

The app displays customer/order delivery information to an assigned driver. Re-check the production backend and every bundled third-party SDK before publishing the privacy answers. Do not declare diagnostics, analytics, precise device location, payment information, or advertising data unless production services actually collect them.

## Review Information

Create a permanent review driver account on the production API and keep at least:

- one available delivery request
- one active assignment
- one completed delivery

Review notes:

`This app is for Books on Wheels delivery drivers. Sign in with the demo driver account provided in App Review Information. The Home tab shows available requests; Active shows accepted deliveries; History shows completed deliveries. Opening a delivery shows pickup and destination details. "View Route on Map" opens the device's installed maps application. Profile contains language selection, legal documents, profile editing, and permanent in-app account deletion. No purchase or subscription is available in this app. The production backend must remain available during review.`

Enter a monitored contact name, phone number, and email in App Review Information. Put the demo email and password in the dedicated sign-in fields, not only in review notes.

## Screenshots

- Upload 1 to 10 screenshots for each required device class.
- This project currently supports iPhone and iPad (`TARGETED_DEVICE_FAMILY = 1,2`), so capture both required iPhone and iPad sizes shown by App Store Connect.
- Recommended sequence: available requests, request details, active delivery, route/status workflow, history, driver profile.
- Use production-like sample content with no real customer personal data.
- Use PNG or JPEG without transparency and do not add unsupported claims or prices.

## Privacy, Encryption, and Permissions

- `PrivacyInfo.xcprivacy` declares app-only UserDefaults access reason `CA92.1`.
- `ITSAppUsesNonExemptEncryption` is `false` because the app uses standard HTTPS transport rather than proprietary encryption. The account holder remains responsible for confirming export-compliance answers.
- The only iOS permission requested is photo-library read access for selecting an optional profile image.
- Account deletion is available from Profile and calls `DELETE /api/v1/user/me`.

## Signing and Upload Checklist

1. Enroll the legal entity in the Apple Developer Program and accept all current agreements.
2. Create or confirm App ID `com.najwafth.booksonwheelsdriver`.
3. Open `ios/Runner.xcworkspace` in Xcode and select the correct Team under Signing & Capabilities.
4. Confirm the app record uses the exact same bundle ID.
5. Deploy the updated backend and verify the API, privacy URL, support URL, and account-deletion endpoint.
6. Run `flutter clean`, `flutter pub get`, `flutter analyze`, and `flutter test`.
7. Build with `flutter build ipa --release --build-name 1.0.0 --build-number 1`.
8. Test the archive on a physical iPhone and iPad through TestFlight.
9. Upload from Xcode Organizer or Transporter.
10. Complete pricing/availability, age rating, app privacy, export compliance, review contact, demo credentials, screenshots, and phased-release choice.
11. Select the processed build, resolve every App Store Connect warning, then submit for review.

## Values Still Requiring Account-Owner Input

- Apple Developer Team ID and signing certificate
- App Store Connect user roles and agreements
- Final SKU if the suggested SKU is not desired
- Review contact phone number
- Production demo driver email and password
- Final countries/regions and pricing (normally Free)
- Confirmation of legal entity name, SIRET, address, privacy practices, and export classification
