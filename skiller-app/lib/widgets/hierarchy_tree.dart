import 'package:flutter/material.dart';
import 'package:get/get.dart' as getx;
import 'package:graphview/GraphView.dart';
import 'package:skiller/controllers/post/add_post_controller.dart';

class HierarchyTree extends StatefulWidget {
  const HierarchyTree({Key? key}) : super(key: key);
  @override
  _HierarchyTreeState createState() => _HierarchyTreeState();
}

class _HierarchyTreeState extends State<HierarchyTree> {
  final Graph graph = Graph()..isTree = true;
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  AddPostController addPostController = getx.Get.find<AddPostController>();

  // addPostController.selectedNodes;
  // Set<int> selectedNodes = {};

  List hierarchy = [
    {'id': 1, 'label': 'AIKTC'},
    {'id': 2, 'label': 'AIKTC.Engineering'},
    {'id': 3, 'label': 'AIKTC.Pharmacy'},
    {'id': 4, 'label': 'AIKTC.Architecture'},
    {'id': 5, 'label': 'AIKTC.Engineering.Computer'},
    {'id': 6, 'label': 'AIKTC.Engineering.Mechanical'},
    {'id': 7, 'label': 'AIKTC.Engineering.Civil'},
    {'id': 9, 'label': 'AIKTC.Pharmacy.FY'},
    {'id': 10, 'label': 'AIKTC.Pharmacy.SY'},
    {'id': 11, 'label': 'AIKTC.Pharmacy.TY'},
    {'id': 14, 'label': 'AIKTC.Architecture.SY'},
    {'id': 15, 'label': 'AIKTC.Architecture.TY'},
    {'id': 16, 'label': 'AIKTC.Architecture.Fourth_Year'},
    {'id': 17, 'label': 'AIKTC.Architecture.Fifth_Year'},
    {'id': 18, 'label': 'AIKTC.Engineering.Computer.FE'},
    {'id': 20, 'label': 'AIKTC.Engineering.Computer.TE'},
    {'id': 21, 'label': 'AIKTC.Engineering.Computer.BE'},
    {'id': 22, 'label': 'AIKTC.Engineering.Mechanical.FE'},
    {'id': 26, 'label': 'AIKTC.Engineering.Civil.FE'},
    {'id': 30, 'label': 'AIKTC.Engineering.EXTC.FE'},
    {'id': 31, 'label': 'AIKTC.Engineering.EXTC.SE'},
    {'id': 32, 'label': 'AIKTC.Engineering.EXTC.TE'},
    {'id': 33, 'label': 'AIKTC.Engineering.EXTC.BE'},
  ];

  Map json = {};

  @override
  void initState() {
    super.initState();
    json.addAll({'nodes': hierarchy, 'edges': getEdges(hierarchy)});
    var edges = json['edges']!;
    for (var element in edges) {
      var fromNodeId = element['from'];
      var toNodeId = element['to'];
      graph.addEdge(Node.Id(fromNodeId), Node.Id(toNodeId));
    }

    builder
      ..siblingSeparation = (20)
      ..levelSeparation = (50)
      ..subtreeSeparation = (50)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InteractiveViewer(
          constrained: false,
          boundaryMargin: const EdgeInsets.fromLTRB(10, 10, 20, 50),
          minScale: 0.01,
          child: GraphView(
            graph: graph,
            algorithm:
                BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
            paint: Paint()
              ..color = Colors.purple
              ..strokeWidth = 1
              ..style = PaintingStyle.stroke,
            builder: (Node node) {
              var a = node.key!.value as int?;
              var nodes = json['nodes']!;
              var nodeValue = nodes.firstWhere((element) => element['id'] == a);
              return rectangleWidget(nodeValue);
            },
          )),
    );
  }

  Widget rectangleWidget(Map node) {
    return InkWell(
      onTap: () {
        if (addPostController.selectedNodes.contains(node['id'])) {
          List<int> pendingTraversal= [node['id']];
          while(pendingTraversal.isNotEmpty){
               int currentNodeId = pendingTraversal.first;
               pendingTraversal.removeAt(0);
               addPostController.selectedNodes.remove(currentNodeId);

              pendingTraversal.addAll( (json['edges'] as List)
              .where((edge) => edge['from'] == currentNodeId)
              .map((edges) => edges['to'] as int)
              .toList());
              
          }

        } else {
          List<int> pendingTraversal= [node['id']];
          
          while(pendingTraversal.isNotEmpty){
               int currentNodeId = pendingTraversal.first;
               pendingTraversal.removeAt(0);
              addPostController.selectedNodes.add(currentNodeId);

              pendingTraversal.addAll( (json['edges'] as List)
              .where((edge) => edge['from'] == currentNodeId)
              .map((edges) => edges['to'] as int)
              .toList());
              
          }

       
        }
        setState(() {});
        print('clicked ${node['label']} with id : ${node['id']}');
      },
      child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: addPostController.selectedNodes.contains(node['id']) ? Colors.yellow : null,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(color: Colors.blue[100]!, spreadRadius: 1),
            ],
          ),
          child: Text(
            node['label'].split('.').last ?? '',
            style: TextStyle(fontSize: 14),
          )),
    );
  }
}

List getEdges(List hierarchy) {
  List<Map> edges = [];
  for (int i = 0; i < hierarchy.length; i++) {
    for (int j = i + 1; j < hierarchy.length; j++) {
      Map first = hierarchy[i], second = hierarchy[j], parent, child;
      List firstSplitted = first['label'].split('.'),
          secondSplitted = second['label'].split('.');

      /// checking difference of 1 level
      if (i != j &&
          ((firstSplitted.length - secondSplitted.length).abs() == 1)) {
        int parentLevel;
        if (firstSplitted.length < secondSplitted.length) {
          parentLevel = firstSplitted.length;
          parent = first;
          child = second;
        } else {
          parentLevel = secondSplitted.length;
          parent = second;
          child = first;
        }
        bool isEdgeExist = true;
        for (int x = 0; x < parentLevel; x++) {
          if (firstSplitted[x] != secondSplitted[x]) {
            isEdgeExist = false;
            break;
          }
        }
        if (isEdgeExist) {
          Map edge = {'from': parent['id'], 'to': child['id']};
          edges.add(edge);
        }
      }
    }
  }
  return edges;
}
