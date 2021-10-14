// import 'package:event_dispatcher/EventDispatcher.dart';
//
// /**
//  * @author Dream-Lab software technologies muhtarjan mahmood(مۇختەرجان مەخمۇت)
//  * @email ug-project@outlook.com
//  * @create date 2021-10-07 16:23:41
//  * @modify date 2021-10-07 16:23:41
//  * @desc [description]
//  */
//
//
// class TreeNodeBase {
//   final String key;
//   final List<TreeNodeBase> children = [];
//
//   TreeNodeBase(this.key);
// }
// class TreeDataNode extends TreeNodeBase {
//   final MessageNode node;
//   final TreeNodeBase parent;
//   TreeDataNode(String key, this.parent, this.node) : super(key);
// }
// class TreeIndexNode extends TreeNodeBase {
//   final TreeNodeBase parent;
//   TreeIndexNode(String key, this.parent) : super(key){
//     parent.children.add(this);
//   }
//   void removeFromParent() {
//     parent.children.remove(this);
//   }
// }
