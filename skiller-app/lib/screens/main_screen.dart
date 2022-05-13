import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:skiller/controllers/auth/auth_controller.dart';
import 'package:skiller/screens/profile_screen.dart';
import 'package:skiller/widgets/app_drawer.dart';
import 'package:skiller/screens/notifications_screen.dart';
import 'package:skiller/server/queries.dart';
import 'package:skiller/widgets/common/loading_cube.dart';

import '../controllers/user_controller.dart';
import '../models/home_search_result.dart';
import '../models/user.dart';
import 'home_screen.dart';
import 'post/post_metadata_screen.dart';
import 'chat/chat_list_screen.dart';
import 'collab_screen.dart';
import 'explore_screen.dart';
import 'skilled_people_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;
  var pageController = PageController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  bool shouldShowSearchField = false;
  @override
  void initState() {
    super.initState();
    Get.put(UserController());
    Get.find<AuthController>()
        .initializeUser(context: context, fromLocal: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        drawer: const AppDrawer(),
        body: SafeArea(
          child: NestedScrollView(
            floatHeaderSlivers: true,
            headerSliverBuilder: (context, isInn) {
              return [
                SliverAppBar(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  floating: true,
                  snap: true,
                  leading: IconButton(
                      icon: const Icon(Icons.menu, color: Colors.black),
                      onPressed: () {
                        scaffoldKey.currentState!.openDrawer();
                      }),
                  title: const Text(
                    'Skiller',
                    style: TextStyle(color: Colors.purple),
                  ),
                  centerTitle: true,
                  actions: [
                    IconButton(
                        icon: const Icon(Icons.search, color: Colors.black),
                        onPressed: () {
                          setState(() {
                            shouldShowSearchField = !shouldShowSearchField;
                          });
                        }),
                    IconButton(
                        icon: const Icon(Icons.notifications,
                            color: Colors.black),
                        onPressed: () {
                          Get.to(const NotificationsScreen());
                        })
                  ],
                )
              ];
            },
            body: Stack(
              children: [
                PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: pageController,
                  onPageChanged: (int index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  children: const [
                    HomeScreen(),
                    ExploreScreen(),
                    PostMetadataScreen(),
                    CollabScreen(),
                    ChatListScreen()
                  ],
                ),
                if (shouldShowSearchField) const SearchField(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavyBar(
          selectedIndex: selectedIndex,
          showElevation: true, // use this to remove appBar's elevation
          onItemSelected: (index) => setState(() {
            selectedIndex = index;
            pageController.animateToPage(index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease);
          }),
          items: [
            BottomNavyBarItem(
              icon: Icon(Icons.home),
              title: Text('Home'),
              inactiveColor: Colors.grey.shade400,
            ),
            BottomNavyBarItem(
              icon: Icon(Icons.grid_view),
              title: Text('Explore'),
              inactiveColor: Colors.grey.shade400,
            ),
            BottomNavyBarItem(
              icon: Icon(FontAwesomeIcons.plus),
              title: Text('Post'),
              inactiveColor: Colors.grey.shade400,
            ),
            BottomNavyBarItem(
              icon: Icon(Icons.group),
              title: Text('Collab'),
              inactiveColor: Colors.grey.shade400,
            ),
            BottomNavyBarItem(
              icon: Icon(Icons.message),
              title: Text('Chat'),
              inactiveColor: Colors.grey.shade400,
            ),
          ],
        ));
  }
}

class SearchField extends StatefulWidget {
  const SearchField({Key? key}) : super(key: key);

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  List<HomeSearchResult> searchResult = [];
  // [
  //   HomeSearchResult(,name: 'Computer Graphics', type: 1),
  //   HomeSearchResult(name: 'Computer Programming', type: 1),
  //   HomeSearchResult(name: 'Coder', type: 2),
  //   HomeSearchResult(name: 'Codeilm', type: 2),
  //   HomeSearchResult(name: 'Calm Boy', type: 2),
  // ];

  bool isLoading = false;

  TextEditingController searchTEC = TextEditingController();

  LayerLink layerLink = LayerLink();

  OverlayState? searchResultOverlay;

  OverlayEntry? searchResultOverlayEntry;

  @override
  void initState() {
    super.initState();
    searchResultOverlay = Overlay.of(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showSearchResultOverlay() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    if (searchResultOverlayEntry != null) {
      searchResultOverlayEntry?.remove();
    }
    searchResultOverlayEntry = OverlayEntry(
        builder: (context) => Positioned(
            top: 0,
            left: 0,
            bottom: 50,
            width: size.width,
            child: CompositedTransformFollower(
                link: layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, size.height),
                child: buildOverlay())));
    searchResultOverlay?.insert(searchResultOverlayEntry!);
  }

  void hideSearchResultOverlay() {
    if (searchResultOverlayEntry != null) {
      searchResultOverlayEntry?.remove();
      searchResultOverlayEntry = null;
    }
  }

  Widget buildOverlay() => Align(
        alignment: Alignment.topCenter,
        child: Material(
          elevation: isLoading ? 0 : 8,
          child: isLoading
              ? const SizedBox(
                  height: 250,
                  child: LoadingCube(),
                )
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: searchResult.length,
                  itemBuilder: (context, index) {
                    HomeSearchResult item = searchResult[index];
                    return ListTile(
                      leading: item.type == HomeSearchResultType.people
                          ? const Icon(Icons.person)
                          : const Icon(Icons.style),
                      title: Text(item.name),
                      onTap: () {
                        hideSearchResultOverlay();
                        if (item.type == HomeSearchResultType.people) {
                          Get.to(() => ProfileScreen(
                              isCurrentUser: false,
                              user: User(
                                  userId: item.id, unofficialName: item.name)));
                        } else {
                          Get.to(() => SkilledPeopleScreen(
                              skill: item.name, skillId: item.id));
                        }
                      },
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
                ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        color: const Color(0xFFEBEDFA),
        child: CompositedTransformTarget(
          link: layerLink,
          child: TextField(
            controller: searchTEC,
            onChanged: (value) {},
            decoration: InputDecoration(
              hintText: "Search",
              fillColor: const Color(0xFFF2F4FC),
              filled: true,
              isDense: true,
              suffixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15), //15
                child: Mutation(
                  options: MutationOptions(
                      document: gql(Queries.searchByKeywordQuery),
                      onCompleted: (response) {
                        debugPrint('Search completed Response : $response');
                        searchResult = List<HomeSearchResult>.from(
                            response!['searchByKeyword']
                                    ['SearchResultListVariable']
                                .map((map) => HomeSearchResult.fromMap(
                                    map as Map<String, dynamic>)));

                        setState(() {
                          isLoading = false;
                        });
                        showSearchResultOverlay();
                      }),
                  builder: (MultiSourceResult<dynamic> Function(
                              Map<String, dynamic>,
                              {Object? optimisticResult})
                          runMutation,
                      QueryResult<dynamic>? result) {
                    return IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          runMutation({'keyword': searchTEC.text});
                          FocusManager.instance.primaryFocus?.unfocus();
                          setState(() {
                            isLoading = true;
                          });

                          showSearchResultOverlay();
                        });
                  },
                ),
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        
        ),
      ),
    );
  }
}
