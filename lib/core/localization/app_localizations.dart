import 'package:flutter/material.dart';

final class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('fr'), Locale('en')];
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final result = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    assert(result != null, 'AppLocalizations not found in context.');
    return result!;
  }

  bool get isFrench => locale.languageCode == 'fr';

  String tr(String english) {
    if (!isFrench) return english;
    return _french[english] ?? english;
  }

  String requiredMessage(String label) =>
      isFrench ? '$label est requis.' : '$label is required.';

  String minLengthMessage(String label, int length) => isFrench
      ? '$label doit contenir au moins $length caractères.'
      : '$label must be at least $length characters.';

  String minutesAgo(int value) => isFrench ? '$value min' : '$value min';
  String hoursAgo(int value) => isFrench ? '$value h' : '$value hr';
  String daysAgo(int value) => isFrench ? '$value j' : '$value d';
  String pendingRequests(int value) =>
      isFrench ? '$value en attente' : '$value pending';
  String missingArgument(String name) =>
      isFrench ? 'Paramètre manquant : $name.' : 'Missing $name.';
  String statusLabel(String status) {
    return switch (status.trim().toLowerCase()) {
      'pending' => tr('Pending'),
      'accepted' => tr('Accepted'),
      'processing' || 'picked_up' => tr('Picked Up'),
      'picked' || 'on_way' || 'shipped' => tr('On The Way'),
      'delivered' => tr('Delivered'),
      'rejected' => tr('Rejected'),
      _ => status,
    };
  }

  String get aboutContent => isFrench
      ? """QUI SUIS-JE ?

Bonjour, je suis Najwa, la fondatrice de Books on Wheels. J'ai créé ce projet avec une idée simple : permettre aux gens de commander leurs livres dans leurs librairies locales et de les recevoir rapidement chez eux, sans passer par les grandes plateformes.

Car au final, beaucoup commandent sur Amazon, Fnac ou Cultura surtout pour la rapidité et la praticité. Alors je me suis dit : pourquoi ne pas créer un Uber Eats du livre ? Books on Wheels est un service de livraison rapide conçu pour les librairies locales et les lecteurs qui souhaitent continuer à acheter autrement."""
      : """WHO AM I?

Hi, I'm Najwa, the founder of Books on Wheels. I created this project with a simple idea: allow people to order their books in their local bookstores and receive them quickly at home, without going through the big platforms.

Because in the end, many order on Amazon, Fnac or Cultura especially for speed and practicality. So I thought: why not create an Uber Eats of the book? Books on Wheels is a fast delivery service designed for local bookstores and readers who want to keep buying differently.""";

  String get privacyPolicyContent => isFrench
      ? """POLITIQUE DE CONFIDENTIALITÉ

1. Introduction
Books on Wheels accorde une importance particulière à la protection des données personnelles et au respect de la vie privée.
La présente Politique de Confidentialité explique quelles données sont collectées, pourquoi elles sont collectées et comment elles sont utilisées.

2. Données collectées
Books on Wheels peut collecter les informations suivantes :
• nom et prénom ;
• adresse e-mail ;
• numéro de téléphone ;
• adresse de livraison ;
• informations de commande ;
• données de navigation ;
• données de connexion ;
• informations de paiement via des prestataires sécurisés.
Books on Wheels ne stocke pas les données bancaires complètes.

3. Utilisation des données
Les données collectées sont utilisées afin de :
• gérer les commandes ;
• assurer les livraisons ;
• améliorer le service ;
• répondre aux demandes utilisateurs ;
• envoyer des informations liées au service ;
• assurer la sécurité de la Plateforme.

4. Partage des données
Certaines données peuvent être partagées avec :
• les librairies partenaires ;
• les coursiers ;
• les prestataires de paiement ;
• les prestataires techniques nécessaires au fonctionnement du service.
Books on Wheels ne revend pas les données personnelles.

5. Conservation des données
Les données sont conservées pendant la durée nécessaire au fonctionnement du service et au respect des obligations légales.

6. Sécurité
Books on Wheels met en œuvre des mesures raisonnables pour protéger les données personnelles contre les accès non autorisés, pertes ou divulgations.
Toutefois, aucun système n'étant totalement sécurisé, Books on Wheels ne peut garantir une sécurité absolue.

7. Cookies
La Plateforme peut utiliser des cookies afin :
• d'améliorer l'expérience utilisateur ;
• d'analyser l'utilisation du site ;
• de mesurer l'audience.
L'utilisateur peut gérer les cookies depuis les paramètres de son navigateur.

8. Droits des utilisateurs
Conformément au RGPD, l'utilisateur dispose des droits suivants :
• droit d'accès ;
• droit de rectification ;
• droit d'effacement ;
• droit d'opposition ;
• droit à la limitation ;
• droit à la portabilité.
Toute demande peut être adressée à : booksonwheels21000@gmail.com

9. Modification de la politique
Books on Wheels peut modifier la présente Politique de Confidentialité à tout moment.
La version la plus récente sera disponible sur la Plateforme.

MENTIONS LÉGALES
Éditeur du site : Books on Wheels
Statut juridique : micro-entreprise
Nom du responsable : EL FATTAHI Najwa
Adresse : Dijon, 21000
E-mail : booksonwheels21000@gmail.com
SIRET : 10654519700019

Contact : pour toute question concernant ce document : booksonwheels21000@gmail.com"""
      : """PRIVACY POLICY

1. Introduction
Books on Wheels places particular importance on the protection of personal data and respect for privacy.
This Privacy Policy explains what data is collected, why it is collected and how it is used.

2. Data collected
Books on Wheels can collect the following information:
• first and last name;
• email address;
• phone number;
• delivery address;
• order information;
• navigation data;
• login data;
• payment information via secure providers.
Books on Wheels does not store complete banking data.

3. Use of data
The collected data are used to:
• manage orders;
• ensure deliveries;
• improve the service;
• respond to user requests;
• send information related to the service;
• ensure the security of the Platform.

4. Data sharing
Some data can be shared with:
• partner bookstores;
• the couriers;
• payment providers;
• the technical service providers necessary for the operation of the service.
Books on Wheels does not resell personal data.

5. Data retention
The data is kept for the duration necessary for the operation of the service and compliance with legal obligations.

6. Security
Books on Wheels implements reasonable measures to protect personal data from unauthorized access, loss or disclosure.
However, since no system is completely secure, Books on Wheels cannot guarantee absolute security.

7. Cookies
The Platform may use cookies:
• to improve the user experience;
• to analyze the use of the site;
• to measure the audience.
The user can manage cookies from their browser settings.

8. User rights
According to the GDPR, the user has the following rights:
• right of access;
• right of rectification;
• right to erasure;
• right of opposition;
• right to limitation;
• right to portability.
Any request may be addressed to: booksonwheels21000@gmail.com

9. Policy changes
Books on Wheels may modify this Privacy Policy at any time.
The most recent version will be available on the Platform.

LEGAL NOTICES
Site publisher: Books on Wheels
Legal status: micro-enterprise
Manager's name: EL FATTAHI Najwa
Address: Dijon, 21000
E-mail: booksonwheels21000@gmail.com
SIRET: 10654519700019

Contact: for any questions regarding this document: booksonwheels21000@gmail.com""";

  String get termsContent => isFrench
      ? """CONDITIONS GÉNÉRALES D'UTILISATION (CGU)

1. Présentation de la plateforme
Le site et/ou l'application Books on Wheels (ci-après « la Plateforme ») est un service permettant la mise en relation entre :
• des clients souhaitant commander des livres ;
• des librairies partenaires ;
• des coursiers indépendants chargés des livraisons.
Books on Wheels agit en qualité d'intermédiaire technique et logistique.

2. Acceptation des conditions
L'utilisation de la Plateforme implique l'acceptation pleine et entière des présentes Conditions Générales d'Utilisation.
Tout utilisateur reconnaît avoir pris connaissance des présentes conditions avant toute utilisation du service.

3. Accès au service
La Plateforme est accessible aux personnes majeures disposant de la capacité juridique nécessaire.
Books on Wheels se réserve le droit de suspendre ou limiter l'accès au service à tout utilisateur ne respectant pas les présentes conditions.

4. Fonctionnement du service
Le client peut commander des livres auprès des librairies partenaires via la Plateforme.
Une fois la commande validée :
• la librairie prépare la commande ;
• un coursier indépendant récupère la commande ;
• la commande est livrée au client.
Les délais de livraison sont donnés à titre indicatif.
Books on Wheels ne garantit pas un délai fixe de livraison.

5. Responsabilités
5.1 Responsabilité des librairies
Les librairies partenaires sont seules responsables :
• des produits vendus ;
• de la conformité des livres ;
• des stocks affichés ;
• de la préparation des commandes.
5.2 Responsabilité des coursiers
Les coursiers sont des travailleurs indépendants responsables de leurs prestations de livraison.
Ils exercent leur activité sous leur propre responsabilité.
5.3 Responsabilité de Books on Wheels
Books on Wheels agit exclusivement comme plateforme de mise en relation.
La responsabilité de Books on Wheels ne pourra être engagée en cas :
• de retard de livraison ;
• d'erreur de préparation ;
• d'indisponibilité d'un produit ;
• de dommages indirects ;
• d'interruption temporaire du service ;
• de force majeure.
La responsabilité de Books on Wheels est en tout état de cause limitée au montant de la commande concernée.

6. Comportement des utilisateurs
Les utilisateurs s'engagent à :
• fournir des informations exactes ;
• utiliser la Plateforme de manière légale ;
• ne pas perturber le fonctionnement du service ;
• respecter les autres utilisateurs.
Books on Wheels se réserve le droit de suspendre un compte en cas d'abus ou de comportement inapproprié.

7. Propriété intellectuelle
Tous les contenus présents sur la Plateforme (logo, nom, design, textes, éléments graphiques, etc.) sont protégés par le droit de la propriété intellectuelle.
Toute reproduction ou utilisation sans autorisation est interdite.

8. Modification des conditions
Books on Wheels peut modifier les présentes CGU à tout moment.
Les utilisateurs seront informés des mises à jour via la Plateforme.

9. Droit applicable
Les présentes conditions sont soumises au droit français.
En cas de litige, les tribunaux compétents seront ceux du ressort du siège social de Books on Wheels.

CONDITIONS GÉNÉRALES DE VENTE (CGV)

1. Objet
Les présentes Conditions Générales de Vente définissent les modalités de commande, paiement et livraison proposées par Books on Wheels.

2. Services proposés
Books on Wheels propose :
• un service de mise en relation avec des librairies partenaires ;
• un service de livraison via des coursiers indépendants.

3. Commandes
Toute commande passée via la Plateforme implique l'acceptation des présentes CGV.
Une commande est considérée comme validée après confirmation du paiement.
Books on Wheels se réserve le droit de refuser une commande en cas de problème technique, suspicion de fraude ou indisponibilité du produit.

4. Prix
Les prix affichés sont indiqués en euros TTC.
Le montant total peut inclure :
• le prix du livre ;
• des frais de livraison ;
• des frais de service éventuels.
Books on Wheels se réserve le droit de modifier ses tarifs à tout moment.

5. Paiement
Le paiement s'effectue via les moyens proposés sur la Plateforme.
Le client garantit disposer des autorisations nécessaires pour utiliser le moyen de paiement choisi.
En cas de refus de paiement, la commande pourra être annulée.

6. Livraison
Les délais de livraison sont estimatifs.
Books on Wheels met en œuvre des moyens raisonnables pour assurer des livraisons rapides, sans garantie absolue de délai.
Le client doit fournir une adresse correcte et accessible.
En cas d'absence du client ou d'adresse incorrecte, la commande pourra être annulée sans remboursement intégral des frais de livraison.

7. Réclamations
Toute réclamation doit être adressée dans un délai de 48 heures après réception de la commande.
Des preuves pourront être demandées (photos, description du problème, etc.).

8. Remboursements
Les remboursements éventuels sont évalués au cas par cas.
Les frais de livraison peuvent ne pas être remboursés lorsque la prestation de livraison a été effectuée.
Books on Wheels se réserve le droit de refuser un remboursement en cas d'abus ou de fraude.

9. Limitation de responsabilité
Books on Wheels ne pourra être tenu responsable des dommages indirects liés à l'utilisation du service.
La responsabilité maximale de Books on Wheels est limitée au montant payé par le client pour la commande concernée.

10. Force majeure
Books on Wheels ne pourra être tenu responsable d'un retard ou d'une impossibilité de livraison causé par un événement indépendant de sa volonté :
• intempéries ;
• accidents ;
• grèves ;
• problèmes techniques ;
• circulation ;
• force majeure.

11. Droit applicable
Les présentes CGV sont soumises au droit français."""
      : """GENERAL TERMS OF USE (TOU)

1. Presentation of the platform
The Books on Wheels website and/or application (hereinafter referred to as "the Platform") is a service that allows for connections between:
• customers wishing to order books;
• partner bookstores;
• independent couriers in charge of deliveries.
Books on Wheels acts as a technical and logistical intermediary.

2. Acceptance of terms
The use of the Platform implies full and complete acceptance of these Terms of Use.
Any user acknowledges having read these terms before using the service.

3. Service access
The Platform is accessible to adults with legal capacity.
Books on Wheels reserves the right to suspend or limit access to the service to any user who does not comply with these conditions.

4. Operation of the service
The customer can order books from partner bookstores via the Platform.
Once the order is validated:
• the bookstore prepares the order;
• an independent courier collects the order;
• the order is delivered to the customer.
The delivery times are given for information purposes only.
Books on Wheels does not guarantee a fixed delivery time.

5. Responsibility
5.1 Responsibility of bookstores
The partner bookstores are solely responsible:
• for the products sold;
• for the conformity of the books;
• for the displayed stocks;
• for the preparation of orders.
5.2 Responsibility of couriers
The couriers are independent workers responsible for their delivery services.
They carry out their activity under their own responsibility.
5.3 Books on Wheels liability
Books on Wheels acts exclusively as a matchmaking platform.
Books on Wheels shall not be held liable in the event of:
• delivery delay;
• preparation error;
• a product being unavailable;
• indirect damage;
• temporary interruption of service;
• force majeure.
The liability of Books on Wheels is in any event limited to the amount of the relevant order.

6. User behavior
Users commit to:
• provide accurate information;
• use the Platform in a legal manner;
• not disrupt the operation of the service;
• respect other users.
Books on Wheels reserves the right to suspend an account in case of abuse or inappropriate behavior.

7. Intellectual property
All content on the Platform (logo, name, design, text, graphics, etc.) is protected by intellectual property law.
Any reproduction or use without permission is prohibited.

8. Modification of the conditions
Books on Wheels may modify these Terms of Use at any time.
Users will be informed of updates via the Platform.

9. Applicable law
These terms are subject to French law.
In the event of a dispute, the competent courts shall be those within the jurisdiction of the registered office of Books on Wheels.

GENERAL TERMS OF SALE (GTS)

1. Object
These General Terms and Conditions of Sale set out the ordering, payment and delivery methods offered by Books on Wheels.

2. Services offered
Books on Wheels offers:
• a matchmaking service with partner bookstores;
• a delivery service via independent couriers.

3. Orders
Any order placed via the Platform implies acceptance of these Terms of Sale.
An order is considered validated after payment has been confirmed.
Books on Wheels reserves the right to refuse an order in case of technical problem, suspicion of fraud or unavailability of the product.

4. Price
The prices quoted are in euros including tax.
The total amount can include:
• the price of the book;
• delivery fees;
• any service fees.
Books on Wheels reserves the right to change its prices at any time.

5. Payment
Payment is made via the methods offered on the Platform.
The customer guarantees to have the necessary permissions to use the chosen payment method.
If payment is refused, the order may be cancelled.

6. Delivery
The delivery times are estimated.
Books on Wheels uses reasonable means to ensure quick deliveries, without an absolute guarantee of lead time.
The client must provide a correct and accessible address.
In the event of the customer's absence or incorrect address, the order may be cancelled without a full refund of delivery costs.

7. Claims
Any complaint must be sent within 48 hours after receipt of the order.
Evidence may be requested (photos, description of the problem, etc.).

8. Reimbursements
Possible refunds are assessed on a case by case basis.
Delivery costs may not be refunded once the delivery service has been carried out.
Books on Wheels reserves the right to refuse a refund in case of abuse or fraud.

9. Limitation of liability
Books on Wheels cannot be held responsible for indirect damages related to the use of the service.
The maximum liability of Books on Wheels is limited to the amount paid by the customer for the relevant order.

10. Force majeure
Books on Wheels cannot be held responsible for any delay or impossibility of delivery caused by an event beyond its control:
• bad weather;
• accidents;
• strikes;
• technical problems;
• traffic;
• force majeure.

11. Applicable law
These Terms of Sale are subject to French law.""";

  static const _french = <String, String>{
    'About App': "À propos de l'application",
    'Accepted': 'Acceptée',
    'Active': 'Actives',
    'Address': 'Adresse',
    'Age': 'Âge',
    'All': 'Toutes',
    'Are you sure you want to log out?':
        'Êtes-vous sûr de vouloir vous déconnecter ?',
    'Assigned': 'Attribuée',
    'Available Requests': 'Demandes disponibles',
    'Back': 'Retour',
    'Bike': 'Vélo',
    'Bio': 'Bio',
    'Cancel': 'Annuler',
    'Change Password': 'Modifier le mot de passe',
    'Choose Language': 'Choisir la langue',
    'Choose a profile style': 'Choisir un style de profil',
    'Clear selection': 'Effacer la sélection',
    'Complete Profile': 'Compléter le profil',
    'Confirm New Password': 'Confirmer le nouveau mot de passe',
    'Confirm Password': 'Confirmer le mot de passe',
    'Contact': 'Contact',
    'Continue': 'Continuer',
    'Create an account': 'Créer un compte',
    'Current Password': 'Mot de passe actuel',
    'Customer': 'Client',
    'Date of Birth': 'Date de naissance',
    'Delete Account': 'Supprimer le compte',
    'Deliver Books, Earn More': 'Livrez des livres, gagnez plus',
    'Deliver To': 'Livrer à',
    'Delivered': 'Livrée',
    'Delivery': 'Livraison',
    'Delivery Address': 'Adresse de livraison',
    'Delivery Details': 'Détails de la livraison',
    'Delivery History': 'Historique des livraisons',
    'Driver Details': 'Informations du coursier',
    "Driver's Use": 'Véhicule du coursier',
    'Easy Navigation': 'Navigation facile',
    'Built-in maps and optimized routes to make your deliveries smooth.':
        'Des cartes intégrées et des itinéraires optimisés pour faciliter vos livraisons.',
    'Edit Profile': 'Modifier le profil',
    'Edit driver details': 'Modifier les informations du coursier',
    'Electric Bike': 'Vélo électrique',
    'Email': 'E-mail',
    'English': 'Anglais',
    'Enter Confirm Password': 'Confirmez votre mot de passe',
    'Enter the complete 6-digit OTP.':
        'Saisissez le code OTP complet à 6 chiffres.',
    'Enter OTP': 'Saisir le code OTP',
    'Enter your Email': 'Entrez votre e-mail',
    'Enter your Full Name': 'Entrez votre nom complet',
    'Enter your Password': 'Entrez votre mot de passe',
    'Enter your email to receive the OTP':
        "Entrez votre e-mail pour recevoir le code OTP",
    'Enter your new password and confirm password':
        'Saisissez et confirmez votre nouveau mot de passe',
    'Enter your phone number': 'Entrez votre numéro de téléphone',
    'Entrepreneur Status': 'Statut entrepreneur',
    'Entrepreneur status': 'Statut entrepreneur',
    'France': 'France',
    'French': 'Français',
    'Forgot password?': 'Mot de passe oublié ?',
    'Gender': 'Genre',
    'History': 'Historique',
    'Home': 'Accueil',
    'ID': 'Identifiant',
    'Items': 'Articles',
    'Join our network of drivers delivering knowledge across the city.':
        'Rejoignez notre réseau de coursiers qui livrent des livres dans toute la ville.',
    'Just a few more details to get you on the road':
        'Encore quelques informations avant de prendre la route',
    "Let's Get Started!": 'Commençons !',
    'Let’s Get Started': 'Commencer',
    'Load More': 'Charger plus',
    'Location not available': 'Localisation indisponible',
    'Log Out': 'Se déconnecter',
    'Male': 'Homme',
    'Female': 'Femme',
    'Other': 'Autre',
    'Mark All': 'Tout marquer',
    'Name': 'Nom',
    'New': 'Nouvelles',
    'New Password': 'Nouveau mot de passe',
    'Next': 'Suivant',
    'No active deliveries': 'Aucune livraison active',
    'No active orders': 'Aucune commande active',
    'No delivery history': 'Aucun historique de livraison',
    'No notifications yet': 'Aucune notification pour le moment',
    'No requests available': 'Aucune demande disponible',
    'Notifications': 'Notifications',
    'Offline': 'Hors ligne',
    'Online': 'En ligne',
    'On The Way': 'En route',
    'Order': 'Commande',
    'Order Details': 'Détails de la commande',
    'Order Items': 'Articles de la commande',
    'Password': 'Mot de passe',
    'Passwords do not match.': 'Les mots de passe ne correspondent pas.',
    'Phone': 'Téléphone',
    'Phone Number': 'Numéro de téléphone',
    'Picked Up': 'Récupérée',
    'Pickup From': 'Récupérer chez',
    'Plate': "Plaque d'immatriculation",
    'Privacy Policy': 'Politique de confidentialité',
    'Profile': 'Profil',
    'Profile saved. Sign in to continue.':
        'Profil enregistré. Connectez-vous pour continuer.',
    'Profile updated successfully.': 'Profil mis à jour avec succès.',
    'Reject': 'Refuser',
    'Rejected': 'Refusée',
    'Remember me': 'Se souvenir de moi',
    'Request Details': 'Détails de la demande',
    'Resend code in': 'Renvoyer le code dans',
    'RESEND OTP': 'RENVOYER LE CODE OTP',
    'SENDING...': 'ENVOI...',
    'Reset New password': 'Réinitialiser le mot de passe',
    'Reset password': 'Réinitialiser le mot de passe',
    'Retry': 'Réessayer',
    'Save': 'Enregistrer',
    'Save & Continue': 'Enregistrer et continuer',
    'Select': 'Sélectionner',
    'Select date of birth': 'Sélectionner la date de naissance',
    'Send OTP': 'Envoyer le code OTP',
    'Sent to': 'Envoyé à',
    'Sign In Here': 'Connectez-vous ici',
    'Sign Up Here': 'Inscrivez-vous ici',
    'Sign in': 'Se connecter',
    'Sign up': "S'inscrire",
    'Skip': 'Passer',
    'Status': 'Statut',
    'Terms & Conditions': "Conditions générales d'utilisation",
    'Today': "Aujourd'hui",
    'Today Earnings': "Gains aujourd'hui",
    'Today Deliveries': "Livraisons aujourd'hui",
    'Total': 'Total',
    'Track Your Earnings': 'Suivez vos gains',
    'See your daily earnings and delivery history in real-time.':
        "Consultez vos gains quotidiens et l'historique des livraisons en temps réel.",
    'United Kingdom': 'Royaume-Uni',
    'Use bike badge': "Utiliser l'icône vélo",
    'Use books badge': "Utiliser l'icône livres",
    'Use initials avatar': 'Utiliser les initiales',
    'User Email': 'E-mail utilisateur',
    'User Name': "Nom d'utilisateur",
    'Vehicle': 'Véhicule',
    'Vehicle Plate': "Plaque d'immatriculation",
    'Vehicle Plate Number (Optional)': "Plaque d'immatriculation (facultatif)",
    'Vehicle Type': 'Type de véhicule',
    'Verify': 'Vérifier',
    'Verify Now': 'Vérifier maintenant',
    'View Details': 'Voir les détails',
    'View Route on Map': "Voir l'itinéraire sur la carte",
    'Welcome Back!': 'Bon retour !',
    'Your Email': 'Votre e-mail',
    'Your account and personal profile data will be permanently deleted. This action cannot be undone.':
        'Votre compte et vos données personnelles seront définitivement supprimés. Cette action est irréversible.',
    'Your account has been deleted.': 'Votre compte a été supprimé.',
    "Don't have an account?": "Vous n'avez pas de compte ?",
    "Didn't Receive OTP?": "Vous n'avez pas reçu le code OTP ?",
    'Already have an account?': 'Vous avez déjà un compte ?',
    'A fresh OTP has been sent.': 'Un nouveau code OTP a été envoyé.',
    'Password changed successfully.': 'Mot de passe modifié avec succès.',
    'Password updated. Sign in with your new password.':
        'Mot de passe mis à jour. Connectez-vous avec votre nouveau mot de passe.',
    'New password and confirm password must match.':
        'Le nouveau mot de passe et sa confirmation doivent correspondre.',
    'Age must be a number.': "L'âge doit être un nombre.",
    'Photo access is denied. Enable Photos permission in Settings.':
        "L'accès aux photos est refusé. Activez-le dans les réglages.",
    'Image picker is already open.': "Le sélecteur d'images est déjà ouvert.",
    'Image picker is not ready. Please rebuild the app.':
        "Le sélecteur d'images n'est pas prêt. Veuillez reconstruire l'application.",
    'Could not pick image.': "Impossible de sélectionner l'image.",
    'Active Orders': 'Commandes actives',
    'Deliveries': 'Livraisons',
    'Delivery request': 'Demande de livraison',
    'Hi, Good Morning': 'Bonjour',
    'Location': 'Localisation',
    'New Requests': 'Nouvelles demandes',
    'No new delivery requests': 'Aucune nouvelle demande de livraison',
    'Pull down to refresh when you are online.':
        'Tirez vers le bas pour actualiser lorsque vous êtes en ligne.',
    'Order ID': 'Identifiant de commande',
    'Request accepted.': 'Demande acceptée.',
    'Request rejected.': 'Demande refusée.',
    "Today's Earnings": "Gains aujourd'hui",
    'Unknown Shop': 'Librairie inconnue',
    'Unknown Location': 'Localisation inconnue',
    'Go online to start': 'Passez en ligne pour commencer',
    'You need to be online to receive new delivery requests.':
        'Vous devez être en ligne pour recevoir de nouvelles demandes de livraison.',
    'Go Online': 'Passer en ligne',
    'Accept': 'Accepter',
    'Accept a delivery request to see\nit here.':
        'Acceptez une demande de livraison pour\nla voir ici.',
    'Completed deliveries will appear here.':
        'Les livraisons terminées apparaîtront ici.',
    'From:': 'De :',
    'To:': 'À :',
    'Message': 'Message',
    'Item': 'Article',
    'Total Amount': 'Montant total',
    'Driver profile is not loaded yet.':
        "Le profil du coursier n'est pas encore chargé.",
    "You're Online": 'Vous êtes en ligne',
    "You're Offline": 'Vous êtes hors ligne',
    'Order Status': 'Statut de la commande',
    'Order received by Driver': 'Commande reçue par le coursier',
    'Driver partner picked up order': 'Commande récupérée par le coursier',
    'On Way': 'En route',
    'Order On Way': 'Commande en route',
    'Order delivered successfully': 'Commande livrée avec succès',
    'Contact Information': 'Coordonnées',
    'Order Date:': 'Date de commande :',
    'Phone:': 'Téléphone :',
    'Order ID:': 'Commande :',
    'Something went wrong. Please try again.':
        "Une erreur s'est produite. Veuillez réessayer.",
    'This account is not registered as a driver.':
        "Ce compte n'est pas enregistré comme coursier.",
    'Invalid email or password': 'E-mail ou mot de passe incorrect',
    'User not found': 'Utilisateur introuvable',
    'Invalid OTP': 'Code OTP incorrect',
    'Invalid or expired OTP': 'Code OTP incorrect ou expiré',
    'Enter a valid email address.': 'Entrez une adresse e-mail valide.',
    'Driver': 'Coursier',
    'Bike courier': 'Coursier à vélo',
    'Electric bike courier': 'Coursier à vélo électrique',
    'Sign out': 'Se déconnecter',
    'Not available': 'Non disponible',
    'Pending': 'En attente',
    'Driver ID': 'Identifiant du coursier',
    'Edit Profile Again': 'Modifier à nouveau le profil',
    'Your onboarding and driver profile are ready.':
        'Votre intégration et votre profil de coursier sont prêts.',
    'Earlier': 'Plus tôt',
    'No notifications yet.': 'Aucune notification pour le moment.',
    'now': 'maintenant',
    'Status updated successfully': 'Statut mis à jour avec succès',
    'Failed to update status': 'Échec de la mise à jour du statut',
    'Mark as Picked': 'Marquer comme récupérée',
    'Go to On Way': 'Marquer en route',
    'Confirm Delivery': 'Confirmer la livraison',
    'Done': 'Terminer',
    'Estimated Earnings:': 'Gains estimés :',
    'Order not found.': 'Commande introuvable.',
    'Shop': 'Librairie',
    'Driver request not found': 'Demande de livraison introuvable',
    'Copy': 'Copier',
    'Copied to clipboard': 'Copié dans le presse-papiers',
    'Open in Maps': 'Ouvrir dans Plans',
    'Send email': 'Envoyer un e-mail',
    'Could not open this action.': "Impossible d'ouvrir cette action.",
  };
}

final class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
    (supported) => supported.languageCode == locale.languageCode,
  );

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
