import '../database/database.dart';

class RelationHelper {
  /// Returns a standardized relationship label (e.g., 'kid' -> 'Child', 'mom' -> 'Mother').
  static String getStandardRelation(String relation) {
    final lower = relation.toLowerCase().trim();
    switch (lower) {
      case 'son':
        return 'Son';
      case 'daughter':
        return 'Daughter';
      case 'child':
      case 'kid':
      case 'children':
        return 'Child';
      case 'father':
      case 'dad':
        return 'Father';
      case 'mother':
      case 'mom':
        return 'Mother';
      case 'parent':
        return 'Parent';
      case 'brother':
        return 'Brother';
      case 'sister':
        return 'Sister';
      case 'sibling':
        return 'Sibling';
      case 'husband':
        return 'Husband';
      case 'wife':
        return 'Wife';
      case 'spouse':
      case 'partner':
        return 'Partner';
      case 'manager':
      case 'boss':
      case 'supervisor':
        return 'Manager';
      case 'employee':
      case 'report':
      case 'direct report':
      case 'subordinate':
        return 'Direct Report';
      case 'mentor':
        return 'Mentor';
      case 'mentee':
      case 'student':
        return 'Mentee';
      case 'teacher':
      case 'professor':
      case 'instructor':
        return 'Teacher';
      case 'uncle':
        return 'Uncle';
      case 'aunt':
        return 'Aunt';
      case 'nephew':
        return 'Nephew';
      case 'niece':
        return 'Niece';
      case 'nibling':
        return 'Nibling';
      case 'grandfather':
      case 'grandpa':
        return 'Grandfather';
      case 'grandmother':
      case 'grandma':
        return 'Grandmother';
      case 'grandparent':
        return 'Grandparent';
      case 'grandson':
        return 'Grandson';
      case 'granddaughter':
        return 'Granddaughter';
      case 'grandchild':
        return 'Grandchild';
      case 'cousin':
        return 'Cousin';
      case 'friend':
      case 'best friend':
        return 'Friend';
      case 'coworker':
      case 'colleague':
        return 'Coworker';
      default:
        // By default, just capitalize what they typed
        return _capitalize(relation.trim());
    }
  }

  /// Returns the logical inverse of a given relationship.
  static String getInverseRelation(String relation) {
    final lower = relation.toLowerCase().trim();
    switch (lower) {
      case 'son':
      case 'daughter':
      case 'child':
      case 'kid':
      case 'children':
        return 'Parent';
      case 'father':
      case 'mother':
      case 'parent':
      case 'dad':
      case 'mom':
        return 'Child';
      case 'brother':
      case 'sister':
      case 'sibling':
        return 'Sibling';
      case 'husband':
      case 'wife':
      case 'spouse':
      case 'partner':
        return 'Partner';
      case 'manager':
      case 'boss':
      case 'supervisor':
        return 'Direct Report';
      case 'employee':
      case 'report':
      case 'direct report':
      case 'subordinate':
        return 'Manager';
      case 'mentor':
        return 'Mentee';
      case 'mentee':
      case 'student':
        return 'Mentor';
      case 'teacher':
      case 'professor':
      case 'instructor':
        return 'Student';
      case 'uncle':
      case 'aunt':
        return 'Niece/Nephew';
      case 'nephew':
      case 'niece':
      case 'nibling':
        return 'Uncle/Aunt';
      case 'grandfather':
      case 'grandmother':
      case 'grandparent':
      case 'grandpa':
      case 'grandma':
        return 'Grandchild';
      case 'grandson':
      case 'granddaughter':
      case 'grandchild':
        return 'Grandparent';
      case 'cousin':
        return 'Cousin';
      case 'friend':
      case 'best friend':
      case 'coworker':
      case 'colleague':
        return relation; // These are symmetric
      default:
        // By default, if we don't know the inverse, just return the relation itself
        return relation;
    }
  }

  /// Calculates the contextual label for the [subjectId] given a [connection].
  ///
  /// Example: A adds B as "Son".
  /// - A is [connection.personId], B is [connection.connectedPersonId].
  /// - If we're displaying a label describing A to B, subjectId = A.
  ///   It will return "Parent" (Inverse of "Son").
  /// - If we're displaying a label describing B to A, subjectId = B.
  ///   It will return "Son".
  static String getLabelForSubject({
    required int subjectId,
    required PersonConnection connection,
  }) {
    if (subjectId == connection.personId) {
      // The subject created the connection. Thus, the target is the subject's [Label].
      // E.g. Target is Subject's Son. Therefore, Subject is Target's INVERSE(Label).
      return _capitalize(getInverseRelation(connection.relationLabel));
    } else {
      // The subject is the target of the connection.
      // E.g. Subject is Creator's Son. The Subject IS the [Label].
      return _capitalize(connection.relationLabel);
    }
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
