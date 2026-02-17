import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:here/providers/notification_provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _fade = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
      _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colors.background,
      appBar: NotificationAppBar(colors: colors),
      body: FadeTransition(
        opacity: _fade,
        child: Consumer<NotificationProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.notifications.isEmpty) {
              return Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2, 
                  color: colors.primary,
                ),
              );
            }

            if (provider.status == NotificationStatus.error && provider.notifications.isEmpty) {
              return _ErrorView(provider: provider, colors: colors);
            }

            if (provider.notifications.isEmpty) return NotificationEmptyState(colors: colors);

            final grouped = provider.groupedNotifications;

            return RefreshIndicator(
              onRefresh: () => provider.loadNotifications(refresh: true),
              color: colors.primary,
              backgroundColor: colors.surface,
              edgeOffset: 20,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: grouped.length,
                itemBuilder: (context, index) {
                  final date = grouped.keys.elementAt(index);
                  final items = grouped[date]!;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DateHeader(date: date, colors: colors),
                      ...items.map((item) => _DismissibleTile(
                        item: item, 
                        provider: provider,
                        colors: colors,
                      )),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DismissibleTile extends StatelessWidget {
  final NotificationItem item;
  final NotificationProvider provider;
  final ColorScheme colors;

  const _DismissibleTile({
    required this.item, 
    required this.provider,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: colors.error,
        child: Icon(Icons.delete_outline, color: colors.onError),
      ),
      onDismissed: (_) => provider.removeNotification(item.id),
      child: NotificationTile(
        item: item,
        colors: colors,
        onTap: () => provider.markAsRead(item.id),
      ),
    );
  }
}

class NotificationAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ColorScheme colors;
  
  const NotificationAppBar({super.key, required this.colors});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final int unread = context.select<NotificationProvider, int>((p) => p.unreadCount);

    return AppBar(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: colors.surface,
      centerTitle: false,
      title: Text(
        'Activity', 
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          fontSize: 22,
          color: colors.onSurface,
        ),
      ),
      actions: [
        if (unread > 0)
          TextButton(
            onPressed: () => context.read<NotificationProvider>().markAllAsRead(),
            child: Text(
              'Mark all read', 
              style: TextStyle(color: colors.primary),
            ),
          ),
        PopupMenuButton(
          icon: Icon(Icons.more_horiz, color: colors.onSurface),
          color: colors.surface,
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: () => context.read<NotificationProvider>().clearAll(),
              child: Text(
                'Clear all',
                style: TextStyle(color: colors.onSurface),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class NotificationTile extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;
  final ColorScheme colors;

  const NotificationTile({
    super.key, 
    required this.item, 
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: item.isRead ? Colors.transparent : colors.primary.withOpacity(0.04),
          border: Border(
            bottom: BorderSide(color: colors.outline),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(item.userImage),
              onBackgroundImageError: (_, __) => Icon(Icons.person, color: colors.onSurface),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.plusJakartaSans(
                        color: colors.onSurface, 
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: item.title, 
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: ' '),
                        TextSpan(
                          text: item.message, 
                          style: TextStyle(color: colors.onSurface.withOpacity(0.8)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.timeAgo, 
                    style: TextStyle(
                      fontSize: 12, 
                      color: colors.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            if (!item.isRead)
              CircleAvatar(
                radius: 4, 
                backgroundColor: colors.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final String date;
  final ColorScheme colors;
  
  const _DateHeader({
    required this.date,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        date.toUpperCase(), 
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11, 
          letterSpacing: 1.2, 
          fontWeight: FontWeight.bold, 
          color: colors.onSurface.withOpacity(0.5),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final NotificationProvider provider;
  final ColorScheme colors;
  
  const _ErrorView({
    required this.provider,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline, 
              size: 48, 
              color: colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              provider.errorMessage ?? 'Something went wrong',
              style: TextStyle(color: colors.onSurface),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => provider.loadNotifications(), 
              child: Text(
                'Retry',
                style: TextStyle(color: colors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationEmptyState extends StatelessWidget {
  final ColorScheme colors;
  
  const NotificationEmptyState({
    super.key,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded, 
              size: 64, 
              color: colors.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'All caught up!', 
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16, 
                color: colors.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}