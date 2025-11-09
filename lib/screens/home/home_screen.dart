import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/home_bloc.dart';
import '../../cubits/home_event.dart';
import '../../cubits/home_state.dart';
import '../../models/home_overview_model.dart';
import '../../models/notes_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/category_grid_item.dart';
import '../../widgets/home_app_bar.dart';
import '../../widgets/pinned_note_card.dart';
import '../../widgets/recent_note_card.dart';
import '../../widgets/section_header.dart';
import '../auth/login_screen.dart';
import '../editor/note_editor_screen.dart';
import '../note_detail/note_detail_screen.dart';
import '../notes/notes_screen.dart';
import '../search/search_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const HomeOverviewData _emptyOverview = HomeOverviewData(
    pinnedNotes: <Note>[],
    categorySummaries: <CategorySummary>[],
    recentNotes: <Note>[], 
  );

  int _selectedIndex = 0;
  final _authService = AuthService();
  String _userName = 'Notely User';

  @override
  void initState() {
    super.initState();
    _loadUserName();
    // Load home overview data when screen initializes
    context.read<HomeBloc>().add(const LoadHomeOverview());
  }

  Future<void> _loadUserName() async {
    final user = await _authService.getLoggedInUser();
    if (user != null && mounted) {
      setState(() {
        _userName = user['username'] ?? 'Notely User';
      });
    }
  }




  @override
  void dispose() {
    super.dispose();
  }

  void _handleRefresh() {
    context.read<HomeBloc>().add(const LoadHomeOverview());
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  void _onBottomNavTapped(int index) async {
    if (index == 2) {
      return;
    }
    
    // Navigate to notes screen when notes icon is tapped
    if (index == 1) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NotesScreen()),
      );
      // No need to reload - NotesScreen uses NotesBloc which is separate from HomeBloc
      // HomeBloc state is preserved and doesn't need reloading
      return;
    }
    
    // Navigate to search screen when search icon is tapped
    if (index == 3) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SearchScreen()),
      );
      // No need to reload - SearchScreen uses SearchBloc which is separate from HomeBloc
      // HomeBloc state is preserved and doesn't need reloading
      return;
    }

    // Navigate to profile screen when profile icon is tapped
    if (index == 4) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
      // Reload user name when returning from profile
      if (mounted) {
        _loadUserName();
      }
      return;
    }
    
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: HomeAppBar(
        userName: _userName,
        onProfileTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
          if (mounted) {
            _loadUserName();
          }
        },
        onLogoutTap: _handleLogout,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NoteEditorScreen()),
          );
          // Only reload if note was created/saved (result is true)
          if (result == true && mounted) {
            _handleRefresh();
          }
        },
        label: const Text('New note'),
        icon: const Icon(Icons.add),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurfaceVariant,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notes_outlined),
            activeIcon: Icon(Icons.notes),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.circle, color: Colors.transparent),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          // Handle any side effects like showing snackbars
          if (state is HomeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          // Handle loading state
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle error state
          if (state is HomeError) {
            return _ErrorState(
              message: 'Something went wrong while loading your notes.',
              onRetry: () async => _handleRefresh(),
            );
          }

          // Get overview data
          HomeOverviewData data = _emptyOverview;
          if (state is HomeLoaded) {
            data = state.overview;
          }

          return RefreshIndicator(
            onRefresh: () async => _handleRefresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 120),
              children: [
                SectionHeader(
                  title: 'Pinned',
                  actionText: 'View all',
                  onActionPressed: () {},
                ),
                _buildPinnedList(data.pinnedNotes),
                SectionHeader(
                  title: 'Main Categories',
                  actionText: 'Manage',
                  onActionPressed: () {},
                ),
                _buildCategoriesGrid(data.categorySummaries),
                SectionHeader(
                  title: 'Recent',
                  actionText: 'View all',
                  onActionPressed: () {},
                ),
                _buildRecentList(data.recentNotes),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPinnedList(List<Note> pinnedNotes) {
    if (pinnedNotes.isEmpty) {
      return const _EmptyState(message: 'Pin notes to access them quickly.');
    }

    return SizedBox(
      height: 190,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final note = pinnedNotes[index];
          return PinnedNoteCard(
            tag: 'Pinned',
            title: note.title,
            description: note.summary,
            tagColor: _colorForCategory(note.category),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteDetailScreen(noteId: note.id),
                ),
              );
              // Only reload if note was modified (result is true)
              if (result == true && mounted) {
                _handleRefresh();
              }
            },
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: pinnedNotes.length,
      ),
    );
  }

  Widget _buildCategoriesGrid(List<CategorySummary> categories) {
    if (categories.isEmpty) {
      return const _EmptyState(
        message: 'Create categories to organise your notes.',
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        shrinkWrap: true,
        itemCount: categories.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryGridItem(
            icon: category.icon ?? Icons.folder_open,
            title: category.name,
            noteCount: category.noteCount,
            onTap: () {},
          );
        },
      ),
    );
  }

  Widget _buildRecentList(List<Note> recentNotes) {
    if (recentNotes.isEmpty) {
      return const _EmptyState(message: 'Recently created notes show up here.');
    }

    return SizedBox(
      height: 170,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final note = recentNotes[index];
          return RecentNoteCard(
            category: note.category.isEmpty ? 'General' : note.category,
            title: note.title,
            description: note.summary,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteDetailScreen(noteId: note.id),
                ),
              );
              // Only reload if note was modified (result is true)
              if (result == true && mounted) {
                _handleRefresh();
              }
            },
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: recentNotes.length,
      ),
    );
  }

  Color _colorForCategory(String category) {
    final theme = Theme.of(context);
    final key = category.toLowerCase();
    switch (key) {
      case 'work':
        return Colors.orange;
      case 'personal':
        return Colors.green;
      case 'ideas':
        return Colors.indigo;
      case 'study':
        return Colors.blue;
      case 'health':
        return Colors.redAccent;
      case 'travel':
        return Colors.teal;
      case 'finance':
        return Colors.deepPurple;
      default:
        return theme.colorScheme.primary;
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
