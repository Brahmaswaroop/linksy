import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import '../../core/database/database_provider.dart';

// ── Models ─────────────────────────────────────────────────────────────

class GraphNode {
  final int id;
  final String name;
  final bool isUser;
  final String category; // 'Friend', 'Family', etc.
  final bool isWeak;

  GraphNode({
    required this.id,
    required this.name,
    this.isUser = false,
    this.category = '',
    this.isWeak = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GraphNode && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
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
}

// ── Provider ───────────────────────────────────────────────────────────

final graphDataProvider = FutureProvider.family<GraphData, int>((
  ref,
  focusedPersonId,
) async {
  final db = ref.read(databaseProvider);

  final nodes = <GraphNode>[];
  final edges = <GraphEdge>[];

  if (focusedPersonId == 0) {
    // ── "You" view ─────────────────────────────────────────────────────
    nodes.add(GraphNode(id: 0, name: 'You', isUser: true));

    final allPeople = await db.select(db.people).get();
    final allConnections = await db.select(db.personConnections).get();

    // Build a lookup: personId -> list of (connectedPersonId, isWeak)
    // For each connection, determine which end is weak.
    // A person is a weak node if ALL their connections to "you" are weak.
    // We treat a connection as linking two people. If isWeak is true on
    // a connection, we anchor the weak person to their strong via-person.

    // Step 1: index all strong people ids (connected with at least one
    //   non-weak connection). Everyone is strong unless only weakly linked.
    final Set<int> allPersonIds = allPeople.map((p) => p.id).toSet();

    // For each person – collect all their connections and find if they
    // are exclusively weak-linked (no direct strong link to any strong node).
    // For simplicity: a person is rendered as a WEAK node if every connection
    // they participate in has isWeak == true.
    final Map<int, bool> personIsWeak = {};
    for (final p in allPeople) {
      final relatedConns = allConnections.where(
        (c) => c.personId == p.id || c.connectedPersonId == p.id,
      );
      if (relatedConns.isEmpty) {
        personIsWeak[p.id] = false;
      } else {
        personIsWeak[p.id] = relatedConns.every((c) => c.isWeak);
      }
    }

    // Step 2: Add all people as nodes.
    for (final person in allPeople) {
      final weak = personIsWeak[person.id] ?? false;
      nodes.add(
        GraphNode(
          id: person.id,
          name: person.name,
          category: person.category,
          isWeak: weak,
        ),
      );
    }

    // Step 3: Add edges.
    // Strong people → link to "You".
    // Weak people → link to their closest strong via-person.
    final Set<int> edgesDone = {};

    for (final person in allPeople) {
      if (edgesDone.contains(person.id)) continue;
      edgesDone.add(person.id);

      final weak = personIsWeak[person.id] ?? false;
      if (!weak) {
        // Strong person: edge from You -> person
        edges.add(
          GraphEdge(0, person.id, relationLabel: person.category, isWeak: false),
        );
      } else {
        // Weak person: find the first strong via-person in connections
        final conns = allConnections.where(
          (c) => c.personId == person.id || c.connectedPersonId == person.id,
        );
        int? viaId;
        String label = person.category;
        for (final c in conns) {
          final otherId =
              c.personId == person.id ? c.connectedPersonId : c.personId;
          final otherIsWeak = personIsWeak[otherId] ?? true;
          if (!otherIsWeak && allPersonIds.contains(otherId)) {
            viaId = otherId;
            label = c.relationLabel;
            break;
          }
        }
        // Fall back to "You" if no strong via-person found
        edges.add(
          GraphEdge(
            viaId ?? 0,
            person.id,
            relationLabel: label,
            isWeak: true,
          ),
        );
      }
    }
  } else {
    // ── Focused on a specific person ────────────────────────────────────
    final person = await (db.select(
      db.people,
    )..where((tbl) => tbl.id.equals(focusedPersonId))).getSingleOrNull();
    if (person != null) {
      nodes.add(
        GraphNode(id: person.id, name: person.name, category: person.category),
      );

      // Implicitly connected to "You"
      nodes.add(GraphNode(id: 0, name: 'You', isUser: true));
      edges.add(GraphEdge(0, focusedPersonId, relationLabel: person.category));

      final connections1 = await (db.select(
        db.personConnections,
      )..where((tbl) => tbl.personId.equals(focusedPersonId))).get();
      final connections2 = await (db.select(
        db.personConnections,
      )..where((tbl) => tbl.connectedPersonId.equals(focusedPersonId))).get();

      final connectedIds = <int>{};
      final edgeMap = <int, (String, bool)>{};

      for (final c in connections1) {
        connectedIds.add(c.connectedPersonId);
        edgeMap[c.connectedPersonId] = (c.relationLabel, c.isWeak);
      }

      for (final c in connections2) {
        connectedIds.add(c.personId);
        if (!edgeMap.containsKey(c.personId)) {
          edgeMap[c.personId] = ('${c.relationLabel} (Theirs)', c.isWeak);
        }
      }

      if (connectedIds.isNotEmpty) {
        final connectedPeople = await (db.select(
          db.people,
        )..where((tbl) => tbl.id.isIn(connectedIds))).get();
        for (final p in connectedPeople) {
          final (label, weak) = edgeMap[p.id] ?? (p.category, false);
          nodes.add(
            GraphNode(
              id: p.id,
              name: p.name,
              category: p.category,
              isWeak: weak,
            ),
          );
          edges.add(
            GraphEdge(focusedPersonId, p.id, relationLabel: label, isWeak: weak),
          );
        }
      }
    } else {
      nodes.add(GraphNode(id: 0, name: 'You', isUser: true));
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
  static const _categories = ['All', 'Friend', 'Family', 'Colleague', 'Other'];

  static const double kGraphCenterBound = 2000.0;
  final TransformationController _transformController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerView();
    });
  }

  void _centerView() {
    final size = MediaQuery.of(context).size;
    _transformController.value = Matrix4.identity()
      ..translateByDouble(
        -(kGraphCenterBound / 2) + (size.width / 2),
        -(kGraphCenterBound / 2) + (size.height / 2) - 100,
        0.0,
        1.0,
      );
  }

  GraphData? _filteredGraphData(GraphData original) {
    if (_selectedCategory == 'All') return original;

    final matchingNodes = original.nodes
        .where(
          (n) =>
              n.category == _selectedCategory ||
              n.id == 0 ||
              n.id == _currentFocusId,
        )
        .map((n) => n.id)
        .toSet();

    final filteredNodes = original.nodes
        .where((n) => matchingNodes.contains(n.id))
        .toList();

    final filteredEdges = original.edges
        .where(
          (e) =>
              matchingNodes.contains(e.sourceId) &&
              matchingNodes.contains(e.targetId),
        )
        .toList();

    return GraphData(filteredNodes, filteredEdges);
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(graphDataProvider(_currentFocusId));
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Graph'),
        actions: [
          if (_currentFocusId != 0) ...[
            TextButton.icon(
              icon: const Icon(LucideIcons.user),
              label: const Text('View Profile'),
              onPressed: () => context.push('/people/$_currentFocusId'),
            ),
            TextButton.icon(
              icon: const Icon(Icons.my_location),
              label: const Text('Back to Me'),
              onPressed: () {
                setState(() => _currentFocusId = 0);
                _centerView();
              },
            ),
          ],
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(graphDataProvider(_currentFocusId));
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
          final filteredData = _filteredGraphData(data);

          if (data.nodes.length <= 1 && _currentFocusId == 0) {
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

          if (filteredData == null || filteredData.nodes.isEmpty) {
            return const Center(
              child: Text('No connections matching this category.'),
            );
          }

          return InteractiveViewer(
            transformationController: _transformController,
            boundaryMargin: const EdgeInsets.all(kGraphCenterBound),
            minScale: 0.1,
            maxScale: 4.0,
            constrained: false,
            child: SizedBox(
              width: kGraphCenterBound,
              height: kGraphCenterBound,
              child: _GraphLayoutEngine(
                data: filteredData,
                focusId: _currentFocusId,
                onNodeTap: (id) {
                  setState(() {
                    _currentFocusId = id;
                  });
                },
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

// ── Layout Engine ────────────────────────────────────────────────────────

class _GraphLayoutEngine extends StatelessWidget {
  final GraphData data;
  final int focusId;
  final ValueChanged<int> onNodeTap;

  const _GraphLayoutEngine({
    required this.data,
    required this.focusId,
    required this.onNodeTap,
  });

  @override
  Widget build(BuildContext context) {
    const centerOffset = Offset(
      _GraphScreenState.kGraphCenterBound / 2,
      _GraphScreenState.kGraphCenterBound / 2,
    );

    final nodePositions = <int, Offset>{};

    final focusNode = data.nodes.where((n) => n.id == focusId).firstOrNull;
    if (focusNode != null) {
      nodePositions[focusNode.id] = centerOffset;

      // Separate strong and weak nodes
      final strongNodes =
          data.nodes.where((n) => n.id != focusId && !n.isWeak).toList();
      final weakNodes =
          data.nodes.where((n) => n.id != focusId && n.isWeak).toList();

      // Place strong nodes in first ring
      final strongCount = strongNodes.length;
      final outerRadius = 200.0 + (strongCount * 6).clamp(0, 400).toDouble();
      for (int i = 0; i < strongCount; i++) {
        final angle = (i * 2 * math.pi) / strongCount;
        final x = centerOffset.dx + outerRadius * math.cos(angle);
        final y = centerOffset.dy + outerRadius * math.sin(angle);
        nodePositions[strongNodes[i].id] = Offset(x, y);
      }

      // Place weak nodes orbiting their via-person (edge source)
      // Group weak nodes by their parent
      final Map<int, List<GraphNode>> weakByParent = {};
      for (final wn in weakNodes) {
        // Find the edge whose target is this weak node
        final edge = data.edges
            .where((e) => e.targetId == wn.id && e.isWeak)
            .firstOrNull;
        final parentId = edge?.sourceId ?? focusId;
        weakByParent.putIfAbsent(parentId, () => []).add(wn);
      }

      for (final entry in weakByParent.entries) {
        final parentId = entry.key;
        final children = entry.value;
        final parentPos = nodePositions[parentId] ?? centerOffset;
        const innerRadius = 90.0;
        // Angle offset so children spread around the parent away from center
        final baseAngle = math.atan2(
          parentPos.dy - centerOffset.dy,
          parentPos.dx - centerOffset.dx,
        );
        final spread = math.pi * 0.7;
        for (int i = 0; i < children.length; i++) {
          final t = children.length == 1
              ? 0.0
              : (i / (children.length - 1)) - 0.5;
          final angle = baseAngle + t * spread;
          final x = parentPos.dx + innerRadius * math.cos(angle);
          final y = parentPos.dy + innerRadius * math.sin(angle);
          nodePositions[children[i].id] = Offset(x, y);
        }
      }
    } else {
      for (final n in data.nodes) {
        nodePositions[n.id] = centerOffset;
      }
    }

    return Stack(
      children: [
        // Edges Layer
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _GraphEdgesPainter(
                data: data,
                nodePositions: nodePositions,
                context: context,
              ),
            ),
          ),
        ),

        // Nodes Layer
        for (final node in data.nodes) ...[
          if (nodePositions.containsKey(node.id))
            AnimatedPositioned(
              key: ValueKey(node.id),
              duration: const Duration(milliseconds: 700),
              curve: Curves.fastOutSlowIn,
              left: nodePositions[node.id]!.dx - 40,
              top: nodePositions[node.id]!.dy - 50,
              width: 80,
              height: 100,
              child: GestureDetector(
                onTap: () => onNodeTap(node.id),
                onDoubleTap: node.id == 0
                    ? null
                    : () => context.push('/people/${node.id}'),
                behavior: HitTestBehavior.opaque,
                child: _NodeWidget(node: node, isFocused: node.id == focusId),
              ),
            ),
        ],
      ],
    );
  }
}

class _NodeWidget extends StatelessWidget {
  final GraphNode node;
  final bool isFocused;

  const _NodeWidget({required this.node, required this.isFocused});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Color nodeColor;
    if (node.isUser) {
      nodeColor = cs.primary;
    } else {
      nodeColor = colorForCategory(node.category);
    }

    // Weak nodes are smaller and more transparent
    final double nodeSize = node.isWeak
        ? 34
        : isFocused
        ? 64
        : (node.isUser ? 56 : 48);

    final double nodeOpacity = node.isWeak ? 0.55 : 1.0;

    return Opacity(
      opacity: nodeOpacity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: nodeSize,
            height: nodeSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: nodeColor,
              border: node.isWeak
                  ? Border.all(
                      color: cs.outlineVariant,
                      width: 1.5,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    )
                  : Border.all(
                      color: isFocused ? cs.onSurface : cs.surface,
                      width: isFocused ? 3 : 2,
                    ),
              boxShadow: node.isWeak
                  ? []
                  : [
                      BoxShadow(
                        color: isFocused
                            ? nodeColor.withValues(alpha: 0.6)
                            : Colors.black.withValues(alpha: 0.2),
                        blurRadius: isFocused ? 12 : 6,
                        spreadRadius: isFocused ? 2 : 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            alignment: Alignment.center,
            child: Text(
              node.name.isNotEmpty ? node.name[0].toUpperCase() : '?',
              style: TextStyle(
                color: Colors.white,
                fontSize: nodeSize * 0.45,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              color: node.isWeak
                  ? cs.onSurface.withValues(alpha: 0.45)
                  : isFocused
                  ? cs.onSurface
                  : cs.onSurfaceVariant,
              fontSize: node.isWeak ? 10 : (isFocused ? 14 : 12),
              fontWeight: isFocused ? FontWeight.bold : FontWeight.w600,
            ),
            child: Text(
              node.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Edges Painter ────────────────────────────────────────────────────────

class _GraphEdgesPainter extends CustomPainter {
  final GraphData data;
  final Map<int, Offset> nodePositions;
  final BuildContext context;

  _GraphEdgesPainter({
    required this.data,
    required this.nodePositions,
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cs = Theme.of(context).colorScheme;

    final strongPaint = Paint()
      ..color = cs.outlineVariant.withValues(alpha: 0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final weakPaint = Paint()
      ..color = cs.outlineVariant.withValues(alpha: 0.28)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (final edge in data.edges) {
      final sourcePos = nodePositions[edge.sourceId];
      final targetPos = nodePositions[edge.targetId];

      if (sourcePos != null && targetPos != null) {
        if (edge.isWeak) {
          // Draw dashed line for weak connections
          _drawDashedLine(canvas, sourcePos, targetPos, weakPaint);
        } else {
          canvas.drawLine(sourcePos, targetPos, strongPaint);
        }

        // Draw relation label badge
        final label = edge.relationLabel;
        if (label != null && label.isNotEmpty) {
          final midPoint = Offset(
            (sourcePos.dx + targetPos.dx) / 2,
            (sourcePos.dy + targetPos.dy) / 2,
          );

          textPainter.text = TextSpan(
            text: label,
            style: TextStyle(
              color: edge.isWeak
                  ? Colors.white.withValues(alpha: 0.6)
                  : Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          );
          textPainter.layout();

          final badgeRect = Rect.fromCenter(
            center: midPoint,
            width: textPainter.width + 12,
            height: textPainter.height + 6,
          );

          final rrect = RRect.fromRectAndRadius(
            badgeRect,
            const Radius.circular(12),
          );
          canvas.drawRRect(
            rrect,
            Paint()
              ..color = cs.secondary.withValues(
                alpha: edge.isWeak ? 0.35 : 0.8,
              ),
          );

          textPainter.paint(
            canvas,
            midPoint - Offset(textPainter.width / 2, textPainter.height / 2),
          );
        }
      }
    }
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset from,
    Offset to,
    Paint paint,
  ) {
    const dashLength = 8.0;
    const gapLength = 5.0;

    final total = (to - from).distance;
    final direction = (to - from) / total;
    double drawn = 0;

    while (drawn < total) {
      final start = from + direction * drawn;
      final end = from + direction * (drawn + dashLength).clamp(0, total);
      canvas.drawLine(start, end, paint);
      drawn += dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant _GraphEdgesPainter oldDelegate) {
    return true;
  }
}
