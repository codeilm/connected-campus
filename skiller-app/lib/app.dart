import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:skiller/controllers/auth/auth_controller.dart';
import 'package:provider/provider.dart';
// import 'screens/main_screen.dart';
import 'server/server_provider.dart';
import 'services/routes/route.dart';
import 'services/routes/route_list.dart';

class App extends StatelessWidget {
  static int count = 0;
  App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return GraphQLProvider(
      client: Provider.of<ServerProvider>(context).client,
      child: const GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AIKTC',
          initialRoute: RouteList.initialRoute,
          // home: LoginScreen(),
      ),
    );
  }
}
