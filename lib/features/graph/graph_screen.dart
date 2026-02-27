import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database_provider.dart';

// ── Models ─────────────────────────────────────────────────────────────

class GraphNode {
  final int id;
  final String name;
  final bool isUser;
  final String category; // 'Friend', 'Family', etc.
  Offset position;
  Offset velocity = Offset.zero;

  GraphNode({
    required this.id,
    required this.name,
    this.isUser = false,
    this.category = '',
    this.position = Offset.zero,
  });
}

class GraphEdge {
  final int sourceId;
  final int targetId;

  GraphEdge(this.sourceId, this.targetId);
}

class GraphData {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  GraphData(this.nodes, this.edges);
}

// ── Provider ───────────────────────────────────────────────────────────

final graphDataProvider = FutureProvider<GraphData>((ref) async {
  final db = ref.read(databaseProvider);
  final allPeople = await db.select(db.people).get();
  final allConnections = await db.select(db.personConnections).get();

  final nodes = <GraphNode>[
    // The central 'User' node (ID: 0 to signify self)
    GraphNode(id: 0, name: 'You', isUser: true),
  ];

  final edges = <GraphEdge>[];

  final random = math.Random();
  for (final person in allPeople) {
    // Initial random scatter around center
    final angle = random.nextDouble() * 2 * math.pi;
    final r = random.nextDouble() * 100 + 50;

    nodes.add(
      GraphNode(
        id: person.id,
        name: person.name,
        category: person.category,
        position: Offset(math.cos(angle) * r, math.sin(angle) * r),
      ),
    );

    // Link everyone to 'You'
    edges.add(GraphEdge(0, person.id));
  }

  // Add all internal connections
  for (final conn in allConnections) {
    edges.add(GraphEdge(conn.personId, conn.connectedPersonId));
  }

  return GraphData(nodes, edges);
});

// ── Screen Layer ───────────────────────────────────────────────────────

class GraphScreen extends ConsumerStatefulWidget {
  const GraphScreen({super.key});

  @override
  ConsumerState<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends ConsumerState<GraphScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  GraphData? _fullGraphData;
  GraphData? _filteredGraphData;

  String _selectedCategory = 'All';
  static const _categories = ['All', 'Friend', 'Family', 'Colleague', 'Other'];

  // Force Directed Graph constants
  static const double kSpringLength = 100.0;
  static const double kSpringStiffness = 0.05;
  static const double kRepulsion = 4000.0;
  static const double kDamping = 0.85;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(_tickSimulation);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    if (_fullGraphData == null) return;

    if (_selectedCategory == 'All') {
      setState(() {
        _filteredGraphData = _fullGraphData;
      });
      _animController.forward(from: 0.0);
      return;
    }

    final matchingNodes = _fullGraphData!.nodes
        .where((n) => n.category == _selectedCategory)
        .map((n) => n.id)
        .toSet();

    final connectedNodeIds = <int>{};
    for (final edge in _fullGraphData!.edges) {
      if (matchingNodes.contains(edge.sourceId) && edge.targetId != 0) {
        connectedNodeIds.add(edge.targetId);
      }
      if (matchingNodes.contains(edge.targetId) && edge.sourceId != 0) {
        connectedNodeIds.add(edge.sourceId);
      }
    }

    final allowedNodeIds = {0, ...matchingNodes, ...connectedNodeIds};

    final filteredNodes = _fullGraphData!.nodes
        .where((n) => allowedNodeIds.contains(n.id))
        .toList();
    final filteredEdges = _fullGraphData!.edges
        .where(
          (e) =>
              allowedNodeIds.contains(e.sourceId) &&
              allowedNodeIds.contains(e.targetId),
        )
        .toList();

