import 'package:event_dispatcher/EventDispatcher.dart';
import 'package:test/test.dart';

/**
 * @author Dream-Lab software technologies muhtarjan mahmood(مۇختەرجان مەخمۇت)
 * @email ug-project@outlook.com
 * @create date 2021-10-12 15:41:53
 * @modify date 2021-10-12 15:41:53
 * @desc [description]
 */



void main() {
  group("Deep clone => ", () {
    test("Map and list object", () {
      final mapA = <String, dynamic>{
        "address": {
          "name": "Urumqi",
        },
        "name": "Ug-Project",
        "researchs": [
          "Linux epoll"
        ]
      };
      final mapB = mapA.deepClone();
      mapA["address"]!["name"] = "Kashgar";
      mapA["name"] = "Dream-Lab";
      mapA["researchs"].add("Unreal engine");
      mapA["researchs"].add("Robotics automation");
      expect(mapB["name"], "Ug-Project");
      expect(mapB["address"]!["name"], "Urumqi");
      expect(mapB["name"], isNot(equals(mapA["name"])));
      expect(mapB["address"]!["name"], isNot(mapA["address"]!["name"]));
      expect(mapB["researchs"]!.length, isNot(mapA["researchs"].length));
    });
  });
}