import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<dynamic> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('*')
          .order('created_at', ascending: false);

      setState(() {
        _users = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleRole(String userId, String currentRole) async {
    final newRole = currentRole == 'admin' ? 'client' : 'admin';
    try {
      await Supabase.instance.client
          .from('profiles')
          .update({'role': newRole})
          .eq('id', userId);
      
      _fetchUsers();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Rôle changé en $newRole"),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final formatDate = DateFormat('dd/MM/yyyy HH:mm', 'fr_FR');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          "Utilisateurs (${_users.length})",
          style: TextStyle(fontSize: r.fontSize(18)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchUsers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(r.space(24)),
                    child: Text(
                      "Erreur : $_error",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )
              : _users.isEmpty
                  ? const Center(
                      child: Text("Aucun utilisateur inscrit"),
                    )
                  : ResponsiveContainer(
                      child: ListView.builder(
                        padding: EdgeInsets.all(r.space(12)),
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          final isAdmin = user['role'] == 'admin';
                          
                          return Card(
                            margin: EdgeInsets.only(bottom: r.space(8)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isAdmin ? Colors.red : AppColors.primary,
                                child: Icon(
                                  isAdmin ? Icons.admin_panel_settings : Icons.person,
                                  color: Colors.white,
                                  size: r.fontSize(22),
                                ),
                              ),
                              title: Text(
                                user['full_name']?.isNotEmpty == true
                                    ? user['full_name']
                                    : 'Sans nom',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: r.fontSize(14),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: r.space(2)),
                                  Text(
                                    user['email'] ?? '',
                                    style: TextStyle(fontSize: r.fontSize(12)),
                                  ),
                                  SizedBox(height: r.space(2)),
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: r.space(6),
                                          vertical: r.space(2),
                                        ),
                                        decoration: BoxDecoration(
                                          color: isAdmin ? Colors.red[50] : Colors.blue[50],
                                          borderRadius: BorderRadius.circular(r.space(4)),
                                        ),
                                        child: Text(
                                          isAdmin ? 'ADMIN' : 'CLIENT',
                                          style: TextStyle(
                                            fontSize: r.fontSize(9),
                                            fontWeight: FontWeight.bold,
                                            color: isAdmin ? Colors.red : Colors.blue,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: r.space(8)),
                                      Text(
                                        user['created_at'] != null
                                            ? formatDate.format(DateTime.parse(user['created_at']))
                                            : '',
                                        style: TextStyle(
                                          fontSize: r.fontSize(10),
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  isAdmin ? Icons.remove_moderator : Icons.add_moderator,
                                  color: isAdmin ? Colors.orange : Colors.green,
                                ),
                                tooltip: isAdmin ? 'Retirer admin' : 'Passer admin',
                                onPressed: () => _toggleRole(user['id'], user['role'] ?? 'client'),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
