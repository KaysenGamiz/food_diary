import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../models/day_entry.dart';

class WeeklyStatusBanner extends StatefulWidget {
  final List<DayEntry> days;

  const WeeklyStatusBanner({super.key, required this.days});

  @override
  State<WeeklyStatusBanner> createState() => _WeeklyStatusBannerState();
}

class _WeeklyStatusBannerState extends State<WeeklyStatusBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  bool _isVisible = true;
  bool _isExiting = false; // Controla si estamos en fase de salida

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    );

    // Animación de ENTRADA (0% a 10% del tiempo total)
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.1, curve: Curves.easeOutBack),
          ),
        );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.1, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _fadeOutAndClose();
      }
    });
  }

  // Método para una salida suave
  void _fadeOutAndClose() async {
    if (_isExiting) return;
    setState(() => _isExiting = true);

    // Esperamos a que el widget se desvanezca antes de quitarlo del árbol
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() => _isVisible = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _speedUp() {
    HapticFeedback.lightImpact();
    // Aceleramos el controlador para que llegue rápido al final y dispare _fadeOutAndClose
    _controller.duration = const Duration(milliseconds: 500);
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible || widget.days.isEmpty) return const SizedBox.shrink();

    final last7Days = widget.days.take(7).toList();
    final reactions = last7Days.where((d) => d.hadReaction == true).length;
    final highEnergyDays = last7Days
        .where((d) => (d.energyLevel ?? 0) >= 4)
        .length;

    String message = "Tu energía esta semana es estable.";
    IconData icon = Icons.insights;
    Color statusColor = AppTheme.primary;

    if (reactions > 2) {
      message = "Has tenido malestar en $reactions días. ¡Revisa tus tags!";
      icon = Icons.warning_amber_rounded;
      statusColor = AppTheme.danger;
    } else if (highEnergyDays >= 4) {
      message = "¡Genial! Tienes energía alta esta semana.";
      icon = Icons.bolt;
      statusColor = Colors.orange;
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: _isExiting ? 0.0 : 1.0, // Se desvanece al salir
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 400),
        offset: _isExiting
            ? const Offset(0, -0.5)
            : Offset.zero, // Sube un poco al salir
        curve: Curves.easeInBack,
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: GestureDetector(
              onLongPressStart: (_) => _speedUp(),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          statusColor,
                          Color.lerp(statusColor, Colors.black, 0.6)!,
                        ],
                        stops: [1.0 - _controller.value, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(icon, color: Colors.white, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "ESTADO SEMANAL",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  message,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
