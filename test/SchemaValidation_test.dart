import 'package:event_dispatcher/Schema/MessageSchema.dart';
import 'package:test/test.dart';

/**
 * @author Dream-Lab software technologies muhtarjan mahmood(مۇختەرجان مەخمۇت)
 * @email ug-project@outlook.com
 * @create date 2021-10-08 10:38:50
 * @modify date 2021-10-08 10:38:50
 * @desc [description]
 */

void main() {
  group("String validation", (){
    test("length validate", (){
      final _string1 = StringSchema(false, 3, 5);
      final r0 = _string1.validate("" ,"adbc");
      expect(r0.passed, true, reason: r0.message);
      expect(_string1.validate("" ,"abcd").passed, true);
      expect(_string1.validate("" ,"acde").passed, true);
      expect(_string1.validate("" ,null).passed, false);
      expect(_string1.validate("" ,"").passed, false);
      expect(_string1.validate("" ,"abcdefg").passed, false);
    });
    test("null validate", (){
      final _string2 = StringSchema(true, 3, 5);
      expect(_string2.validate("" ,null).passed, true);
      expect(_string2.validate("" ,"1").passed, false);
    });
  });
  group("integer test", (){
    final _integerSchema1 = IntegerSchema(false, 10, 5);
    final _integerSchema2 = IntegerSchema(true, 10, 5);
    test("range test", (){
      expect(_integerSchema1.validate("" ,5).passed, true);
      expect(_integerSchema1.validate("" ,10).passed, true);
      expect(_integerSchema1.validate("" ,4).passed, false);
      expect(_integerSchema1.validate("" ,11).passed, false);
      expect(_integerSchema1.validate("" ,null).passed, false);
    });
    test("null test", (){
      expect(_integerSchema2.validate("" ,null).passed, true);
    });
  });
  group("double test", (){
    final _integerSchema1 = DoubleSchema(false, 10, 5);
    final _integerSchema2 = DoubleSchema(true, 10, 5);
    test("range test", (){
      final r0 = _integerSchema1.validate("" ,5);
      expect(r0.passed, true, reason: r0.message);
      expect(_integerSchema1.validate("" ,10).passed, true);
      expect(_integerSchema1.validate("" ,4).passed, false);
      expect(_integerSchema1.validate("" ,11).passed, false);
      expect(_integerSchema1.validate("" ,null).passed, false);
    });
    test("null test", (){
      expect(_integerSchema2.validate("" ,null).passed, true);
    });
  });
  group("boolean", (){
    final _boolean1 = BooleanSchema(false);
    final _boolean2 = BooleanSchema(true);
    test("valid value test", (){
      expect(_boolean1.validate("" ,10).passed, false);
      expect(_boolean1.validate("" ,"10").passed, false);
      expect(_boolean1.validate("" ,true).passed, true);
      expect(_boolean1.validate("" ,false).passed, true);
    });
    test("nullable test", (){
      final r0 = _boolean2.validate("value" ,null);
      expect(r0.passed, true, reason: r0.message);
    });
  });
  group("EnumTest", (){
    test("enum of integer", (){
      final validValues = [10, 20, 30];
      final invalidValues = [11, 21, 31];
      final _enum = EnumSchema(false, IntegerSchema(false, 150, 0), validValues);
      validValues.forEach((element) {
        expect(_enum.validate("" ,element).passed, true);
      });
      invalidValues.forEach((element) {
        expect(_enum.validate("" ,element).passed, false);
      });
      expect(_enum.validate("" ,null).passed, false);
    });
    test("enum of string", (){
      final validValues = ["A", "B", "C"];
      final _enum = EnumSchema(false, StringSchema(false, 1, 255), validValues);
      validValues.forEach((element) {
        expect(_enum.validate("" ,element).passed, true);
      });
      ["E", "F", "G", null].forEach((element) {
        expect(_enum.validate("" ,element).passed, false);
      });
    });
  });
  group("Array test", (){
    final _array1 = ArraySchema(false, StringSchema(false, 1, 5), 1, 3);
    final _array2 = ArraySchema(false, StringSchema(true, 1, 5), 1, 3);
    test("range test", (){
      expect(_array1.validate("" ,["A", "B"]).passed, true);
      expect(_array1.validate("" ,[]).passed, false);
      expect(_array1.validate("" ,["A"]).passed, true);
      expect(_array1.validate("" ,["A", "B", "C", "D"]).passed, false);
      expect(_array1.validate("" ,[0]).passed, false);
      expect(_array1.validate("" ,[null]).passed, false);
      expect(_array1.validate("" ,["AA", true, 0]).passed, false);
      expect(_array1.validate("" ,[""]).passed, false);
      expect(_array1.validate("" ,["123456"]).passed, false);
      expect(_array1.validate("" ,["12345", null]).passed, false);
    });
    test("null test", (){
      expect(_array2.validate("" ,[null]).passed, true);
      expect(_array2.validate("" ,[""]).passed, false);
      expect(_array2.validate("" ,["ABC"]).passed, true);
    });
  });
  group("Object test", (){
    final _person = CustomObjectSchema(false, {
      "name": StringSchema(false, 1, 5),
      "level": IntegerSchema(false, 5, 0),
      "gender": EnumSchema(false, StringSchema(false, 0, 255), ["None", "Man", "Women"]),
      "married": BooleanSchema(false),
      "money": DoubleSchema(false, 5.0, 0.0),
    });
    _person.properties["girlFriends"] = ArraySchema(false, _person, 0, 3);

    test("property validation", (){
      final obj1 = {
        "name": "Abdu",
        "level": 3,
        "gender": "Man",
        "married": false,
        "money": 0.0,
        "girlFriends": [
          {
            "name": "AAA",
            "level": 1,
            "gender": "Women",
            "married": false,
            "money": 3.0,
            "girlFriends": [
              {
                "name": "HHH",
                "level": 1,
                "gender": "Women",
                "married": false,
                "money": 3.0,
                "girlFriends":[]
              },
            ]
          },
          {
            "name": "BBB",
            "level": 2,
            "gender": "Women",
            "married": false,
            "money": 2,
            "girlFriends":[]
          }
        ]
      };
      final result = _person.validate("obj" ,obj1);
      expect(result.passed, true, reason: result.message);
    });
    test("Empty object test", (){
      final r0 = _person.validate("obj", {
        "name": "hello"
      });
      expect(r0.passed, false, reason: "expected: '${r0.message}'");
    });
    test("enum in object validation test", (){
      final v0 = CustomObjectSchema(false, {
        "gender": EnumSchema(false, StringSchema(false, 1, 10), ["Male", "Female", "None"])
      });
      final r0 = v0.validate("obj", {
        "gender": "-"
      });
      expect(r0.passed, false, reason: r0.message);
    });
  });
}