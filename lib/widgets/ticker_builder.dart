import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Vuelve a dibujar el contenido en cada fotograma mientras esté montado.
class TickerBuilder extends StatefulWidget {
  const TickerBuilder({super.key, required this.builder});
  final WidgetBuilder builder;

  @override
  State<TickerBuilder> createState() => _TickerBuilderState();
}

class _TickerBuilderState extends State<TickerBuilder>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      if (mounted) setState(() {});
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}
