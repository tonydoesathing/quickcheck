import 'dart:convert';

import 'package:quickcheck/data/model/group.dart';
import 'package:quickcheck/data/model/student.dart';
import 'package:test/test.dart';

void main() {
  test('Student creates a Student from JSON', () {
    String json = '''{
        "id": 1,
        "name": "student",
        "date_edited": "2022-12-15T16:27:40.421634Z",
        "date_created": "2022-12-15T16:27:40.421667Z",
        "groups": [2,3],
        "class_id": 1
    }''';
    final Student jsonStudent = Student.fromJson(jsonDecode(json));
    const Student expectedStudent =
        Student(name: "student", id: 1, groups: [2, 3], classId: 1);
    expect(jsonStudent, equals(expectedStudent));
  });

  test('Group creates Group from JSON', () {
    String json = '''{
        "id": 9,
        "name": "Group 1",
        "date_edited": "2022-12-15T17:35:04.950970Z",
        "date_created": "2022-12-15T17:35:04.950970Z",
        "student_set": [
            {
                "id": 1,
                "name": "bob",
                "date_edited": "2022-12-15T04:54:42.776360Z",
                "date_created": "2022-12-15T04:54:42.776360Z",
                "groups": [
                    2,
                    6,
                    9
                ],
                "class_id": 2
            }
        ],
        "class_id": 1
    }''';
    final Group jsonGroup = Group.fromJson(jsonDecode(json));
    const Group expectedGroup =
        Group(id: 9, name: "Group 1", classId: 1, members: [
      Student(name: "bob", id: 1, groups: [2, 6, 9], classId: 2)
    ]);
    print(jsonGroup);
    print(expectedGroup);

    expect(jsonGroup, equals(expectedGroup));
  });
}
