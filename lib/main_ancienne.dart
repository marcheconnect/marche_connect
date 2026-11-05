
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() => runApp(const MarcheConnect());

const vert = Color(0xFF0F4C3A);
const orange = Color(0xFFF29D38);
const fraisLivraison = 500;

// ---------- PRODUIT ----------

class Produit {
  final String nom;
  final int prix;
  final String categorie;
  final String vendeuse;
  final String marche;
  final String emplacement;
  final String telephone;
  final bool disponible;

  const Produit({
    required this.nom,
    required this.prix,
    required this.categorie,
    required this.vendeuse,
    required this.marche,
    required this.emplacement,
    required this.telephone,
    this.disponible = true,
  });
}

const produits = [
  Produit(
    nom: 'Attiéké (1 kg)',
    prix: 500,
    categorie: 'Vivriers',
    vendeuse: 'Mariam',
    marche: 'Adjamé',
    emplacement: 'Allée B, étal 12',
    telephone: '07 00 00 00 01',
  ),
  Produit(
    nom: 'Igname (1 tubercule)',
    prix: 800,
    categorie: 'Vivriers',
    vendeuse: 'Mariam',
    marche: 'Adjamé',
    emplacement: 'Allée B, étal 12',
    telephone: '07 00 00 00 01',
  ),
  Produit(
    nom: 'Banane plantain',
    prix: 1500,
    categorie: 'Vivriers',
    vendeuse: 'Aminata',
    marche: 'Abobo',
    emplacement: 'Zone vivriers, étal 4',
    telephone: '07 00 00 00 02',
  ),
  Produit(
    nom: 'Tomates (1 tas)',
    prix: 300,
    categorie: 'Légumes',
    vendeuse: 'Awa',
    marche: 'Cocody',
    emplacement: 'Entrée nord, étal 7',
    telephone: '07 00 00 00 03',
  ),
  Produit(
    nom: 'Piment frais',
    prix: 200,
    categorie: 'Légumes',
    vendeuse: 'Awa',
    marche: 'Cocody',
    emplacement: 'Entrée nord, étal 7',
    telephone: '07 00 00 00 03',
    disponible: false,
  ),
  Produit(
    nom: 'Poisson braisé',
    prix: 2500,
    categorie: 'Poisson et viande',
    vendeuse: 'Fatou',
    marche: 'Treichville',
    emplacement: 'Côté lagune, étal 3',
    telephone: '07 00 00 00 04',
  ),
  Produit(
    nom: 'Poulet braisé (1/2)',
    prix: 3000,
    categorie: 'Poisson et viande',
    vendeuse: 'Fatou',
    marche: 'Treichville',
    emplacement: 'Côté lagune, étal 3',
    telephone: '07 00 00 00 04',
  ),
  Produit(
    nom: 'Pagne wax (6 yards)',
    prix: 12000,
    categorie: 'Vêtements',
    vendeuse: 'Kadi',
    marche: 'Adjamé',
    emplacement: 'Allée D, étal 21',
    telephone: '07 00 00 00 05',
  ),
  Produit(
    nom: 'Beurre de karité',
    prix: 1000,
    categorie: 'Beauté',
    vendeuse: 'Kadi',
    marche: 'Adjamé',
    emplacement: 'Allée D, étal 21',
    telephone: '07 00 00 00 05',
  ),
  Produit(
    nom: 'Alloco et poisson',
    prix: 1500,
    categorie: 'Plats cuisinés',
    vendeuse: 'Salimata',
    marche: 'Marcory',
    emplacement: 'Rue des gargotes, étal 2',
    telephone: '07 00 00 00 06',
  ),
];

String fcfa(int nombre) {
  final texte = nombre.toString();
  final resultat = StringBuffer();

  for (var i = 0; i < texte.length; i++) {
    if (i > 0 && (texte.length - i) % 3 == 0) {
      resultat.write(' ');
    }
    resultat.write(texte[i]);
  }

  return '$resultat F CFA';
}

// ---------- PANIER PARTAGÉ ----------

class Panier extends ChangeNotifier {
  final Map<Produit, int> lignes = {};

  int get nbArticles =>
      lignes.values.fold(0, (total, qte) => total + qte);

  int get sousTotal => lignes.entries.fold(
        0,
        (total, ligne) => total + ligne.key.prix * ligne.value,
      );

  void ajouter(Produit produit) {
    lignes[produit] = (lignes[produit] ?? 0) + 1;
    notifyListeners();
  }

