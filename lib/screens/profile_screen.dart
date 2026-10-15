import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import 'admin_users_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  String? _role;
  String? _fullName;

  Future<void> _fetchRole() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final data = await Supabase.instance.client
            .from('profiles')
            .select('role, full_name')
            .eq('id', user.id)
            .single();
        setState(() {
          _role = data['role'];
          _fullName = data['full_name'];
        });
      } catch (e) {
        debugPrint('Erreur rôle: $e');
      }
    }
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await Supabase.instance.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        await _fetchRole();
      } else {
        await Supabase.instance.client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          data: {'full_name': _fullNameController.text.trim()},
        );
      }
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    setState(() {
      _role = null;
      _fullName = null;
      _emailController.clear();
      _passwordController.clear();
      _fullNameController.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    if (Supabase.instance.client.auth.currentUser != null) {
      _fetchRole();
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      return ResponsiveContainer(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(r.space(24)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: r.space(20)),
                CircleAvatar(
                  radius: r.space(50),
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person,
                      size: r.fontSize(60), color: Colors.white),
                ),
                SizedBox(height: r.space(16)),
                Text(
                  _fullName?.isNotEmpty == true ? _fullName! : 'Sans nom',
                  style: TextStyle(
                    fontSize: r.fontSize(20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: r.space(4)),
                Text(
                  user.email ?? '',
                  style: TextStyle(
                    fontSize: r.fontSize(14),
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: r.space(8)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: r.space(12),
                    vertical: r.space(6),
                  ),
                  decoration: BoxDecoration(
                    color: _role == 'admin' ? Colors.red[50] : Colors.blue[50],
                    borderRadius: BorderRadius.circular(r.space(20)),
                  ),
                  child: Text(
                    _role == 'admin' ? "ADMINISTRATEUR" : "Client",
                    style: TextStyle(
                      color: _role == 'admin' ? Colors.red : Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: r.fontSize(12),
                    ),
                  ),
                ),
                SizedBox(height: r.space(32)),

                // --- BOUTONS ADMIN ---
                if (_role == 'admin') ...[
                  SizedBox(
                    width: double.infinity,
                    height: r.space(50),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AdminUsersScreen()),
                        );
                      },
                      icon: const Icon(Icons.people),
                      label: const Text("Voir les utilisateurs"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(r.space(12)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: r.space(12)),
                ],

                // --- DÉCONNEXION ---
                SizedBox(
                  width: double.infinity,
                  height: r.space(50),
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text("Se déconnecter"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(r.space(12)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // --- FORMULAIRE CONNEXION / INSCRIPTION ---
    return ResponsiveContainer(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(r.space(24)),
        child: Column(
          children: [
            SizedBox(height: r.space(30)),
            Icon(
              _isLogin ? Icons.login : Icons.person_add,
              size: r.fontSize(60),
              color: AppColors.primary,
            ),
            SizedBox(height: r.space(16)),
            Text(
              _isLogin ? "Connexion" : "Créer un compte",
              style: TextStyle(
                fontSize: r.fontSize(24),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: r.space(24)),

            if (!_isLogin) ...[
              TextField(
                controller: _fullNameController,
                style: TextStyle(fontSize: r.fontSize(14)),
                decoration: InputDecoration(
                  labelText: "Nom complet",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(r.space(12)),
                  ),
                ),
              ),
              SizedBox(height: r.space(12)),
            ],

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(fontSize: r.fontSize(14)),
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(r.space(12)),
                ),
              ),
            ),
            SizedBox(height: r.space(12)),

            TextField(
              controller: _passwordController,
              obscureText: true,
              style: TextStyle(fontSize: r.fontSize(14)),
              decoration: InputDecoration(
                labelText: "Mot de passe",
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(r.space(12)),
                ),
              ),
            ),
            SizedBox(height: r.space(20)),

            SizedBox(
              width: double.infinity,
              height: r.space(50),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(r.space(12)),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isLogin ? "Se connecter" : "S'inscrire",
                        style: TextStyle(fontSize: r.fontSize(16)),
                      ),
              ),
            ),

            TextButton(
              onPressed: () => setState(() => _isLogin = !_isLogin),
              child: Text(
                _isLogin
                    ? "Pas de compte ? Créez-en un"
                    : "Déjà un compte ? Connectez-vous",
                style: TextStyle(fontSize: r.fontSize(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
