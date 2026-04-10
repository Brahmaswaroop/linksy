import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_force_directed_graph/flutter_force_directed_graph.dart' as fdg;
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import '../../core/database/database_provider.dart';

// ── Models ─────────────────────────────────────────────────────────────

class GraphNode {
  final int id;
  final String name;
  final bool isUser;
  final String category;
  final bool isWeak;
  final bool isGroup;
  final int memberCount;

  GraphNode({
    required this.id,
    required this.name,
    this.isUser = false,
    this.category = '',
    this.isWeak = false,
    this.isGroup = false,
    this.memberCount = 1,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GraphNode && runtimeType == other.runtimeType && id == other.id && isGroup == other.isGroup;

  @override
  int get hashCode => Object.hash(id, isGroup);
}

class GraphEdge {
  final int sourceId;
  final int targetId;
  final String? relationLabel;
  final bool isWeak;

  GraphEdge(
    this.sourceId,
    this.targetId, {
    this.relationLabel,
    this.isWeak = false,
  });
}

class GraphData {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  GraphData(this.nodes, this.edges);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GraphData &&
          runtimeType == other.runtimeType &&
          nodes.length == other.nodes.length &&
          edges.length == other.edges.length;

  @override
  int get hashCode => Object.hash(nodes.length, edges.length);
}

// ── Provider ───────────────────────────────────────────────────────────

final graphDataProvider = FutureProvider.family<GraphData, int>((ref, focusedPersonId) async {
  final db = ref.read(databaseProvider);

  final nodes = <GraphNode>[];
  final edges = <GraphEdge>[];
  final Set<int> addedNodeIds = {};

  void addNode(GraphNode node) {
    if (node.isGroup || !addedNodeIds.contains(node.id)) {
      nodes.add(node);
      if (!node.isGroup) addedNodeIds.add(node.id);
    }
  }

  final allPeople = await db.select(db.people).get();
  final allConnections = await db.select(db.personConnections).get();

  if (focusedPersonId == 0) {
    // ── "You" View With Smart Grouping ──────────────────────────────────
    addNode(GraphNode(id: 0, name: 'You', isUser: true));

    final categoryMembers = <String, List<int>>{};
    for (final person in allPeople) {
      if (!person.isWeak) {
        categoryMembers.putIfAbsent(person.category, () => []).add(person.id);
      }
    }

    // Add individuals and groups
    for (final entry in categoryMembers.entries) {
      final category = entry.key;
      final memberIds = entry.value;

      if (memberIds.length > 8) {
        addNode(GraphNode(
          id: -category.hashCode,
          name: category,
          category: category,
          isGroup: true,
          memberCount: memberIds.length,
        ));
        edges.add(GraphEdge(0, -category.hashCode, relationLabel: category));
      } else {
        for (final id in memberIds) {
          final person = allPeople.firstWhere((p) => p.id == id);
          addNode(GraphNode(id: person.id, name: person.name, category: person.category));
          edges.add(GraphEdge(0, person.id, relationLabel: person.category));
        }
      }
    }

    // Add weak connections linking to their intermediates
    for (final person in allPeople.where((p) => p.isWeak)) {
      final conns = allConnections.where((c) => c.personId == person.id || c.connectedPersonId == person.id);
      final otherId = conns.isEmpty ? 0 : (conns.first.personId == person.id ? conns.first.connectedPersonId : conns.first.personId);
      
      addNode(GraphNode(id: person.id, name: person.name, category: person.category, isWeak: true));
      edges.add(GraphEdge(otherId, person.id, relationLabel: conns.isEmpty ? '?' : conns.first.relationLabel, isWeak: true));
    }
  } else {
    // ── Focused Person View ─────────────────────────────────────────────
    final person = allPeople.firstWhere((p) => p.id == focusedPersonId, orElse: () => allPeople.first);
    addNode(GraphNode(id: person.id, name: person.name, category: person.category));
    addNode(GraphNode(id: 0, name: 'You', isUser: true));
    edges.add(GraphEdge(0, focusedPersonId, relationLabel: person.category));

    final connections = allConnections.where((c) => c.personId == focusedPersonId || c.connectedPersonId == focusedPersonId);
    for (final c in connections) {
      final otherId = c.personId == focusedPersonId ? c.connectedPersonId : c.personId;
      final other = allPeople.where((p) => p.id == otherId).firstOrNull;
      if (other != null) {
        addNode(GraphNode(id: other.id, name: other.name, category: other.category, isWeak: c.isWeak));
        edges.add(GraphEdge(focusedPersonId, other.id, relationLabel: c.relationLabel, isWeak: c.isWeak));
      }
    }
  }

  return GraphData(nodes, edges);
});

// ── Screen Layer ───────────────────────────────────────────────────────

class GraphScreen extends ConsumerStatefulWidget {
  const GraphScreen({super.key});

  @override
  ConsumerState<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends ConsumerState<GraphScreen> {
  int _currentFocusId = 0;
  String _selectedCategory = 'All';
  final Set<String> _expandedCategories = {};

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(graphDataProvider(_currentFocusId));
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Network Map'),
        actions: [
          if (_currentFocusId != 0) ...[
            TextButton.icon(
              icon: const Icon(LucideIcons.user),
              label: const Text('Profile'),
              onPressed: () => context.push('/people/$_currentFocusId'),
            ),
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: () => setState(() => _currentFocusId = 0),
              tooltip: 'Center on Me',
            ),
          ],
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(graphDataProvider(_currentFocusId)),
          ),
        ],
      ),
      body: Stack(
        children: [
          asyncData.when(
            data: (data) => _GraphLayoutEngine(
              data: data,
              focusId: _currentFocusId,
              expandedCategories: _expandedCategories,
              onNodeTap: (id) => setState(() => _currentFocusId = id),
              onGroupTap: (category) {
                setState(() {
                  if (_expandedCategories.contains(category)) {
                    _expandedCategories.remove(category);
                  } else {
                    _expandedCategories.add(category);
                  }
                });
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error loading graph: $err')),
          ),
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: _CategoryFilter(
              selected: _selectedCategory,
              onChanged: (cat) => setState(() => _selectedCategory = cat),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Layout Engine (FDG) ────────────────────────────────────────────────

class _GraphLayoutEngine extends StatefulWidget {
  final GraphData data;
  final int focusId;
  final Set<String> expandedCategories;
  final ValueChanged<int> onNodeTap;
  final ValueChanged<String> onGroupTap;

  const _GraphLayoutEngine({
    required this.data,
    required this.focusId,
    required this.expandedCategories,
    required this.onNodeTap,
    required this.onGroupTap,
  });

  @override
  State<_GraphLayoutEngine> createState() => _GraphLayoutEngineState();
}

class _GraphLayoutEngineState extends State<_GraphLayoutEngine> {
  late final fdg.ForceDirectedGraphController<GraphNode> _controller;
  final Map<String, GraphEdge> _edgeLookup = {};
  final Map<int, fdg.Node<GraphNode>> _fdgNodeMap = {};

  @override
  void initState() {
    super.initState();
    _controller = fdg.ForceDirectedGraphController<GraphNode>();
    _initController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_GraphLayoutEngine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data || oldWidget.expandedCategories != widget.expandedCategories) {
      _initController();
    }
  }

  void _initController() {
    final visibleNodes = <GraphNode>[];
    final visibleEdges = <GraphEdge>[];
    final Map<String, int> groupNodeIds = {};
    _edgeLookup.clear();
    _fdgNodeMap.clear();

    // Grouping and Filtering logic logic
    for (final node in widget.data.nodes) {
      if (node.isGroup) {
        groupNodeIds[node.category] = node.id;
        if (!widget.expandedCategories.contains(node.category)) {
          visibleNodes.add(node);
        }
      }
    }

    for (final node in widget.data.nodes) {
      if (!node.isGroup && node.id != 0 && node.id != widget.focusId) {
        if (!node.isWeak && groupNodeIds.containsKey(node.category) && !widget.expandedCategories.contains(node.category)) {
          continue; // Hidden in group
        }
        visibleNodes.add(node);
      } else if (node.id == 0 || node.id == widget.focusId) {
        visibleNodes.add(node);
      }
    }

    for (final edge in widget.data.edges) {
      int s = edge.sourceId;
      int t = edge.targetId;

      // Handle group redirection
      final sNode = widget.data.nodes.firstWhere((n) => n.id == s, orElse: () => GraphNode(id: -1, name: '?'));
      final tNode = widget.data.nodes.firstWhere((n) => n.id == t, orElse: () => GraphNode(id: -1, name: '?'));

      if (!sNode.isGroup && sNode.id != 0 && groupNodeIds.containsKey(sNode.category) && !widget.expandedCategories.contains(sNode.category)) {
        s = groupNodeIds[sNode.category]!;
      }
      if (!tNode.isGroup && tNode.id != 0 && groupNodeIds.containsKey(tNode.category) && !widget.expandedCategories.contains(tNode.category)) {
        t = groupNodeIds[tNode.category]!;
      }

      if (s != t) {
        final mappedEdge = GraphEdge(s, t, relationLabel: edge.relationLabel, isWeak: edge.isWeak);
        visibleEdges.add(mappedEdge);
        _edgeLookup['$s-$t'] = mappedEdge;
      }
    }

    final graph = fdg.ForceDirectedGraph<GraphNode>(
      config: const fdg.GraphConfig(
        repulsion: 300.0,
        length: 140.0,
        repulsionRange: 600.0,
        damping: 0.5, // Faster settling
      ),
    );

    for (final n in visibleNodes) {
      final node = fdg.Node<GraphNode>(n);
      graph.addNode(node);
      _fdgNodeMap[n.id] = node;
    }

    for (final e in visibleEdges) {
      final nodeA = _fdgNodeMap[e.sourceId];
      final nodeB = _fdgNodeMap[e.targetId];
      if (nodeA != null && nodeB != null) {
        graph.addEdge(fdg.Edge(nodeA, nodeB));
      }
    }

    _controller.graph = graph;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleUpdate: (details) {
        // Implement panning manually since scaling is handled by the widget
        if (details.scale == 1.0) {
          _controller.locateToPosition(
            -details.focalPointDelta.dx / _controller.scale,
            details.focalPointDelta.dy / _controller.scale,
          );
        }
      },
      child: fdg.ForceDirectedGraphWidget<GraphNode>(
        controller: _controller,
        nodesBuilder: (context, node) => _NodeWidget(
          node: node,
          isFocused: node.id == widget.focusId,
          isExpanded: node.isGroup && widget.expandedCategories.contains(node.category),
          onTap: node.isGroup ? () => widget.onGroupTap(node.category) : () => widget.onNodeTap(node.id),
        ),
        edgesBuilder: (context, a, b, distance) {
          final edge = _edgeLookup['${a.id}-${b.id}'] ?? _edgeLookup['${b.id}-${a.id}'];
          if (edge == null) return const SizedBox.shrink();
          return _EdgeLine(
            isWeak: edge.isWeak,
            label: edge.relationLabel,
            distance: distance,
          );
        },
      ),
    );
  }
}

// ─── Edge Widget ────────────────────────────────────────────────────────────
//
// The library places edge widgets at the midpoint of the two nodes on an
// *unconstrained* canvas. We must explicitly give the widget a size or the
// CustomPaint will default to Size.zero and be invisible.
//
// Size = (distance, distance) guarantees the bounding box is always big enough
// for any angle. The line is drawn relative to the widget's own center,
// which the library maps to the geometric midpoint of the edge.

class _EdgeLine extends StatelessWidget {
  final bool isWeak;
  final String? label;
  final double distance;

  const _EdgeLine({required this.isWeak, this.label, required this.distance});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sz = distance.clamp(1.0, 2000.0);
    return SizedBox(
      width: sz,
      height: sz,
      child: CustomPaint(
        painter: _EdgePainter(
          color: cs.outlineVariant.withValues(alpha: isWeak ? 0.35 : 0.7),
          strokeWidth: isWeak ? 1.5 : 2.5,
          isDashed: isWeak,
          label: label,
          labelColor: cs.secondary,
        ),
      ),
    );
  }
}

class _EdgePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final bool isDashed;
  final String? label;
  final Color labelColor;

  const _EdgePainter({
    required this.color,
    required this.strokeWidth,
    required this.isDashed,
    required this.label,
    required this.labelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final end = size.bottomRight(Offset.zero);

    if (isDashed) {
      _drawDashedLine(canvas, Offset.zero, end, paint);
    } else {
      canvas.drawLine(Offset.zero, end, paint);
    }

    if (label != null && label!.isNotEmpty) {
      final mid = Offset(size.width / 2, size.height / 2);
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final rect = Rect.fromCenter(center: mid, width: tp.width + 10, height: tp.height + 4);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        Paint()..color = labelColor.withValues(alpha: isDashed ? 0.4 : 0.8),
      );
      tp.paint(canvas, mid - Offset(tp.width / 2, tp.height / 2));
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashLen = 8.0;
    const gapLen = 5.0;
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final len = (end - start).distance;
    if (len == 0) return;
    final ux = dx / len;
    final uy = dy / len;
    double drawn = 0;
    bool drawing = true;
    while (drawn < len) {
      final seg = drawing ? dashLen : gapLen;
      final next = (drawn + seg).clamp(0.0, len);
      if (drawing) {
        canvas.drawLine(
          Offset(start.dx + ux * drawn, start.dy + uy * drawn),
          Offset(start.dx + ux * next, start.dy + uy * next),
          paint,
        );
      }
      drawn = next;
      drawing = !drawing;
    }
  }

  @override
  bool shouldRepaint(covariant _EdgePainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

class _CategoryFilter extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _CategoryFilter({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const cats = ['All', 'Friend', 'Family', 'Colleague', 'Other'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: cats.map((c) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(c),
              selected: selected == c,
              onSelected: (s) => s ? onChanged(c) : null,
              visualDensity: VisualDensity.compact,
            ),
          )).toList(),
        ),
      ),
    );
  }
}

class _NodeWidget extends StatelessWidget {
  final GraphNode node;
  final bool isFocused;
  final bool isExpanded;
  final VoidCallback onTap;

  const _NodeWidget({
    required this.node,
    required this.isFocused,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = node.isUser ? cs.primary : colorForCategory(node.category);
    final circleSize = node.isGroup ? 72.0 : (isFocused ? 64.0 : (node.isUser ? 56.0 : 48.0));

    return GestureDetector(
      onTap: onTap,
      onDoubleTap: (node.id == 0 || node.isGroup) ? null : () => context.push('/people/${node.id}'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(
                color: isFocused ? cs.onSurface : (node.isGroup ? cs.outlineVariant : Colors.white),
                width: isFocused ? 3.0 : (node.isGroup ? 4.0 : 2.0),
              ),
              boxShadow: isFocused
                  ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 12, spreadRadius: 4)]
                  : [],
            ),
            child: Center(
              child: node.isGroup
                  ? Icon(isExpanded ? LucideIcons.chevronUp : LucideIcons.users, color: Colors.white, size: 24)
                  : Text(
                      node.name.isNotEmpty ? node.name[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            node.isGroup ? '${node.name} (${node.memberCount})' : node.name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isFocused ? FontWeight.bold : FontWeight.w500,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