  void retirer(Produit produit) {
    final quantite = lignes[produit] ?? 0;

    if (quantite <= 1) {
      lignes.remove(produit);
    } else {
      lignes[produit] = quantite - 1;
    }

    notifyListeners();
  }

  void vider() {
    lignes.clear();
    notifyListeners();
  }
}

final panier = Panier();

// ---------- APPLICATION ----------

class MarcheConnect extends StatelessWidget {
  const MarcheConnect({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MARCHÉ_CONNECT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: vert),
        scaffoldBackgroundColor: const Color(0xFFF3F7F2),
        appBarTheme: const AppBarTheme(
          backgroundColor: vert,
          foregroundColor: Colors.white,
        ),
      ),
      home: const AccueilPage(),
    );
  }
}

// ---------- ACCUEIL ----------

class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  String recherche = '';
  String categorie = 'Toutes';
  String marche = 'Tous';
  bool disponibles = false;

  final categories = [
    'Toutes',
    'Vivriers',
    'Légumes',
    'Poisson et viande',
    'Vêtements',
    'Beauté',
    'Plats cuisinés',
  ];

  final marches = [
    'Tous',
    'Cocody',
    'Abobo',
    'Adjamé',
    'Treichville',
    'Marcory',
  ];

  @override
  Widget build(BuildContext context) {
    final liste = produits.where((p) {
      return p.nom.toLowerCase().contains(recherche.toLowerCase()) &&
          (categorie == 'Toutes' || p.categorie == categorie) &&
          (marche == 'Tous' || p.marche == marche) &&
          (!disponibles || p.disponible);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MARCHÉ_CONNECT',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          ListenableBuilder(
            listenable: panier,
            builder: (context, _) => IconButton(
              tooltip: 'Mon panier',
              icon: Badge(
                isLabelVisible: panier.nbArticles > 0,
                label: Text('${panier.nbArticles}'),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PanierPage(),
                ),
              ),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (valeur) {
              if (valeur == 'Accueil') {
                setState(() {
                  recherche = '';
                  categorie = 'Toutes';
                  marche = 'Tous';
                  disponibles = false;
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$valeur : bientôt disponible')),
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'Accueil', child: Text('Accueil')),
              PopupMenuItem(
                value: 'Mes commandes',
                child: Text('Mes commandes'),
              ),
              PopupMenuItem(
                value: 'Mon compte',
                child: Text('Mon compte'),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFDCEEE3), Colors.white],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: vert,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenue au marché !',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Tes produits préférés, près de chez toi.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher un produit...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (valeur) {
                  setState(() => recherche = valeur);
                },
              ),
            ),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: categories.map((c) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(c),
                      selected: categorie == c,
                      onSelected: (_) {
                        setState(() => categorie = c);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: marche,
                      items: marches.map((m) {
                        return DropdownMenuItem(
                          value: m,
                          child: Text(
                            m == 'Tous' ? 'Tous les marchés' : 'Marché de $m',
                          ),
                        );
                      }).toList(),
                      onChanged: (valeur) {
                        if (valeur != null) {
                          setState(() => marche = valeur);
                        }
                      },
                    ),
                  ),
                  const Text('Disponibles'),
                  Switch(
                    value: disponibles,
                    onChanged: (valeur) {
                      setState(() => disponibles = valeur);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('${liste.length} produits'),
              ),
            ),
            Expanded(
              child: liste.isEmpty
                  ? const Center(child: Text('Aucun produit trouvé'))
                  : ListView.builder(
                      itemCount: liste.length,
                      itemBuilder: (context, index) {
                        final p = liste[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFFFE8C2),
                              child: Icon(
                                Icons.storefront,
                                color: vert,
                              ),
                            ),
                            title: Text(
                              p.nom,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${fcfa(p.prix)}\n${p.vendeuse} · ${p.marche}',
                            ),
                            isThreeLine: true,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProduitPage(produit: p),
                              ),
                            ),
                            trailing: p.disponible
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.add_shopping_cart,
                                      color: vert,
                                    ),
                                    onPressed: () {
                                      panier.ajouter(p);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${p.nom} ajouté au panier',
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : const Text(
                                    'Épuisé',
                                    style: TextStyle(color: Colors.red),
                                  ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- FICHE PRODUIT ----------

class ProduitPage extends StatelessWidget {
  final Produit produit;

  const ProduitPage({super.key, required this.produit});

  @override
  Widget build(BuildContext context) {
    final p = produit;

    return Scaffold(
      appBar: AppBar(title: Text(p.nom)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Icon(Icons.storefront, size: 90, color: vert),
            const SizedBox(height: 16),
            Text(
              p.nom,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              fcfa(p.prix),
              style: const TextStyle(
                color: vert,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 32),
            Text('Catégorie : ${p.categorie}'),
            Text('Vendeuse : ${p.vendeuse}'),
            Text('Marché : ${p.marche}'),
            Text('Emplacement : ${p.emplacement}'),
            Text('Téléphone : ${p.telephone}'),
            Text(p.disponible ? 'Disponible' : 'Épuisé'),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton.icon(
          icon: const Icon(Icons.add_shopping_cart),
          label: const Text('Ajouter au panier'),
          onPressed: p.disponible
              ? () {
                  panier.ajouter(p);
                  Navigator.pop(context);
                }
              : null,
        ),
      ),
    );
  }
}

// ---------- PANIER ET COMMANDE ----------

class PanierPage extends StatefulWidget {
  const PanierPage({super.key});

  @override
  State<PanierPage> createState() => _PanierPageState();
}

class _PanierPageState extends State<PanierPage> {
  bool livraison = false;
  String paiement = 'Wave';

  final moyens = [
    'Wave',
    'Orange Money',
    'MTN MoMo',
    'Moov Money',
    'À la livraison',
  ];

  int get total => panier.sousTotal + (livraison ? fraisLivraison : 0);

  void commander() {
    if (panier.lignes.isEmpty) return;

    final code = (100000 + Random().nextInt(900000)).toString();
    final articles = panier.lignes.entries
        .map((e) => '${e.value} x ${e.key.nom}')
        .toList();

    final montant = total;

    panier.vider();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => TicketPage(
          code: code,
          total: montant,
          livraison: livraison,
          paiement: paiement,
          articles: articles,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: panier,
      builder: (context, _) {
        final vide = panier.lignes.isEmpty;

        return Scaffold(
          appBar: AppBar(title: const Text('Mon panier')),
          body: vide
              ? const Center(child: Text('Votre panier est vide'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ...panier.lignes.entries.map((e) {
                      return ListTile(
                        title: Text(e.key.nom),
                        subtitle: Text(fcfa(e.key.prix)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => panier.retirer(e.key),
                            ),
                            Text('${e.value}'),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => panier.ajouter(e.key),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(height: 32),
                    const Text(
                      'Récupération',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: false,
                          label: Text('Retrait'),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text('Livraison'),
                        ),
                      ],
                      selected: {livraison},
                      onSelectionChanged: (valeurs) {
                        setState(() => livraison = valeurs.first);
                      },
                    ),
                    if (livraison)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text('Frais de livraison : 500 F CFA'),
                      ),
                    const SizedBox(height: 20),
                    const Text(
                      'Moyen de paiement',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: paiement,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: moyens.map((m) {
                        return DropdownMenuItem(
                          value: m,
                          child: Text(m),
                        );
                      }).toList(),
                      onChanged: (valeur) {
                        if (valeur != null) {
                          setState(() => paiement = valeur);
                        }
                      },
                    ),
                    const Divider(height: 32),
                    Text('Sous-total : ${fcfa(panier.sousTotal)}'),
                    Text('Total : ${fcfa(total)}'),
                  ],
                ),
          bottomNavigationBar: vide
              ? null
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton(
                    onPressed: commander,
                    child: Text('Commander · ${fcfa(total)}'),
                  ),
                ),
        );
      },
    );
  }
}

// ---------- TICKET QR ----------

class TicketPage extends StatelessWidget {
  final String code;
  final int total;
  final bool livraison;
  final String paiement;
  final List<String> articles;

  const TicketPage({
    super.key,
    required this.code,
    required this.total,
    required this.livraison,
    required this.paiement,
    required this.articles,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket de commande'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: vert, size: 60),
            const Text(
              'Commande enregistrée !',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            QrImageView(
              data: 'MARCHECONNECT|$code|$total',
              size: 200,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              'N° ${code.substring(0, 3)} ${code.substring(3)}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Text(
              'Présente ce QR code au commerçant ou au livreur.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...articles.map((article) => Text(article)),
                    const Divider(height: 24),
                    Text(
                      livraison
                          ? 'Livraison à domicile'
                          : 'Retrait au marché',
                    ),
                    Text('Paiement : $paiement (simulation)'),
                    Text('Total : ${fcfa(total)}'),
                    const SizedBox(height: 12),
                    const Text(
                      'Statut : en attente de confirmation du commerçant.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          child: const Text('Retour aux produits'),
        ),
      ),
    );
  }
}