    setState(() {
      _filteredGraphData = GraphData(filteredNodes, filteredEdges);
    });
    _animController.forward(from: 0.0);
  }

  void _tickSimulation() {
    if (_filteredGraphData == null || !mounted) return;
    final nodes = _filteredGraphData!.nodes;
    final edges = _filteredGraphData!.edges;

    // Center node is pinned
    final centerNode = nodes.firstWhere((n) => n.id == 0);
    centerNode.position = Offset.zero;
    centerNode.velocity = Offset.zero;

    // Apply Repulsion between all nodes
    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        final n1 = nodes[i];
        final n2 = nodes[j];
        final dx = n1.position.dx - n2.position.dx;
        final dy = n1.position.dy - n2.position.dy;
        final distSq = dx * dx + dy * dy;

        if (distSq > 0.1) {
          final dist = math.sqrt(distSq);
          final f = kRepulsion / distSq;
          final fx = (dx / dist) * f;
          final fy = (dy / dist) * f;

          if (!n1.isUser) {
            n1.velocity += Offset(fx, fy);
          }
          if (!n2.isUser) {
            n2.velocity -= Offset(fx, fy);
          }
        }
      }
    }

    // Apply Spring Attraction along edges
    for (final edge in edges) {
      final source = nodes.firstWhere(
        (n) => n.id == edge.sourceId,
        orElse: () => nodes.first,
      );
      final target = nodes.firstWhere(
        (n) => n.id == edge.targetId,
        orElse: () => nodes.first,
      );
      if (source == target) continue;

      final dx = target.position.dx - source.position.dx;
      final dy = target.position.dy - source.position.dy;
      final dist = math.sqrt(dx * dx + dy * dy);

      if (dist > 0) {
        final f = (dist - kSpringLength) * kSpringStiffness;
        final fx = (dx / dist) * f;
        final fy = (dy / dist) * f;

        if (!source.isUser) {
          source.velocity += Offset(fx, fy);
        }
        if (!target.isUser) {
          target.velocity -= Offset(fx, fy);
        }
      }
    }

    // Update positions and apply damping
    for (final node in nodes) {
      if (node.isUser) continue; // Keep pinned
      node.position += node.velocity;
      node.velocity *= kDamping;

      // Soft bounding box constraint to keep nodes in view
      const limit = 250.0;
      if (node.position.dx > limit) node.velocity -= const Offset(5, 0);
      if (node.position.dx < -limit) node.velocity += const Offset(5, 0);
      if (node.position.dy > limit) node.velocity -= const Offset(0, 5);
      if (node.position.dy < -limit) node.velocity += const Offset(0, 5);
    }

    setState(() {}); // Trigger repaint
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(graphDataProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Graph'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(graphDataProvider);
              _fullGraphData = null; // reset
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _categories.map((cat) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: _selectedCategory == cat,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = cat);
                        _applyFilter();
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: asyncData.when(
        data: (data) {
          if (_fullGraphData != data) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _fullGraphData = data;
              _applyFilter();
            });
          }

          if (data.nodes.length == 1) {
            return Center(
              child: Text(
                'No connections yet.\nAdd people to see your network!',
                textAlign: TextAlign.center,
                style: tt.bodyLarge?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
              ),
            );
          }

          if (_filteredGraphData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(double.infinity),
            minScale: 0.1,
            maxScale: 4.0,
            child: Center(
              child: SizedBox(
                width: 1000,
                height: 1000,
                child: CustomPaint(
                  painter: _NetworkPainter(_filteredGraphData!, context),
                  size: const Size(1000, 1000),
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

// ── Painter ─────────────────────────────────────────────────────────────

class _NetworkPainter extends CustomPainter {
  final GraphData data;
  final BuildContext context;

  _NetworkPainter(this.data, this.context);

  @override
  void paint(Canvas canvas, Size size) {
    final cs = Theme.of(context).colorScheme;
    final center = Offset(size.width / 2, size.height / 2);

    final edgePaint = Paint()
      ..color = cs.outlineVariant.withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw Edges
    for (final edge in data.edges) {
      final source = data.nodes.where((n) => n.id == edge.sourceId).firstOrNull;
      final target = data.nodes.where((n) => n.id == edge.targetId).firstOrNull;

      if (source != null && target != null) {
        canvas.drawLine(
          center + source.position,
          center + target.position,
          edgePaint,
        );
      }
    }

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Draw Nodes
    for (final node in data.nodes) {
      final pos = center + node.position;

      // Draw shadow
      canvas.drawCircle(
        pos + const Offset(0, 2),
        node.isUser ? 30 : 20,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.1)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );

      // Node background
      Color nodeColor;
      if (node.isUser) {
        nodeColor = cs.primary;
      } else {
        switch (node.category) {
          case 'Family':
            nodeColor = Colors.purple.shade400;
            break;
          case 'Friend':
            nodeColor = Colors.blue.shade400;
            break;
          case 'Colleague':
            nodeColor = Colors.teal.shade400;
            break;
          default:
            nodeColor = cs.secondary;
        }
      }

      canvas.drawCircle(
        pos,
        node.isUser ? 30 : 20,
        Paint()
          ..color = nodeColor
          ..style = PaintingStyle.fill,
      );

      // Node border
      canvas.drawCircle(
        pos,
        node.isUser ? 30 : 20,
        Paint()
          ..color = cs.surface
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );

      // Draw initial
      textPainter.text = TextSpan(
        text: node.name.isNotEmpty ? node.name[0].toUpperCase() : '?',
        style: TextStyle(
          color: Colors.white,
          fontSize: node.isUser ? 24 : 16,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        pos - Offset(textPainter.width / 2, textPainter.height / 2),
      );

      // Draw label below
      textPainter.text = TextSpan(
        text: node.name,
        style: TextStyle(
          color: cs.onSurface,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        pos + Offset(-textPainter.width / 2, (node.isUser ? 35 : 25)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NetworkPainter oldDelegate) => true;
}
